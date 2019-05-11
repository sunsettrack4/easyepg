#!/bin/bash

#      Copyright (C) 2019 Jan-Luca Neumann
#      https://github.com/sunsettrack4/easyepg
#
#      Collaborators:
#      - DeBaschdi ( https://github.com/DeBaschdi )
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with easyepg. If not, see <http://www.gnu.org/licenses/>.


# ################
# INITIALIZATION #
# ################

#
# UPDATE XML FILE
#

if [ -e settings.json ]
then
	printf "\r- DOWNLOAD PROCESS -\n\n"
	
	printf "\rUpdating XML file..."
	
	# EXTRACT VALUES FROM JSON FILE
	grep '"path":' settings.json | sed 's/\({"path": "\)\(.*\)"}/\2/g' > /tmp/res_path
		
	# CHECK IF WEB RESOURCE IS AVAILABLE
	if grep -q -E "http://|https://" /tmp/res_path
	then
		printf "\rUpdating XML file from web resource..."
		if ! curl -s -L $(</tmp/res_path) > ext_file
		then
			if [ -e ext_file.xml ]
			then
				printf "\rWeb resource unavailable! File not updated!"
				rm /tmp/res_path ext_file 2> /dev/null
			else
				printf "\rWeb resource unavailable! Process stopped!"
				rm /tmp/res_path ext_file 2> /dev/null
				exit 0
			fi
		fi
				
	# CHECK IF FILE RESOURCE IS AVAILABLE
	elif grep -q "file://" /tmp/res_path
	then
		printf "\rUpdating XML file from local resource..."
		sed -i 's/file:\/\///g' /tmp/res_path
		if ! cp $(</tmp/res_path) ext_file 2> /dev/null
		then
			if [ -e ext_file.xml ]
			then
				printf "\rLocal resource unavailable! File not updated!"
				rm /tmp/res_path ext_file 2> /dev/null
			else
				printf "\rLocal resource unavailable! Process stopped!"
				rm /tmp/res_path ext_file 2> /dev/null
				exit 0
			fi
		else
			sed -i 's/.*/file:\/\/&/g' /tmp/res_path
		fi
	fi
			
	# CHECK FILE TYPE
	if [ -e ext_file ]
	then
		# DECOMPRESS XZ
		if file ext_file | grep -q "XZ compressed data"
		then
			printf "\rDecompressing XZ file...                  "
			mv ext_file ext_file.xz
			xz -d ext_file.xz
		fi
			
		# DECOMPRESS GZ
		if file ext_file | grep -q "GZ compressed data"
		then
			printf "\rDecompressing GZ file...                  "
			mv ext_file ext_file.gz
			gzip -d ext_file.gz
		fi
			
		# OVERWRITE XML IF FILE IS VALID
		if file ext_file | grep -q "XML"
		then
			printf "\rValidating XML file...                    "
			if xmllint --noout ext_file | grep -q "parser error"
			then
				if [ -e ext_file.xml ]
				then
					printf "\rXML cannot be updated due to parser error!"
					rm /tmp/res_path ext_file 2> /dev/null
				else
					printf "\rXML cannot be updated due to parser error! Process stopped!"
					rm /tmp/res_path ext_file 2> /dev/null
					exit 0
				fi
			else
				printf "\rValidating XML file... DONE!              "
				mv ext_file ext_file.xml
			fi
		fi
	fi
else
	printf "\rSettings.json config file does not exist! Process stopped!"
	exit 0
fi


#
# CREATE XML FILE
#

printf "\n\n- FILE CREATION PROCESS -\n\n"

# LOADING CHANNELS
printf "\rCreating channel manifest...                  "
perl ch_ext.pl > ext_channels

# LOADING EPG DATA
printf "\rCreating programme manifest...                "
perl epg_ext.pl > ext_epg

# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat ext_epg >> ext_channels && mv ext_channels external && rm ext_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<tv>' external
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" external
sed -i '$s/.*/&\n\n<\/tv>/g' external
mv external external.xml
sed -i 's/\&/\&amp;/g' external.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
rm errorlog warnings.txt 2> /dev/null
xmllint --noout external.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv external.xml external_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm external_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" external.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep "<channel id=" external.xml > /tmp/id_check
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY CHANNEL DATA!" >> errorlog
	fi
	
	uniq -d /tmp/id_check > /tmp/id_checked
	if [ -s /tmp/id_checked ]
	then
		echo "[ EPG ERROR ] XMLTV FILE CONTAINS DUPLICATED CHANNEL IDs!" >> errorlog
		sed -i 's/.*/[ DUPLICATE ] &/g' /tmp/id_checked && cat /tmp/id_checked >> errorlog
		rm /tmp/id_check /tmp/id_checked 2> /dev/null
	else
		rm /tmp/id_check /tmp/id_checked 2> /dev/null
	fi
	
	if [ -e errorlog ]
	then
		mv external.xml external_ERROR.xml
		cat errorlog >> warnings.txt
	else
		rm errorlog 2> /dev/null
	fi
fi

# SHOW WARNINGS

if [ -s warnings.txt ]
then
	sort -u warnings.txt > sorted_warnings.txt && mv sorted_warnings.txt warnings.txt
	sed -i '/^$/d' warnings.txt
	
	echo "========== EPG CREATION: WARNING/ERROR LOG ============"
	echo ""
	
	input="warnings.txt"
	while IFS= read -r var
	do
		echo "$var"
	done < "$input"
	
	echo ""
	echo "======================================================="
	echo ""
fi
