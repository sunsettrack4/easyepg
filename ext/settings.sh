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
				dialog --backtitle "[X1E10] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS" --title "UPDATE ERROR" --msgbox "Web resource unavailable! File not updated!" 5 50
				rm /tmp/res_path ext_file 2> /dev/null
			else
				dialog --backtitle "[X1F10] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS" --title "UPDATE ERROR" --msgbox "Web resource unavailable! Setup deleted!" 5 50
				rm /tmp/res_path ext_file settings.json channels.json 2> /dev/null
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
				dialog --backtitle "[X1E20] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS" --title "UPDATE ERROR" --msgbox "Local resource unavailable! File not updated!" 5 50
				rm /tmp/res_path ext_file 2> /dev/null
			else
				dialog --backtitle "[X1F20] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS" --title "UPDATE ERROR" --msgbox "Local resource unavailable! Setup deleted!" 5 50
				rm /tmp/res_path ext_file settings.json channels.json 2> /dev/null
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
					dialog --backtitle "[X1E30] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS" --title "UPDATE ERROR" --msgbox "XML cannot be updated due to parser error!" 5 40
					rm /tmp/res_path ext_file 2> /dev/null
				else
					dialog --backtitle "[X1F30] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS" --title "UPDATE ERROR" --msgbox "XML cannot be updated due to parser error! File deleted!" 5 60
					rm /tmp/res_path ext_file settings.json channels.json 2> /dev/null
				fi
			else
				mv ext_file ext_file.xml
			fi
		fi
	fi
fi


#
# SETTINGS MENU
#

echo "H" > /tmp/value

while grep -q "H" /tmp/value
do
	# X1000 MENU OVERLAY
	echo 'dialog --backtitle "[X1000] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS" --title "SETTINGS" --menu "Please select the option you want to change:" 14 60 10 \' > /tmp/menu 
	
	if [ -e settings.json ]
	then
		# EXTRACT VALUES FROM JSON FILE
		grep '"path":' settings.json | sed 's/\("path": "\)\(.*\)",/path=\2/g' > /tmp/settings_new
	else
		# ENTER FILE PATH
		echo "2" > /tmp/value
	fi
	
	# X1100 CHANNEL LIST
	echo '	1 "MODIFY CHANNEL LIST" \' >> /tmp/menu

	# X1200 FILE PATH
	echo '	2 "MODIFY FILE PATH" \' >> /tmp/menu
	
	# X1300 RUN XML SCRIPT
	echo '	3 "RUN XML SCRIPT" \' >> /tmp/menu
	
	# X1900 DELETE INSTANCE
	echo '	9 "REMOVE GRABBER INSTANCE" \' >> /tmp/menu
	
	echo "2> /tmp/value" >> /tmp/menu
	
	if [ ! -e channels.json ]
	then
		if [ -e settings.json ]
		then
			echo "1" > /tmp/value
		fi
	else
		bash /tmp/menu
		input="$(cat /tmp/value)"
	fi
	
	
	# ####################
	# X1100 CHANNEL LIST #
	# ####################
	
	if grep -q "1" /tmp/value
	then
		# X1100 MENU OVERLAY
		echo 'dialog --backtitle "[X1100] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > CHANNEL LIST" --title "CHANNELS" --checklist "Please choose the channels you want to grab:" 15 50 10 \' > /tmp/chmenu
		
		printf "\rLoading channel list..."
		
		grep "<channel id=" ext_file.xml > /tmp/chvalues
		sed -i 's/.*<channel id="//g;s/">//g' /tmp/chvalues
		sort -u /tmp/chvalues > /tmp/chvalues_sorted && mv /tmp/chvalues_sorted /tmp/chvalues
		
		if [ ! -e channels.json ]
		then
			nl /tmp/chvalues > /tmp/chvalues_count
			sed -i 's/\(     \)\([0-9].*\)/[\2/g;s/\(    \)\([0-9].*\)/[\2/g;s/\(   \)\([0-9].*\)/[\2/g;s/[\t]/] /g;s/\&amp;/\&/g' /tmp/chvalues_count
			mv /tmp/chvalues_count /tmp/chvalues
			sed -i 's/.*/"&" "" off \\/g' /tmp/chvalues
			sed -i '$s/.*/&\n2>\/tmp\/chconf/g' /tmp/chvalues
			cat /tmp/chvalues >> /tmp/chmenu
			
			bash /tmp/chmenu
			
			if [ -s /tmp/chconf ]
			then
				sed 's/" "/","/g;s/\\\[[0-9][^]]*\] //g;s/\\(/(/g;s/\\)/)/g;s/.*/{"channels":[&]}/g;s/\\\&/\&amp;/g;s/\\//g' /tmp/chconf > channels.json
				cp /tmp/chlist chlist_old
				dialog --backtitle "[X1110] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list added!\nPlease run the grabber to add the channels to the setup modules!" 7 50
				echo "H" > /tmp/value
			else
				dialog --backtitle "[X1120] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50

				rm settings.json
				rm /tmp/settings_new 2> /dev/null
				exit 0
			fi
		else
			perl compare_menu.pl > /tmp/enabled_chvalues 2> /dev/null
			comm -12 <(sort -u /tmp/enabled_chvalues) <(sort -u /tmp/chvalues) > /tmp/comm_menu_enabled
			comm -2 -3 <(sort -u /tmp/chvalues) <(sort -u /tmp/enabled_chvalues) > /tmp/comm_menu_disabled
			sed -i 's/.*/&" [ON]/g' /tmp/comm_menu_enabled
			sed -i 's/.*/&" [OFF]/g' /tmp/comm_menu_disabled
			cat /tmp/comm_menu_disabled >> /tmp/comm_menu_enabled
			sort /tmp/comm_menu_enabled > /tmp/chvalues
			nl /tmp/chvalues > /tmp/chvalues_count
			sed -i 's/\(     \)\([0-9].*\)/"[\2/g;s/\(    \)\([0-9].*\)/"[\2/g;s/\(   \)\([0-9].*\)/"[\2/g;s/[\t]/] /g;s/\&amp;/\&/g' /tmp/chvalues_count
			mv /tmp/chvalues_count /tmp/chvalues
			sed -i 's/\[ON\]/"" on \\/g;s/\[OFF\]/"" off \\/g' /tmp/chvalues
			sed -i '$s/.*/&\n2>\/tmp\/chconf/g' /tmp/chvalues
			cat /tmp/chvalues >> /tmp/chmenu
			
			bash /tmp/chmenu
			
			if [ -s /tmp/chconf ]
			then
				sed 's/" "/","/g;s/\\\[[0-9][^]]*\] //g;s/\\(/(/g;s/\\)/)/g;s/.*/{"channels":[&]}/g;s/\\\&/\&amp;/g;s/\\//g' /tmp/chconf > channels.json
				dialog --backtitle "[X1130] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list saved!\nPlease run the grabber to add new channels to the setup modules!" 7 50
				cp /tmp/chlist chlist_old
				echo "H" > /tmp/value
			else
				dialog --backtitle "[X1140] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50
				
				echo "H" > /tmp/value
			fi
		fi
		
		
	# ########################
	# X1200 MODIFY FILE PATH #
	# ########################
	
	elif grep -q "2" /tmp/value
	then
		rm /tmp/setupname 2> /dev/null
		
		until [ -s /tmp/setupname ]
		do
			dialog --backtitle "[X1200] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > MODIFY FILE PATH" --title "FILE PATH" --inputbox "\nPlease enter the file path for your setup.\n\nhttp[s]:// - WEB RESOURCE\nfile://    - FILE RESOURCE" 12 45 2> /tmp/setupname
			
			# CHECK IF WEB RESOURCE IS AVAILABLE
			if grep -q -E "http://|https://" /tmp/setupname
			then
				printf "\rLoading XML file from web resource..."
				if ! curl -s -L $(</tmp/setupname) > ext_file
				then
					dialog --backtitle "[X12E1] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > MODIFY FILE PATH" --title "ERROR" --msgbox "Invalid entry or unavailable resource!" 5 50
					rm /tmp/setupname ext_file 2> /dev/null
				else
					cp /tmp/setupname /tmp/settings_new
				fi
				
			# CHECK IF FILE RESOURCE IS AVAILABLE
			elif grep -q "file://" /tmp/setupname
			then
				printf "\rLoading XML file from local resource..."
				sed -i 's/file:\/\///g' /tmp/setupname
				if ! cp $(</tmp/setupname) ext_file 2> /dev/null
				then
					dialog --backtitle "[X12E2] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > MODIFY FILE PATH" --title "ERROR" --msgbox "Invalid entry or unavailable resource!" 5 50
					rm /tmp/setupname ext_file 2> /dev/null
				else
					sed -i 's/.*/file:\/\/&/g' /tmp/setupname
				fi
			elif [ ! -s /tmp/setupname ]
			then
				if [ -e settings.json ]
				then
					echo "H" > /tmp/value
					grep '"path":' settings.json | sed 's/\({"path": "\)\(.*\)"}/\2/g' > /tmp/setupname
				else
					rm /tmp/settings_new 2> /dev/null
					exit 0
				fi
			else
				dialog --backtitle "[X12E3] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > MODIFY FILE PATH" --title "ERROR" --msgbox "Invalid entry detected!" 5 40
				rm /tmp/setupname 2> /dev/null
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
				
				# RENAME TO XML
				if file ext_file | grep -q "XML"
				then
					mv ext_file ext_file.xml
				else
					dialog --backtitle "[X12E4] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > MODIFY FILE PATH" --title "ERROR" --msgbox "Resource isn't a XML file!" 5 40
					rm /tmp/setupname ext_file 2> /dev/null
				fi
				
				# CHECK IF XML FILE IS VALID
				if [ -e ext_file.xml ]
				then
					printf "\rValidating XML file...                  "
					if xmllint --noout ext_file.xml | grep -q "parser error"
					then
						dialog --backtitle "[X12E6] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > MODIFY FILE PATH" --title "ERROR" --msgbox "XML cannot be parsed due to file error!" 5 40
						rm /tmp/setupname ext_file ext_file.xml 2> /dev/null
					fi
				fi
			fi
			
			# SAVE CONFIG	
			if [ -s /tmp/setupname ]
			then
				sed 's/.*/{"path": "&"}/g' /tmp/setupname > settings.json
				echo "H" > /tmp/value
			fi
		done
		
		rm /tmp/setupname
	
	
	# ######################
	# X1300 RUN XML SCRIPT #
	# ######################
	
	elif grep -q "3" /tmp/value
	then
		clear
		
		echo ""
		echo " --------------------------------------------"
		echo " EXTERNAL EPG SIMPLE XMLTV GRABBER            "
		echo "                                             "
		echo " (c) 2019 Jan-Luca Neumann / sunsettrack4    "
		echo " --------------------------------------------"
		echo ""
		sleep 2s
		
		bash ext.sh && cd - > /dev/null
		
		cp ext/oa/external.xml xml/external_oa.xml 2> /dev/null
		cp ext/ob/external.xml xml/external_ob.xml 2> /dev/null
		cp ext/oc/external.xml xml/external_oc.xml 2> /dev/null
		
		cd - > /dev/null
		
		read -n 1 -s -r -p "Press any key to continue..."
		echo "H" > /tmp/value
		
	
	# #######################
	# X1900 DELETE INSTANCE #
	# #######################
	
	elif grep -q "9" /tmp/value
	then
		# X1900 MENU OVERLAY
		dialog --backtitle "[X1900] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > DELETE INSTANCE" --title "WARNING" --yesno "Do you want to delete this service?" 5 50
						
		response=$?
						
		# X1910 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[X1910] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 32
			echo "H" > /tmp/value
						
		# X1920 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[X1920] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service deleted!" 5 30
			rm channels.json settings.json ext_file.xml 2> /dev/null
			echo "M" > /tmp/value
							
		# X19X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[X19X0] EASYEPG SIMPLE XMLTV GRABBER > EXTERNAL SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ############
	# X1X00 EXIT #
	# ############
	
	else
		echo "M" > /tmp/value
	fi
done

rm /tmp/settings_new 2> /dev/null
