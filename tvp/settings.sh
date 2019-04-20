#!/bin/bash

#      Copyright (C) 2019 Jan-Luca Neumann
#      https://github.com/sunsettrack4/easyepg/hzn
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

# SETTINGS MENU

# ################
# INITIALIZATION #
# ################

rm /tmp/settings_new 2> /dev/null

# #########################
# T1000 TVPLAYER SETTINGS #
# #########################

echo "H" > /tmp/value

while grep -q "H" /tmp/value
do
	# T1000 MENU OVERLAY
	echo 'dialog --backtitle "[T1000] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS" --title "SETTINGS" --menu "Please select the option you want to change:" 14 60 10 \' > /tmp/menu 

	if [ ! -e settings.json ]
	then
		if [ ! -e /tmp/settings_new ]
		then
			# INSERT DEFAULT VALUES
			echo "day=7" > /tmp/settings_new				# grab 7 days by default
			echo "cid=enabled" >> /tmp/settings_new			# use Rytec IDs by default
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
	
	# T1100 CHANNEL LIST
	echo '	1 "MODIFY CHANNEL LIST" \' >> /tmp/menu

	# T1200 TIME PERIOD
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
	elif grep -q "day=0" /tmp/settings_new
	then
		echo '	2 "TIME PERIOD (currently: disabled)" \' >> /tmp/menu 
	fi
		
	# T1300 CONVERT CHANNEL IDs
	# if grep -q "cid=enabled" /tmp/settings_new
	# then
	#	echo '	3 "CONVERT CHANNEL IDs INTO RYTEC FORMAT (enabled)" \' >> /tmp/menu 
	# elif grep -q "cid=disabled" /tmp/settings_new
	# then
	#	echo '	3 "CONVERT CHANNEL IDs INTO RYTEC FORMAT (disabled)" \' >> /tmp/menu 
	# fi

	# T1400 CONVERT CATEGORIES
	if grep -q "genre=enabled" /tmp/settings_new
	then
		echo '	4 "CONVERT CATEGORIES INTO EIT FORMAT (enabled)" \' >> /tmp/menu 
	elif grep -q "genre=disabled" /tmp/settings_new
	then
		echo '	4 "CONVERT CATEGORIES INTO EIT FORMAT (disabled)" \' >> /tmp/menu 
	fi

	# T1500 MULTIPLE CATEGORIES
	# if grep -q "category=enabled" /tmp/settings_new
	# then
	#	echo '	5 "USE MULTIPLE CATEGORIES (enabled)" \' >> /tmp/menu 
	# elif grep -q "category=disabled" /tmp/settings_new
	# then
	#	echo '	5 "USE MULTIPLE CATEGORIES (disabled)" \' >> /tmp/menu 
	# fi

	# T1600 EPISODE FORMAT
	if grep -q "episode=xmltv_ns" /tmp/settings_new
	then
		echo '	6 "EPISODE FORMAT (currently: xmltv_ns)" \' >> /tmp/menu
	elif grep -q "episode=onscreen" /tmp/settings_new
	then
		echo '	6 "EPISODE FORMAT (currently: onscreen)" \' >> /tmp/menu
	fi
	
	# T1700 DELETE INSTANCE
	echo '	7 "REMOVE GRABBER INSTANCE" \' >> /tmp/menu
	
	echo "2> /tmp/value" >> /tmp/menu
	
	if [ ! -e channels.json ]
	then
		echo "1" > /tmp/value
	else
		bash /tmp/menu
		input="$(cat /tmp/value)"
	fi
	
	
	# ####################
	# T1100 CHANNEL LIST #
	# ####################
	
	if grep -q "1" /tmp/value
	then
		# T1100 MENU OVERLAY
		echo 'dialog --backtitle "[T1100] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CHANNEL LIST" --title "CHANNELS" --checklist "Please choose the channels you want to grab:" 15 50 10 \' > /tmp/chmenu
		
		printf "\rLoading channel list..."
		
		if ! curl --write-out %{http_code} --silent --output /dev/null https://tvplayer.com | grep -q "200"
		then
			printf "\rService provider unavailable!"
			sleep 2s
			exit 0
		fi

		curl -s https://tvplayer.com/tvguide?date=$(date '+%Y-%m-%d') | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' > /tmp/chlist
		
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
				dialog --backtitle "[T1110] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list added!\nPlease run the grabber to add the channels to the setup modules!" 7 50
				echo "H" > /tmp/value
			else
				dialog --backtitle "[T1120] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50
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
				dialog --backtitle "[T1130] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "New channel list saved!\nPlease run the grabber to add new channels to the setup modules!" 7 50
				cp /tmp/chlist chlist_old
				echo "H" > /tmp/value
			else
				dialog --backtitle "[T1140] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CHANNEL LIST" --title "INFO" --msgbox "Channel list creation aborted!\nPlease note that at least 1 channel must be included in channel list!" 7 50
				echo "H" > /tmp/value
			fi
		fi
	
	
	# ###################
	# T1200 TIME PERIOD #
	# ###################
	
	elif grep -q "2" /tmp/value
	then
		echo "X" > /tmp/value
		
		while grep -q "X" /tmp/value
		do
			# T1200 MENU OVERLAY
			dialog --backtitle "[T1200] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > TIME PERIOD" --title "EPG GRABBER" --inputbox "Please enter the number of days you want to retrieve the EPG information. (0=disable | 1-7=enable)" 10 46 2>/tmp/value
							
			sed -i 's/.*/epg&-/g' /tmp/value
			
			# T1210 INPUT: DISABLED
			if grep -q "epg0-" /tmp/value
			then
				sed -i '/day=/d' /tmp/settings_new
				echo "day=0" >> /tmp/settings_new
				dialog --backtitle "[T1210] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber disabled!" 5 26 
				echo "H" > /tmp/value
			
			# T1220 INPUT: 1 DAY
			elif grep -q "epg1-" /tmp/value
			then
				sed -i '/day=/d' /tmp/settings_new
				echo "day=1" >> /tmp/settings_new
				dialog --backtitle "[T1220] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber is enabled for 1 day!" 5 42
				echo "H" > /tmp/value
				
			# T1230 INPUT: 2-7 DAYS
			elif grep -q "epg[2-7]-" /tmp/value
			then
				sed -i 's/epg//g;s/-//g' /tmp/value
				sed -i '/day=/d' /tmp/settings_new
				echo "day=$(</tmp/value)" >> /tmp/settings_new
				dialog --backtitle "[T1230] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > TIME PERIOD" --title "INFO" --msgbox "EPG grabber is enabled for $(</tmp/value) days!" 5 42
				echo "H" > /tmp/value
				
			# T1240 WRONG INPUT
			elif [ -s /tmp/value ]
			then
				dialog --backtitle "[T1240] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > TIME PERIOD" --title "ERROR" --msgbox "Wrong input detected!" 5 30 
				echo "X" > /tmp/value
			
			# T12X0 EXIT
			else
				echo "H" > /tmp/value
			fi
		done

	
	# ###########################
	# T1400 CONVERT CATEGORIES  #
	# ###########################
	
	elif grep -q "4" /tmp/value
	then
		# T1400 MENU OVERLAY
		dialog --backtitle "[T1400] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CONVERT CATEGORIES" --title "CATEGORIES" --yesno "Do you want to use the EIT format for tvHeadend?" 5 55
						
		response=$?
						
		# T1410 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[T1410] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "EIT categories disabled!" 5 32
			sed -i '/genre=/d' /tmp/settings_new
			echo "genre=disabled" >> /tmp/settings_new
			echo "H" > /tmp/value
						
		# T1420 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[T1420] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "EIT categories enabled!" 5 30
			sed -i '/genre=/d' /tmp/settings_new
			echo "genre=enabled" >> /tmp/settings_new
			echo "H" > /tmp/value
							
		# T14X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[T14X0] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > CONVERT CATEGORIES" --title "INFO" --msgbox "No changes applied!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ######################
	# T1600 EPISODE FORMAT #
	# ######################
	
	elif grep -q "6" /tmp/value
	then
		# T1600 MENU OVERLAY
		dialog --backtitle "[T1600] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > EPISODE FORMAT" --title "EPISODE" --menu "Please select the format you want to use.\n\nonscreen: move the episode data into the broadcast description\nxmltv_ns: episode data to be parsed by tvHeadend" 14 60 10 \
		1	"ONSCREEN" \
		2	"XMLTV_NS" \
		2>/tmp/value
		
		# T1610 ONSCREEN
		if grep -q "1" /tmp/value
		then
			dialog --backtitle "[T1610] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > EPISODE FORMAT" --title "INFO" --msgbox "Episode format 'onscreen' enabled!" 5 40
			sed -i '/episode=/d' /tmp/settings_new
			echo "episode=onscreen" >> /tmp/settings_new
			echo "H" > /tmp/value
		
		# T1620 XMLTV_NS
		elif grep -q "2" /tmp/value
		then
			dialog --backtitle "[T1620] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > EPISODE FORMAT" --title "INFO" --msgbox "Episode format 'xmltv_ns' enabled!" 5 40
			sed -i '/episode=/d' /tmp/settings_new
			echo "episode=xmltv_ns" >> /tmp/settings_new
			echo "H" > /tmp/value
		
		# T16X0 EXIT
		else
			echo "H" > /tmp/value
		fi
	
	
	# #######################
	# T1700 DELETE INSTANCE #
	# #######################
	
	elif grep -q "7" /tmp/value
	then
		# T1700 MENU OVERLAY
		dialog --backtitle "[T1700] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > DELETE INSTANCE" --title "WARNING" --yesno "Do you want to delete this service?" 5 50
						
		response=$?
						
		# T1710 NO
		if [ $response = 1 ]
		then
			dialog --backtitle "[T1710] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 32
			echo "H" > /tmp/value
						
		# T1720 YES
		elif [ $response = 0 ] 
		then
			dialog --backtitle "[T1720] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service deleted!" 5 30
			rm channels.json
			echo "M" > /tmp/value
							
		# T17X0 EXIT
		elif [ $response = 255 ]
		then
			dialog --backtitle "[T17X0] EASYEPG SIMPLE XMLTV GRABBER > TVPLAYER SETTINGS > DELETE INSTANCE" --title "INFO" --msgbox "Service not deleted!" 5 30
			echo "H" > /tmp/value
		fi
	
	
	# ############
	# T1X00 EXIT #
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
