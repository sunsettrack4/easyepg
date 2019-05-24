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

# ####################
# CHECK AVAILABILITY #
# ####################

printf "\rChecking service availability..."

export QT_QPA_PLATFORM=offscreen

if ! curl --write-out %{http_code} --silent --output /dev/null https://www.waipu.tv/ | grep -q "200"
then
	printf "\rService provider unavailable!"
	sleep 2s
	exit 0
fi


# ######################################
# RETRIEVE USER DATA / LOGIN TO ZATTOO #
# ######################################

rm /tmp/login.txt 2> /dev/null

until grep -q '"access_token"' /tmp/login.txt 2> /dev/null
do
	if grep -q -E "login|password" user/userfile 2> /dev/null
	then true
	else
		mkdir user 2> /dev/null
		touch user/userfile
		
		#
		# ENTER EMAIL ADDRESS
		#
		
		until grep -q '[A-Za-z0-9]@.*[A-Za-z0-9].*[.][a-z][a-z]' user/userfile
		do
			sed -i '/login/d' user/userfile
			
			login=$(dialog --backtitle "[W1000] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV > LOGIN" --title "WAIPU.TV | LOGIN PAGE" --inputbox "\nPlease enter your email address:" 8 50 3>&1 1>&2 2>&3 3>&-)
			
			if test $? -eq 0
			then 
				echo "username=$login" >> user/userfile
			else
				exit 1
			fi
			
			until grep -q '[A-Za-z0-9]@.*[A-Za-z0-9].*[.][a-z][a-z]' user/userfile
			do
				sed -i '/login/d' user/userfile
				
				login=$(dialog --backtitle "[W1E00] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV > LOGIN" --title "WAIPU.TV | LOGIN PAGE" --inputbox "EMAIL invalid! | Syntax: name@domain.xxx\nPlease enter your email address:" 8 50 3>&1 1>&2 2>&3 3>&-)
				
				if test $? -eq 0
				then 
					echo "username=$login" >> user/userfile
				else
					exit 1
				fi
			done
		done
		
		#
		# ENTER PASSWORD
		#
		
		password=$(dialog --backtitle "[W2000] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV > LOGIN" --title "WAIPU.TV | LOGIN PAGE" --passwordbox "EMAIL: $login \nPlease enter your password:" 8 50 3>&1 1>&2 2>&3 3>&-)
		
		if test $? -eq 0
		then 
			echo "password=$password" >> user/userfile
		else
			echo "DUMMY" > checkfile
		fi
		
		if [ ! -e checkfile ]
		then
			grep "password=" user/userfile > checkfile
			sed -i "s/password=//g" checkfile
		fi
		
		until grep -q "[:punct:A-Za-z0-9]" checkfile
		do
			sed -i '/password/d' user/userfile
			
			password=$(dialog --backtitle "[W2E00] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV > LOGIN" --title "WAIPU.TV | LOGIN PAGE" --passwordbox "EMAIL: $login \nNo input detected! Please enter your password:" 8 50 3>&1 1>&2 2>&3 3>&-)
			
			if test $? -eq 0
			then 
				echo "password=$password" >> user/userfile
				grep "password=" user/userfile > checkfile
				sed -i "s/password=//g" checkfile
			else
				echo "DUMMY" > checkfile
			fi
		done
			
		rm checkfile
	fi 

	printf "\rLogin to waipu.tv webservice..."

	curl -i -s -X POST -H "User-Agent: WAIPU_USER_AGENT" -H "Authorization: Basic YW5kcm9pZENsaWVudDpzdXBlclNlY3JldA==" -H "Content-Type: application/x-www-form-urlencoded" -v --data-urlencode "$(sed '2d' user/userfile)" --data-urlencode "$(sed '1d' user/userfile)" --data-urlencode "grant_type=password" https://auth.waipu.tv/oauth/token > /tmp/login.txt 2> /dev/null

	if grep -q '"access_token"' /tmp/login.txt
	then
		grep '"access_token"' /tmp/login.txt | jq -r '.access_token' > user/session
		session=$(curl -s -X POST -H "User-Agent: WAIPU_USER_AGENT" -H "Authorization: Bearer $(<user/session)" -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "$(sed '2d' user/userfile)" --data-urlencode "$(sed '1d' user/userfile)" --data-urlencode "grant_type=password" https://auth.waipu.tv/oauth/token 2>/dev/null | jq -r '.access_token')
	else
		rm -rf user/userfile
		printf "\rLogin to waipu.tv webservice... FAILED!"
		sleep 2s
	fi
done

rm /tmp/settings_new 2> /dev/null

# ########################
# W3000 WAIPU.TV SETTINGS  #
# ########################

echo "H" > /tmp/value

while grep -q "H" /tmp/value
do
	# W3000 MENU OVERLAY
	echo 'dialog --backtitle "[W3000] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS" --title "SETTINGS" --menu "Please select the option you want to change:" 14 60 10 \' > /tmp/menu 

	if [ ! -e settings.json ]
	then
		if [ ! -e /tmp/settings_new ]
		then
			# INSERT DEFAULT VALUES
			echo "day=7" > /tmp/settings_new				# grab 7 days by default
			echo "cid=disabled" >> /tmp/settings_new		# do not use Rytec IDs by default
			echo "genre=enabled" >> /tmp/settings_new		# use EIT format for genres by default
			echo "category=enabled" >> /tmp/settings_new	# insert all categories by default
			echo "episode=xmltv_ns" >> /tmp/settings_new	# use XMLTV_NS format for episodes by default
		fi
	else
		# EXTRACT VALUES FROM JSON FILE
		grep '"day":' settings.json | sed 's/\("day": "\)\(.*\)",/day=\2/g' > /tmp/settings_new
		grep '"cid":' settings.json | sed 's/\("cid": "\)\(.*\)",/cid=\2/g' >> /tmp/settings_new
		grep '"genre":' settings.json | sed 's/\("genre": "\)\(.*\)",/genre=\2/g' >> /tmp/settings_new
		grep '"category":' settings.json | sed 's/\("category": "\)\(.*\)",/category=\2/g' >> /tmp/settings_new
		grep '"episode":' settings.json | sed 's/\("episode": "\)\(.*\)",/episode=\2/g' >> /tmp/settings_new
	fi
	
	# W3100 CHANNEL LIST
	echo '	1 "MODIFY CHANNEL LIST" \' >> /tmp/menu

	# W3200 TIME PERIOD
	if grep -q "day=1" /tmp/settings_new
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
	fi
		
	# W3300 CONVERT CHANNEL IDs
	if grep -q "cid=enabled" /tmp/settings_new
	then
		echo '	3 "CONVERT CHANNEL IDs INTO RYTEC FORMAT (enabled)" \' >> /tmp/menu 
	elif grep -q "cid=disabled" /tmp/settings_new
	then
		echo '	3 "CONVERT CHANNEL IDs INTO RYTEC FORMAT (disabled)" \' >> /tmp/menu 
	fi

	# W3400 CONVERT CATEGORIES
	if grep -q "genre=enabled" /tmp/settings_new
	then
		echo '	4 "CONVERT CATEGORIES INTO EIT FORMAT (enabled)" \' >> /tmp/menu 
	elif grep -q "genre=disabled" /tmp/settings_new
	then
		echo '	4 "CONVERT CATEGORIES INTO EIT FORMAT (disabled)" \' >> /tmp/menu 
	fi

	# W3500 MULTIPLE CATEGORIES
	# if grep -q "category=enabled" /tmp/settings_new
	# then
	#	echo '	5 "USE MULTIPLE CATEGORIES (enabled)" \' >> /tmp/menu 
	# elif grep -q "category=disabled" /tmp/settings_new
	# then
	#	echo '	5 "USE MULTIPLE CATEGORIES (disabled)" \' >> /tmp/menu 
	# fi

	# W3600 EPISODE FORMAT
	if grep -q "episode=xmltv_ns" /tmp/settings_new
	then
		echo '	6 "EPISODE FORMAT (currently: xmltv_ns)" \' >> /tmp/menu
	elif grep -q "episode=onscreen" /tmp/settings_new
	then
		echo '	6 "EPISODE FORMAT (currently: onscreen)" \' >> /tmp/menu
	fi
	
	# W3700 RUN XML SCRIPT
	echo '	7 "RUN XML SCRIPT" \' >> /tmp/menu
	
	# W3900 DELETE INSTANCE
	echo '	9 "REMOVE GRABBER INSTANCE" \' >> /tmp/menu
	
	echo "2> /tmp/value" >> /tmp/menu
	
	if [ ! -e channels.json ]
	then
		echo "1" > /tmp/value
	else
		bash /tmp/menu
		input="$(cat /tmp/value)"
	fi


	# ####################
	# W3100 CHANNEL LIST #
	# ####################
	
	if grep -q "1" /tmp/value
	then
		# Z3100 MENU OVERLAY
		echo 'dialog --backtitle "[W3100] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CHANNEL LIST" --title "CHANNELS" --checklist "Please choose the channels you want to grab:" 15 50 10 \' > /tmp/chmenu
		
		printf "\rFetching channel list...               "

		date1=$(date '+%Y-%m-%d')
		rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
		curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T00:00:00&stopTime='"$date1"'T00:00:01' > /tmp/chlist.gz
		
		if ! gzip -d /tmp/chlist.gz 2> /dev/null
		then
			mv /tmp/chlist.gz /tmp/chlist
		fi
		
		sed -i 's/.*/{"attributes":&}/g' /tmp/chlist && jq '.' /tmp/chlist > chlist

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
			
			bash /tmp/chmenu
			
			if [ -s /tmp/chconf ]
			then
				sed 's/" "/","/g;s/\\\[[0-9][^]]*\] //g;s/\\(/(/g;s/\\)/)/g;s/.*/{"channels":[&]}/g;s/\\\&/\&amp;/g;s/\\//g' /tmp/chconf > channels.json
				cp /tmp/chlist chlist_old
				dialog --backtitle "[W3110] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list added!\nPlease run the grabber to add the channels to the setup modules!" 7 50
				echo "H" > /tmp/value
			else
				dialog --backtitle "[W3120] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50
				echo "M" > /tmp/value
				exit 1
			fi
		else
			perl chlist_printer.pl > /tmp/compare.json
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
				dialog --backtitle "[W3130] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list saved!\nPlease run the grabber to add new channels to the setup modules!" 7 50
				cp /tmp/chlist chlist_old
				echo "H" > /tmp/value
			else
				dialog --backtitle "[W3140] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50
				echo "H" > /tmp/value
			fi
		fi
		
		
	# ###################
	# W3200 TIME PERIOD #
	# ###################
	
	elif grep -q "2" /tmp/value
	then
		echo "X" > /tmp/value
		
		while grep -q "X" /tmp/value
		do
			# W3200 MENU OVERLAY
			dialog --backtitle "[W3200] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > TIME PERIOD" --title "EPG GRABBER" --inputbox "Please enter the number of days you want to retrieve the EPG information. (0=disable | 1-7=enable)" 10 46 2>/tmp/value
							
			sed -i 's/.*/epg&-/g' /tmp/value
			
			# W3210 INPUT: DISABLED
			if grep -q "epg0-" /tmp/value
			then
				sed -i '/day=/d' /tmp/settings_new
				echo "day=0" >> /tmp/settings_new
				dialog --backtitle "[W3210] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber disabled!" 5 26 
				echo "H" > /tmp/value
			
			# W3220 INPUT: 1 DAY
			elif grep -q "epg1-" /tmp/value
			then
				sed -i '/day=/d' /tmp/settings_new
				echo "day=1" >> /tmp/settings_new
				dialog --backtitle "[W3220] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber is enabled for 1 day!" 5 42
				echo "H" > /tmp/value
				
			# W3230 INPUT: 2-7 DAYS
			elif grep -q "epg[2-7]-" /tmp/value
			then
				sed -i 's/epg//g;s/-//g' /tmp/value
				sed -i '/day=/d' /tmp/settings_new
				echo "day=$(</tmp/value)" >> /tmp/settings_new
				dialog --backtitle "[W3230] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber is enabled for $(</tmp/value) days!" 5 42
				echo "H" > /tmp/value
			
			# W3240 WRONG INPUT
			elif [ -s /tmp/value ]
			then
				dialog --backtitle "[Z3240] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > TIME PERIOD" --title "ERROR" --msgbox "Wrong input detected!" 5 30 
				echo "X" > /tmp/value
			
			# W32X0 EXIT
			else
				echo "H" > /tmp/value
			fi
		done
		
		
	# ###########################
	# W3300 CONVERT CHANNEL IDs #
	# ###########################
	
	elif grep -q "3" /tmp/value
	then
		# W3300 MENU OVERLAY
		dialog --backtitle "[W3300] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CHANNEL IDs" --title "CHANNEL IDs" --yesno "Do you want to use the Rytec ID format?\n\nRytec ID example: ChannelNameHD.de\nUsual ID example: Channel Name HD" 8 55
						
		response=$?
						
		# W3310 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[Z3310] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CHANNEL IDs" --title "INFO" --msgbox "Rytec Channel IDs disabled!" 5 32
			sed -i '/cid=/d' /tmp/settings_new
			echo "cid=disabled" >> /tmp/settings_new
			echo "H" > /tmp/value
						
		# W3320 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[W3320] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CHANNEL IDs" --title "INFO" --msgbox "Rytec Channel IDs enabled!" 5 30
			sed -i '/cid=/d' /tmp/settings_new
			echo "cid=enabled" >> /tmp/settings_new
			echo "H" > /tmp/value
							
		# W33X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[W33X0] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CHANNEL IDs" --title "INFO" --msgbox "No changes applied!" 5 30
			echo "H" > /tmp/value
		fi

	
	# ###########################
	# W3400 CONVERT CATEGORIES  #
	# ###########################
	
	elif grep -q "4" /tmp/value
	then
		# W3400 MENU OVERLAY
		dialog --backtitle "[Z3400] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CATEGORIES" --title "CATEGORIES" --yesno "Do you want to use the EIT format for tvHeadend?" 5 55
						
		response=$?
						
		# W3410 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[W3410] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "EIT categories disabled!" 5 32
			sed -i '/genre=/d' /tmp/settings_new
			echo "genre=disabled" >> /tmp/settings_new
			echo "H" > /tmp/value
						
		# W3420 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[W3420] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "EIT categories enabled!" 5 30
			sed -i '/genre=/d' /tmp/settings_new
			echo "genre=enabled" >> /tmp/settings_new
			echo "H" > /tmp/value
							
		# W34X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[W34X0] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "No changes applied!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ###########################
	# W3500 MULTIPLE CATEGORIES #
	# ###########################
	
	elif grep -q "5" /tmp/value
	then
		# W3500 MENU OVERLAY
		dialog --backtitle "[W3500] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > MULTIPLE CATEGORIES" --title "MULTIPLE CATEGORIES" --yesno "Do you want to use multiple categories for tvHeadend?" 5 60
						
		response=$?
						
		# W3510 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[W3510] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > MULTIPLE CATEGORIES" --title "INFO" --msgbox "Multiple categories disabled!" 5 35
			sed -i '/category=/d' /tmp/settings_new
			echo "category=disabled" >> /tmp/settings_new
			echo "H" > /tmp/value
						
		# W3520 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[W3520] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > MULTIPLE CATEGORIES" --title "INFO" --msgbox "Multiple categories enabled!" 5 35
			sed -i '/category=/d' /tmp/settings_new
			echo "category=enabled" >> /tmp/settings_new
			echo "H" > /tmp/value
							
		# W35X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[W35X0] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > MULTIPLE CATEGORIES" --title "INFO" --msgbox "No changes applied!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ######################
	# W3600 EPISODE FORMAT #
	# ######################
	
	elif grep -q "6" /tmp/value
	then
		# W3600 MENU OVERLAY
		dialog --backtitle "[W3600] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > EPISODE FORMAT" --title "EPISODE" --menu "Please select the format you want to use.\n\nonscreen: move the episode data into the broadcast description\nxmltv_ns: episode data to be parsed by tvHeadend" 14 60 10 \
		1	"ONSCREEN" \
		2	"XMLTV_NS" \
		2>/tmp/value
		
		# W3610 ONSCREEN
		if grep -q "1" /tmp/value
		then
			dialog --backtitle "[W3610] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > EPISODE FORMAT" --title "INFO" --msgbox "Episode format 'onscreen' enabled!" 5 40
			sed -i '/episode=/d' /tmp/settings_new
			echo "episode=onscreen" >> /tmp/settings_new
			echo "H" > /tmp/value
		
		# W3620 XMLTV_NS
		elif grep -q "2" /tmp/value
		then
			dialog --backtitle "[W3620] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > EPISODE FORMAT" --title "INFO" --msgbox "Episode format 'xmltv_ns' enabled!" 5 40
			sed -i '/episode=/d' /tmp/settings_new
			echo "episode=xmltv_ns" >> /tmp/settings_new
			echo "H" > /tmp/value
		
		# W36X0 EXIT
		else
			echo "H" > /tmp/value
		fi
	
	
	# ######################
	# W3700 RUN XML SCRIPT #
	# ######################
	
	elif grep -q "7" /tmp/value
	then
		clear
		
		echo ""
		echo " --------------------------------------------"
		echo " WAIPU.TV EPG SIMPLE XMLTV GRABBER           "
		echo "                                             "
		echo " (c) 2019 Jan-Luca Neumann / sunsettrack4    "
		echo " --------------------------------------------"
		echo ""
		sleep 2s
		
		bash wpu.sh && cd - > /dev/null
		
		cp wpu/de/waipu.xml xml/waipu_de.xml 2> /dev/null
		
		cd - > /dev/null
		
		read -n 1 -s -r -p "Press any key to continue..."
		echo "H" > /tmp/value
		
	
	# #######################
	# W3900 DELETE INSTANCE #
	# #######################
	
	elif grep -q "9" /tmp/value
	then
		# W3900 MENU OVERLAY
		dialog --backtitle "[W3900] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > DELETE INSTANCE" --title "WARNING" --yesno "Do you want to delete this service?" 5 50
						
		response=$?
						
		# W3910 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[W3910] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 32
			echo "H" > /tmp/value
						
		# W3920 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[W3920] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service deleted!" 5 30
			rm channels.json
			echo "M" > /tmp/value
							
		# W39X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[W39X0] EASYEPG SIMPLE XMLTV GRABBER > WAIPU.TV SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ############
	# W3X00 EXIT #
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
