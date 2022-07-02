#!/bin/bash

#      Copyright (C) 2019-2020 Jan-Luca Neumann
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
# SETUP ENVIRONMENT
#

mkdir mani 2> /dev/null		# manifest files

if grep -q "CH" init.json 2> /dev/null
then
	printf "+++ COUNTRY: SWITZERLAND +++\n\n"
fi

if grep -q '"day": "0"' settings.json
then
	printf "EPG Grabber disabled!\n\n"
	exit 0
fi

if ! curl --write-out %{http_code} --silent --output /dev/null https://tv.blue.ch/tv-guide | grep -q "200"
then
	printf "Service provider unavailable!\n\n"
	exit 0
fi


# ##################
# DOWNLOAD PROCESS #
# ##################

echo "- DOWNLOAD PROCESS -" && echo ""

#
# DELETE OLD FILES
#

printf "\rDeleting old files...                       "

rm mani/* 2> /dev/null


#
# LOADING MANIFEST FILES
#

printf "\rFetching channel list... "
curl -s https://services.sg101.prd.sctv.ch/portfolio/tv/channels > /tmp/chlist
jq '.' /tmp/chlist > /tmp/workfile
sed '1s/\[/{"attributes":[/g;$s/\]/]}/g' /tmp/workfile > /tmp/chlist

printf "\rChecking manifest files... "
perl chlist_printer.pl > /tmp/compare.json
perl url_printer.pl 2>errors.txt | sed '/DUMMY/d' > mani/common

printf "\n$(echo $(wc -l < mani/common)) manifest file(s) to be downloaded!\n\n"

if [ $(wc -l < mani/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < mani/common) / 7)))
	
	split --lines=$(( $number + 1 )) --numeric-suffixes mani/common mani/day

	rm mani/common 2> /dev/null
else	
	mv mani/common mani/day00
fi


#
# CREATE STATUS BAR FOR MANIFEST FILE DOWNLOAD
#

x=$(wc -l < mani/day00)
y=20
h=40

if [ $x -gt $h ]
then
	z5=$(expr $x / $y)
	z10=$(expr $x / $y \* 2)
	z15=$(expr $x / $y \* 3)
	z20=$(expr $x / $y \* 4)
	z25=$(expr $x / $y \* 5)
	z30=$(expr $x / $y \* 6)
	z35=$(expr $x / $y \* 7)
	z40=$(expr $x / $y \* 8)
	z45=$(expr $x / $y \* 9)
	z50=$(expr $x / $y \* 10)
	z55=$(expr $x / $y \* 11)
	z60=$(expr $x / $y \* 12)
	z65=$(expr $x / $y \* 13)
	z70=$(expr $x / $y \* 14)
	z75=$(expr $x / $y \* 15)
	z80=$(expr $x / $y \* 16)
	z85=$(expr $x / $y \* 17)
	z90=$(expr $x / $y \* 18)
	z95=$(expr $x / $y \* 19)

	echo "#!/bin/bash" > progressbar

	# START
	echo "sed -i '2i\\" >> progressbar
	echo "Progress [                    ]   0%% ' mani/day00" >> progressbar

	# 5%
	echo "sed -i '$z5 i\\" >> progressbar
	echo "Progress [#                   ]   5%% ' mani/day00" >> progressbar

	# 10%
	echo "sed -i '$z10 i\\" >> progressbar
	echo "Progress [##                  ]  10%% ' mani/day00" >> progressbar
	
	# 15%
	echo "sed -i '$z15 i\\" >> progressbar
	echo "Progress [###                 ]  15%% ' mani/day00" >> progressbar

	# 20%
	echo "sed -i '$z20 i\\" >> progressbar
	echo "Progress [####                ]  20%% ' mani/day00" >> progressbar

	# 25%
	echo "sed -i '$z25 i\\" >> progressbar
	echo "Progress [#####               ]  25%% ' mani/day00" >> progressbar

	# 30%
	echo "sed -i '$z30 i\\" >> progressbar
	echo "Progress [######              ]  30%% ' mani/day00" >> progressbar

	# 35%
	echo "sed -i '$z35 i\\" >> progressbar
	echo "Progress [#######             ]  35%% ' mani/day00" >> progressbar

	# 40%
	echo "sed -i '$z40 i\\" >> progressbar
	echo "Progress [########            ]  40%% ' mani/day00" >> progressbar

	# 45%
	echo "sed -i '$z45 i\\" >> progressbar
	echo "Progress [#########           ]  45%% ' mani/day00" >> progressbar

	# 50%
	echo "sed -i '$z50 i\\" >> progressbar
	echo "Progress [##########          ]  50%% ' mani/day00" >> progressbar

	# 55%
	echo "sed -i '$z55 i\\" >> progressbar
	echo "Progress [###########         ]  55%% ' mani/day00" >> progressbar

	# 60%
	echo "sed -i '$z60 i\\" >> progressbar
	echo "Progress [############        ]  60%% ' mani/day00" >> progressbar

	# 65%
	echo "sed -i '$z65 i\\" >> progressbar
	echo "Progress [#############       ]  65%% ' mani/day00" >> progressbar

	# 70%
	echo "sed -i '$z70 i\\" >> progressbar
	echo "Progress [##############      ]  70%% ' mani/day00" >> progressbar

	# 75%
	echo "sed -i '$z75 i\\" >> progressbar
	echo "Progress [###############     ]  75%% ' mani/day00" >> progressbar

	# 80%
	echo "sed -i '$z80 i\\" >> progressbar
	echo "Progress [################    ]  80%% ' mani/day00" >> progressbar

	# 85%
	echo "sed -i '$z85 i\\" >> progressbar
	echo "Progress [#################   ]  85%% ' mani/day00" >> progressbar

	# 90%
	echo "sed -i '$z90 i\\" >> progressbar
	echo "Progress [##################  ]  90%% ' mani/day00" >> progressbar

	# 95%
	echo "sed -i '$z95 i\\" >> progressbar
	echo "Progress [################### ]  95%% ' mani/day00" >> progressbar

	# 100%
	echo "sed -i '\$i\\" >> progressbar
	echo "Progress [####################] 100%% ' mani/day00" >> progressbar

	sed -i 's/ i/i/g' progressbar
	bash progressbar
	sed -i -e 's/Progress/printf "\\rProgress/g' -e '/Progress/s/.*/&"/g' mani/day00
	rm progressbar
fi


#
# CREATE MANIFEST DOWNLOAD SCRIPTS
#

for time in {0..8..1}
do	
	sed -i '1i#\!\/bin\/bash\n' mani/day0${time} 2> /dev/null
done


#
# DOWNLOAD MANIFEST FILES
#

printf "\rLoading manifest files..."
echo ""

for a in {0..8..1}
do
	bash mani/day0${a} 2> /dev/null &
done
wait

rm mani/day0* 2> /dev/null
	
echo "DONE!" && printf "\n"


#
# CREATE EPG BROADCAST LIST
#

printf "\rCreating EPG manifest file... "

rm /tmp/manifile.json 2> /dev/null
cat mani/* > /tmp/manifile.json
jq -s '.' /tmp/manifile.json 2>>errors.txt > /tmp/epg_workfile 
sed -i '1s/\[/{ "attributes":[/g;$s/\]/&}/g' /tmp/epg_workfile

echo "DONE!" && printf "\n"


#
# SHOW ERROR MESSAGE + ABORT PROCESS IF CHANNEL IDs WERE CHANGED
#

sort -u errors.txt > /tmp/errors_sorted.txt && mv /tmp/errors_sorted.txt errors.txt

if [ -s errors.txt ]
then
	echo "================= CHANNEL LIST: LOG ==================="
	echo ""
	
	input="errors.txt"
	while IFS= read -r var
	do
		echo "$var"
	done < "$input"
	
	echo ""
	echo "======================================================="
	echo ""
	
	# cp /tmp/chlist chlist_old
else
	rm errors.txt 2> /dev/null
fi


# ###################
# CREATE XMLTV FILE #
# ###################

# WORK IN PROGRESS

echo "- FILE CREATION PROCESS -" && echo ""

rm workfile chlist 2> /dev/null

# DOWNLOAD CHANNEL LIST + RYTEC/EIT CONFIG FILES (JSON)
printf "\rRetrieving channel list and config files...          "
curl -s https://services.sg101.prd.sctv.ch/portfolio/tv/channels > chlist
jq '.' chlist > /tmp/workfile
sed '1s/\[/{"attributes":[/g;$s/\]/]}/g' /tmp/workfile > chlist
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/swc_channels.json > swc_channels.json
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/swc_genres.json > swc_genres.json

# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > swisscom_channels
sort -u swisscom_channels > /tmp/swisscom_channels && mv /tmp/swisscom_channels swisscom_channels
sed -i 's/></>\n</g;s/<display-name/  &/g;s/<icon src/  &/g' swisscom_channels

# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                            "
perl cid_json.pl > swc_cid.json && rm chlist

# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
#perl epg_json2xml.pl > swisscom_epg 2>epg_warnings.txt && rm /tmp/epg_workfile 2> /dev/null
perl epg_json2xml.pl > swisscom_epg 2>epg_warnings.txt 

# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat swisscom_epg >> swisscom_channels && mv swisscom_channels swisscom && rm swisscom_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019-2020 Jan-Luca Neumann -->\n<tv>' swisscom
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" swisscom
sed -i '$s/.*/&\n\n<\/tv>/g' swisscom
rm /tmp/epg_workfile 2> /dev/null 
mv swisscom swisscom.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout swisscom.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv swisscom.xml swisscom_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm swisscom_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" swisscom.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep "<channel id=" swisscom.xml > /tmp/id_check
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
		mv swisscom.xml swisscom_ERROR.xml
		cat errorlog >> warnings.txt
	else
		rm errorlog 2> /dev/null
	fi
fi

# SHOW WARNINGS
cat epg_warnings.txt >> warnings.txt && rm epg_warnings.txt
sort -u warnings.txt > sorted_warnings.txt && mv sorted_warnings.txt warnings.txt
sed -i '/^$/d' warnings.txt

if [ -s warnings.txt ]
then
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
