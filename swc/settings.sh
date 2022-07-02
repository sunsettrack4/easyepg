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

# ##########################
# S1000 SWISSCOM SETTINGS  #
# ##########################

echo "H" > /tmp/value

while grep -q "H" /tmp/value
do
	# S1000 MENU OVERLAY
	echo 'dialog --backtitle "[S1000] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS" --title "SETTINGS" --menu "Please select the option you want to change:" 14 60 10 \' > /tmp/menu 

	if [ ! -e settings.json ]
	then
		if [ ! -e /tmp/settings_new ]
		then
			# INSERT DEFAULT VALUES
			echo "day=7" > /tmp/settings_new				# grab 7 days by default
			echo "cid=disabled" >> /tmp/settings_new		# do not use Rytec IDs by default
			echo "genre=enabled" >> /tmp/settings_new		# use EIT format for genres by default
			# echo "category=enabled" >> /tmp/settings_new	# insert all categories by default
			echo "episode=xmltv_ns" >> /tmp/settings_new	# use XMLTV_NS format for episodes by default
		fi
	else
		# EXTRACT VALUES FROM JSON FILE
		grep '"day":' settings.json | sed 's/\("day": "\)\(.*\)",/day=\2/g' > /tmp/settings_new
		grep '"cid":' settings.json | sed 's/\("cid": "\)\(.*\)",/cid=\2/g' >> /tmp/settings_new
		grep '"genre":' settings.json | sed 's/\("genre": "\)\(.*\)",/genre=\2/g' >> /tmp/settings_new
		# grep '"category":' settings.json | sed 's/\("category": "\)\(.*\)",/category=\2/g' >> /tmp/settings_new
		grep '"episode":' settings.json | sed 's/\("episode": "\)\(.*\)",/episode=\2/g' >> /tmp/settings_new
	fi
	
	# S1100 CHANNEL LIST
	echo '	1 "MODIFY CHANNEL LIST" \' >> /tmp/menu

	# S1200 TIME PERIOD
	if grep -q "day=10" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 10 days)" \' >> /tmp/menu
	elif grep -q "day=11" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 11 days)" \' >> /tmp/menu 
	elif grep -q "day=12" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 12 days)" \' >> /tmp/menu
	elif grep -q "day=13" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 13 days)" \' >> /tmp/menu
	elif grep -q "day=14" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 14 days)" \' >> /tmp/menu
	elif grep -q "day=1" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 1 day)" \' >> /tmp/menu
	elif grep -q "day=2" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 2 days)" \' >> /tmp/menu 
	elif grep -q "day=3" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 3 days)" \' >> /tmp/menu 
	elif grep -q "day=4" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 4 days)" \' >> /tmp/menu 
	elif grep -q "day=5" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 5 days)" \' >> /tmp/menu 
	elif grep -q "day=6" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 6 days)" \' >> /tmp/menu 
	elif grep -q "day=7" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 7 days)" \' >> /tmp/menu 
	elif grep -q "day=8" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 8 days)" \' >> /tmp/menu 
	elif grep -q "day=9" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: 9 days)" \' >> /tmp/menu 
	elif grep -q "day=0" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: disabled)" \' >> /tmp/menu 
	fi
		
	# S1300 CONVERT CHANNEL IDs
	if grep -q "cid=enabled" /tmp/settings_new
	then
		echo '	3 "CONVERT CHANNEL IDs INTO RYTEC FORMAT (enabled)" \' >> /tmp/menu 
	elif grep -q "cid=disabled" /tmp/settings_new
	then
		echo '	3 "CONVERT CHANNEL IDs INTO RYTEC FORMAT (disabled)" \' >> /tmp/menu 
	fi

	# S1400 CONVERT CATEGORIES
	# if grep -q "genre=enabled" /tmp/settings_new
	# then
	#	echo '	4 "CONVERT CATEGORIES INTO EIT FORMAT (enabled)" \' >> /tmp/menu 
	# elif grep -q "genre=disabled" /tmp/settings_new
	# then
	#	echo '	4 "CONVERT CATEGORIES INTO EIT FORMAT (disabled)" \' >> /tmp/menu 
	# fi

	# S1500 MULTIPLE CATEGORIES
	# if grep -q "category=enabled" /tmp/settings_new
	# then
	#	echo '	5 "USE MULTIPLE CATEGORIES (enabled)" \' >> /tmp/menu 
	# elif grep -q "category=disabled" /tmp/settings_new
	# then
	#	echo '	5 "USE MULTIPLE CATEGORIES (disabled)" \' >> /tmp/menu 
	# fi

	# S1600 EPISODE FORMAT
	if grep -q "episode=xmltv_ns" /tmp/settings_new
	then
		echo '	6 "EPISODE FORMAT (currently: xmltv_ns)" \' >> /tmp/menu
	elif grep -q "episode=onscreen" /tmp/settings_new
	then
		echo '	6 "EPISODE FORMAT (currently: onscreen)" \' >> /tmp/menu
	fi
	
	# S1700 RUN XML SCRIPT
	echo '	7 "RUN XML SCRIPT" \' >> /tmp/menu
	
	# S1900 DELETE INSTANCE
	echo '	9 "REMOVE GRABBER INSTANCE" \' >> /tmp/menu
	
	echo "2> /tmp/value" >> /tmp/menu
	
	if [ ! -e channels.json ]
	then
		echo "1" > /tmp/value
	else
		sed -i "s/\[X\]/[$COUNTRY]/g" /tmp/menu
		bash /tmp/menu
		input="$(cat /tmp/value)"
	fi


	# ####################
	# S1100 CHANNEL LIST #
	# ####################
	
	if grep -q "1" /tmp/value
	then
		# S1100 MENU OVERLAY
		echo 'dialog --backtitle "[S1100] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CHANNEL LIST" --title "CHANNELS" --checklist "Please choose the channels you want to grab:" 15 50 10 \' > /tmp/chmenu
		
		printf "\rFetching channel list... "
		
		if ! curl --write-out %{http_code} --silent --output /dev/null https://tv.blue.ch/tv-guide | grep -q "200"
		then
			printf "\rService provider unavailable!"
			sleep 2s
			exit 0
		fi

		curl -s https://services.sg101.prd.sctv.ch/portfolio/tv/channels > /tmp/chlist
		jq '.' /tmp/chlist > /tmp/workfile
		sed '1s/\[/{"attributes":[/g;$s/\]/]}/g' /tmp/workfile > /tmp/chlist

		printf "\rLoading channel configuration..."
		perl cid_json.pl > /tmp/chvalues
		sed -i '/{/d;/}/d;s/.*":"//g;s/",//g;/DUMMY/d' /tmp/chvalues
		sort -u /tmp/chvalues > /tmp/chvalues_sorted && mv /tmp/chvalues_sorted /tmp/chvalues

		if [ ! -e channels.json ]
		then
			nl /tmp/chvalues > /tmp/chvalues_count
			sed -i 's/\(     \)\([0-9].*\)/[\2/g;s/\(    \)\([0-9].*\)/[\2/g;s/\(   \)\([0-9].*\)/[\2/g;s/[\t]/] /g;s/\&amp;/\&/g' /tmp/chvalues_count
			mv /tmp/chvalues_count /tmp/chvalues
			sed -i 's/.*/"&" "" off \\/g' /tmp/chvalues
			sed -i '$s/.*/&\n2>\/tmp\/chconf/g' /tmp/chvalues
			cat /tmp/chvalues >> /tmp/chmenu
				
			sed -i "s/\[X\]/[$COUNTRY]/g" /tmp/chmenu
			bash /tmp/chmenu
				
			if [ -s /tmp/chconf ]
			then
				sed 's/" "/","/g;s/\\\[[0-9][^]]*\] //g;s/\\(/(/g;s/\\)/)/g;s/.*/{"channels":[&]}/g;s/\\\&/\&amp;/g;s/\\//g' /tmp/chconf > channels.json
				cp /tmp/chlist chlist_old
				dialog --backtitle "[S1110] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list added!\nPlease run the grabber to add the channels to the setup modules!" 7 50
				echo "H" > /tmp/value
			else
				dialog --backtitle "[S1120] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50
				echo "M" > /tmp/value
				exit 1
			fi
		else
			perl chlist_printer.pl > /tmp/compare.json
			perl compare_menu.pl > /tmp/enabled_chvalues 2>errors.txt

			sort -u errors.txt > /tmp/errors_sorted.txt && mv /tmp/errors_sorted.txt errors.txt

			if [ -s errors.txt ]
			then
				clear
				echo ""
				echo "================= CHANNEL LIST: LOG ==================="
				echo ""
				echo "NOTICE: Channels with ERROR messages are unselected automatically."
				echo ""

				input="errors.txt"
				while IFS= read -r var
				do
					echo "$var"
				done < "$input"

				echo ""
				echo "======================================================="
				echo ""
				read -n 1 -s -r -p "Press any key to continue..."

			else
				rm errors.txt 2> /dev/null
			fi
			
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
			
			sed -i "s/\[X\]/[$COUNTRY]/g" /tmp/chmenu
			bash /tmp/chmenu
				
			if [ -s /tmp/chconf ]
			then
				sed 's/" "/","/g;s/\\\[[0-9][^]]*\] //g;s/\\(/(/g;s/\\)/)/g;s/.*/{"channels":[&]}/g;s/\\\&/\&amp;/g;s/\\//g' /tmp/chconf > channels.json
				dialog --backtitle "[S1130] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list saved!\nPlease run the grabber to add new channels to the setup modules!" 7 50
				cp /tmp/chlist chlist_old
				echo "H" > /tmp/value
			else
				dialog --backtitle "[S1140] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50
				echo "H" > /tmp/value
			fi
		fi
	
	
	# ###################
	# S1200 TIME PERIOD #
	# ###################
	
	elif grep -q "2" /tmp/value
	then
		echo "X" > /tmp/value
		
		while grep -q "X" /tmp/value
		do
			# S1200 MENU OVERLAY
			dialog --backtitle "[S1200] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > TIME PERIOD" --title "EPG GRABBER" --inputbox "Please enter the number of days you want to retrieve the EPG information. (0=disable | 1-14=enable)" 10 46 2>/tmp/value
							
			sed -i 's/.*/epg&-/g' /tmp/value
			
			# S1210 INPUT: DISABLED
			if grep -q "epg0-" /tmp/value
			then
				sed -i '/day=/d' /tmp/settings_new
				echo "day=0" >> /tmp/settings_new
				dialog --backtitle "[S1210] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber disabled!" 5 26 
				echo "H" > /tmp/value
			
			# S1220 INPUT: 1 DAY
			elif grep -q "epg1-" /tmp/value
			then
				sed -i '/day=/d' /tmp/settings_new
				echo "day=1" >> /tmp/settings_new
				dialog --backtitle "[S1220] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber is enabled for 1 day!" 5 42
				echo "H" > /tmp/value
				
			# S1230 INPUT: 2-9 DAYS
			elif grep -q "epg[2-9]-" /tmp/value
			then
				sed -i 's/epg//g;s/-//g' /tmp/value
				sed -i '/day=/d' /tmp/settings_new
				echo "day=$(</tmp/value)" >> /tmp/settings_new
				dialog --backtitle "[S1230] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber is enabled for $(</tmp/value) days!" 5 42
				echo "H" > /tmp/value
			
			# S1240 INPUT: 10-14 DAYS
			elif grep -q "epg1[0-4]-" /tmp/value
			then
				sed -i 's/epg//g;s/-//g' /tmp/value
				sed -i '/day=/d' /tmp/settings_new
				echo "day=$(</tmp/value)" >> /tmp/settings_new
				dialog --backtitle "[S1240] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber is enabled for $(</tmp/value) days!" 5 42
				echo "H" > /tmp/value
			
			# S1250 WRONG INPUT
			elif [ -s /tmp/value ]
			then
				dialog --backtitle "[S1250] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > TIME PERIOD" --title "ERROR" --msgbox "Wrong input detected!" 5 30 
				echo "X" > /tmp/value
			
			# S12X0 EXIT
			else
				echo "H" > /tmp/value
			fi
		done
		
		
	# ###########################
	# S1300 CONVERT CHANNEL IDs #
	# ###########################
	
	elif grep -q "3" /tmp/value
	then
		# S1300 MENU OVERLAY
		dialog --backtitle "[S1300] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CHANNEL IDs" --title "CHANNEL IDs" --yesno "Do you want to use the Rytec ID format?\n\nRytec ID example: ChannelNameHD.de\nUsual ID example: Channel Name HD" 8 55
						
		response=$?
						
		# S1310 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[S1310] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CHANNEL IDs" --title "INFO" --msgbox "Rytec Channel IDs disabled!" 5 32
			sed -i '/cid=/d' /tmp/settings_new
			echo "cid=disabled" >> /tmp/settings_new
			echo "H" > /tmp/value
						
		# S1320 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[S1320] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CHANNEL IDs" --title "INFO" --msgbox "Rytec Channel IDs enabled!" 5 30
			sed -i '/cid=/d' /tmp/settings_new
			echo "cid=enabled" >> /tmp/settings_new
			echo "H" > /tmp/value
							
		# S13X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[S13X0] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CHANNEL IDs" --title "INFO" --msgbox "No changes applied!" 5 30
			echo "H" > /tmp/value
		fi

	
	# ###########################
	# S1400 CONVERT CATEGORIES  #
	# ###########################
	
	elif grep -q "4" /tmp/value
	then
		# S1400 MENU OVERLAY
		dialog --backtitle "[S1400] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CATEGORIES" --title "CATEGORIES" --yesno "Do you want to use the EIT format for tvHeadend?" 5 55
						
		response=$?
						
		# S1410 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[S1410] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "EIT categories disabled!" 5 32
			sed -i '/genre=/d' /tmp/settings_new
			echo "genre=disabled" >> /tmp/settings_new
			echo "H" > /tmp/value
						
		# S1420 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[S1420] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "EIT categories enabled!" 5 30
			sed -i '/genre=/d' /tmp/settings_new
			echo "genre=enabled" >> /tmp/settings_new
			echo "H" > /tmp/value
							
		# S14X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[S14X0] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "No changes applied!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ###########################
	# S1500 MULTIPLE CATEGORIES #
	# ###########################
	
	elif grep -q "5" /tmp/value
	then
		# S1500 MENU OVERLAY
		dialog --backtitle "[S1500] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > MULTIPLE CATEGORIES" --title "MULTIPLE CATEGORIES" --yesno "Do you want to use multiple categories for tvHeadend?" 5 60
						
		response=$?
						
		# S1510 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[S1510] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > MULTIPLE CATEGORIES" --title "INFO" --msgbox "Multiple categories disabled!" 5 35
			sed -i '/category=/d' /tmp/settings_new
			echo "category=disabled" >> /tmp/settings_new
			echo "H" > /tmp/value
						
		# S1520 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[S1520] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > MULTIPLE CATEGORIES" --title "INFO" --msgbox "Multiple categories enabled!" 5 35
			sed -i '/category=/d' /tmp/settings_new
			echo "category=enabled" >> /tmp/settings_new
			echo "H" > /tmp/value
							
		# S15X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[S15X0] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > MULTIPLE CATEGORIES" --title "INFO" --msgbox "No changes applied!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ######################
	# S1600 EPISODE FORMAT #
	# ######################
	
	elif grep -q "6" /tmp/value
	then
		# S1600 MENU OVERLAY
		dialog --backtitle "[S1600] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > EPISODE FORMAT" --title "EPISODE" --menu "Please select the format you want to use.\n\nonscreen: move the episode data into the broadcast description\nxmltv_ns: episode data to be parsed by tvHeadend" 14 60 10 \
		1	"ONSCREEN" \
		2	"XMLTV_NS" \
		2>/tmp/value
		
		# S1610 ONSCREEN
		if grep -q "1" /tmp/value
		then
			dialog --backtitle "[S1610] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > EPISODE FORMAT" --title "INFO" --msgbox "Episode format 'onscreen' enabled!" 5 40
			sed -i '/episode=/d' /tmp/settings_new
			echo "episode=onscreen" >> /tmp/settings_new
			echo "H" > /tmp/value
		
		# S1620 XMLTV_NS
		elif grep -q "2" /tmp/value
		then
			dialog --backtitle "[S1620] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > EPISODE FORMAT" --title "INFO" --msgbox "Episode format 'xmltv_ns' enabled!" 5 40
			sed -i '/episode=/d' /tmp/settings_new
			echo "episode=xmltv_ns" >> /tmp/settings_new
			echo "H" > /tmp/value
		
		# S16X0 EXIT
		else
			echo "H" > /tmp/value
		fi
	
	
	# ######################
	# S1700 RUN XML SCRIPT #
	# ######################
	
	elif grep -q "7" /tmp/value
	then
		clear
		
		echo ""
		echo " --------------------------------------------"
		echo " SWISSCOM EPG SIMPLE XMLTV GRABBER           "
		echo " powered by easyEPG Grabber $(grep 'VER=' /tmp/initrun.txt | sed 's/VER=//g')"
		echo " (c) 2019-2020 Jan-Luca Neumann / sunsettrack4    "
		echo " --------------------------------------------"
		echo ""
		sleep 2s
		
		cd $(pwd)
		bash swc.sh && cd $(grep 'DIR=' /tmp/initrun.txt | sed 's/DIR=//g') > /dev/null
		
		cp swc/ch/swisscom.xml xml/swisscom_ch.xml 2> /dev/null
		
		cd - > /dev/null
		
		read -n 1 -s -r -p "Press any key to continue..."
		echo "H" > /tmp/value
		
	
	# #######################
	# S1900 DELETE INSTANCE #
	# #######################
	
	elif grep -q "9" /tmp/value
	then
		# S1900 MENU OVERLAY
		dialog --backtitle "[S1900] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > DELETE INSTANCE" --title "WARNING" --yesno "Do you want to delete this service?" 5 50
						
		response=$?
						
		# S1910 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[S1910] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 32
			echo "H" > /tmp/value
						
		# S1920 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[S1920] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service deleted!" 5 30
			rm channels.json
			echo "M" > /tmp/value
							
		# S19X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[S19X0] EASYEPG SIMPLE XMLTV GRABBER > SWISSCOM SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ############
	# S1X00 EXIT #
	# ############
	
	else
		echo "M" > /tmp/value
	fi

sed -i 's/.*/"&",/g' /tmp/settings_new
sed -i 's/=/": "/g' /tmp/settings_new
sed -i '1i{ "settings": {' /tmp/settings_new
sed '$s/.*/&\n"settings": "true" }\n}/g' /tmp/settings_new > settings.json
rm /tmp/settings_new

done
