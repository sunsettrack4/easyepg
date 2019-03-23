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

clear
echo " --------------------------------------------"
echo " EASYEPG SIMPLE XMLTV GRABBER                "
echo " Release v0.1.2 BETA - 2019/03/21            "
echo " powered by                                  "
echo "                                             "
echo " ==THE======================================="
echo "   ##### ##### ##### #   # ##### ##### ##### "
echo "   #     #   # #     #   # #     #   # #     "
echo "  ##### ##### ##### #####  ##### ##### #  ## "
echo "  #     #   #     #   #    #     #     #   # " 
echo " ##### #   # #####   #     ##### #     ##### "
echo " ===================================PROJECT=="
echo "                                             "
echo " (c) 2019 Jan-Luca Neumann / sunsettrack4    "
echo " --------------------------------------------"
echo ""

# ################
# INITIALIZATION #
# ################

#
# CHECK IF ALL MAIN SCRIPTS AND FOLDERS EXIST
#

printf "Initializing script environment..."
sleep 0.5s

mkdir xml 2> /dev/null

if [ ! -e hzn/ch_json2xml.pl ]
then
	printf "\nMissing file in Horzon folder: ch_json2xml.pl "
	ERROR="true"
fi

if [ ! -e hzn/cid_json.pl ]
then
	printf "\nMissing file in Horzon folder: cid_json.pl    "
	ERROR="true"
fi

if [ ! -e hzn/epg_json2xml.pl ]
then
	printf "\nMissing file in Horzon folder: epg_json2xml.pl"
	ERROR="true"
fi

if [ ! -e hzn/settings.sh ]
then
	printf "\nMissing file in Horzon folder: settings.sh         "
	ERROR="true"
fi

if [ ! -e hzn/chlist_printer.pl ]
then
	printf "\nMissing file in Horzon folder: chlist_printer.pl   "
	ERROR="true"
fi

if [ ! -e hzn/compare_menu.pl ]
then
	printf "\nMissing file in Horzon folder: compare_menu.pl   "
	ERROR="true"
fi

if [ ! -e hzn/compare_crid.pl ]
then
	printf "\nMissing file in Horzon folder: compare_crid.pl   "
	ERROR="true"
fi

if [ ! -e hzn/hzn.sh ]
then
	printf "\nMissing file in Horzon folder: hzn.sh         "
	ERROR="true"
fi

if [ ! -e combine.sh ]
then
	printf "\nMissing file in main folder: combine.sh       "
	ERROR="true"
fi

if [ ! -e ch_combine.pl ]
then
	printf "\nMissing file in Horzon folder: ch_combine.pl  "
	ERROR="true"
fi

if [ ! -e prog_combine.pl ]
then
	printf "\nMissing file in Horzon folder: prog_combine.pl"
	ERROR="true"
fi

#
# CHECK IF ALL APPLICATIONS ARE INSTALLED
#

command -v dialog >/dev/null 2>&1 || { printf "\ndialog is required but it's not installed!" >&2; ERROR2="true"; }
command -v curl >/dev/null 2>&1 || { printf "\ncurl is required but it's not installed!" >&2; ERROR2="true"; }
command -v wget >/dev/null 2>&1 || { printf "\nPhantomJS is required but it's not installed!" >&2; ERROR2="true"; }
command -v xmllint >/dev/null 2>&1 || { printf "\nlibxml2-utils is required but it's not installed!" >&2; ERROR2="true"; }
command -v perl >/dev/null 2>&1 || { printf "\nperl is required but it's not installed!" >&2; ERROR2="true"; }
command -v cpan >/dev/null 2>&1 || { printf "\ncpan is required but it's not installed!" >&2; ERROR2="true"; }
command -v jq >/dev/null 2>&1 || { printf "\nperl is required but it's not installed!" >&2; ERROR2="true"; }

if command -v perldoc >/dev/null
then
	perldoc -l JSON >/dev/null 2>&1 || { printf "\nJSON module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l XML::Bare >/dev/null 2>&1 || { printf "\nXML::Bare module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l XML::Rules >/dev/null 2>&1 || { printf "\nXML::Rules module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l Data::Dumper >/dev/null 2>&1 || { printf "\nData::Dumper module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l Time::Piece >/dev/null 2>&1 || { printf "\nTime::Piece module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l utf8 >/dev/null 2>&1 || { printf "\nuft8 module for perl is requried but not installed!" >&2; ERROR2="true"; }
else
	printf "\nperl-doc is required but it's not installed!"
	ERROR2="true"
fi

if [ ! -z "$ERROR2" ]
then
	printf "\n\n[ FATAL ERROR ] Required applications are missing - Stop.\n"
	exit 1
fi


#
# CHECK INTERNET CONNECTIVITY
#

if ! ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null 2> /dev/null
then
	printf "\n\n[ FATAL ERROR ] Internet connection is not available - Stop.\n"
	exit 1
fi


#
# FINAL MESSAGE
#

if [ ! -z "$ERROR" ]
then
	printf "\n\n[ FATAL ERROR ] Script environment is broken - Stop.\n"
	exit 1
else
	printf " OK!\n\n"
	sleep 1s
fi


# ###############
# M1W00 CRONJOB #
# ###############

if ls -l hzn/ | grep -q '^d'
then
	dialog --backtitle "[M1W00] EASYEPG SIMPLE XMLTV GRABBER" --title "MAIN MENU" --infobox "Please press any button to enter the main menu.\n\nThe script will proceed in 5 seconds." 7 50
			
	if read -t 5 -n1
	then
		echo "M" > /tmp/value
	else
		echo "G" > /tmp/value
	fi
else
	echo "M" > /tmp/value
fi


# #################
# M1000 MAIN MENU #
# #################

while grep -q "M" /tmp/value
do
	# M1000 MENU OVERLAY
	echo 'dialog --backtitle "[M1000] EASYEPG SIMPLE XMLTV GRABBER" --title "MAIN MENU" --menu "Welcome to EasyEPG! :)\n(c) 2019 Jan-Luca Neumann\n\nIf you like this script, please support my work:\nhttps://paypal.me/sunsettrack4\n\nPlease choose an option:" 17 55 10 \' > /tmp/menu

	# M1100 ADD GRABBER
	echo '	1 "ADD GRABBER INSTANCE" \' >> /tmp/menu

	# M1200 GRABBER SETTINGS
	if ls -l hzn/ | grep -q '^d'
	then
		echo '	2 "OPEN GRABBER SETTINGS" \' >> /tmp/menu
	fi
	
	# M1300 CREATE SINGLE-/MULTI-SOURCE XML FILE
	if ls xml/ | grep -q ".xml"
	then
		echo '	3 "MODIFY XML FILES" \' >> /tmp/menu
	fi
	
	# M1400 CONTINUE IN GRABBER MODE
	if ls -l hzn/ | grep -q '^d'
	then
		echo '	4 "CONTINUE IN GRABBER MODE" \' >> /tmp/menu
	fi
	
	echo "2> /tmp/value" >> /tmp/menu

	bash /tmp/menu
	input="$(cat /tmp/value)"


	# ###################
	# M1100 ADD GRABBER #
	# ###################

	if grep -q "1" /tmp/value
	then
		# M1100 MENU OVERLAY
		echo 'dialog --backtitle "[M1100] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER" --title "PROVIDERS" --menu "Please select a provider you want to use as EPG source:" 9 40 10 \' > /tmp/menu

		# M1110 HORIZON
		echo '	1 "HORIZON" \' >> /tmp/menu

		echo "2> /tmp/value" >> /tmp/menu

		bash /tmp/menu
		input="$(cat /tmp/value)"
		
		
		# ###############
		# M1110 HORIZON #
		# ###############

		if grep -q "1" /tmp/value
		then
			# M1110 MENU OVERLAY
			echo 'dialog --backtitle "[M1110] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER > HORIZON" --title "COUNTRY" --menu "Please select the service you want to grab:" 11 50 10 \' > /tmp/menu 
			
			# M1111 GERMANY
			if [ ! -d hzn/de ]
			then
				echo '	1 "[DE] Unitymedia Germany" \' >> /tmp/menu
			fi
			
			# M1112 AUSTRIA
			if [ ! -d hzn/at ]
			then
				echo '	2 "[AT] UPC Austria" \' >> /tmp/menu
			fi
			
			# M1113 SWITZERLAND
			if [ ! -d hzn/ch ]
			then
				echo '	3 "[CH] UPC Switzerland" \' >> /tmp/menu
			fi
			
			# M1114 NETHERLANDS
			if [ ! -d hzn/nl ]
			then
				echo '	4 "[NL] Ziggo Netherlands" \' >> /tmp/menu
			fi
			
			# M1115 POLAND
			if [ ! -d hzn/pl ]
			then
				echo '	5 "[PL] Horizon Poland" \' >> /tmp/menu
			fi
			
			# M1116 IRELAND
			if [ ! -d hzn/ie ]
			then
				echo '	6 "[IE] Virgin Media Ireland" \' >> /tmp/menu
			fi
			
			# M1117 SLOVAKIA
			if [ ! -d hzn/sk ]
			then
				echo '	7 "[SK] Horizon Slovakia" \' >> /tmp/menu
			fi
			
			# M1118 CZECH REPUBLIC
			if [ ! -d hzn/cz ]
			then
				echo '	8 "[CZ] Horizon Czech Republic" \' >> /tmp/menu
			fi
			
			# M1119 HUNGARY
			if [ ! -d hzn/hu ]
			then
				echo '	9 "[HU] Horizon Hungary" \' >> /tmp/menu
			fi
			
			# M111R ROMANIA
			if [ ! -d hzn/ro ]
			then
				echo '	0 "[RO] Horizon Romania" \' >> /tmp/menu
			fi
			
			echo "2> /tmp/value" >> /tmp/menu

			bash /tmp/menu
			input="$(cat /tmp/value)"
		
		
			# ##################
			# M1111 HORIZON DE #
			# ##################
			
			if grep -q "1" /tmp/value
			then
				mkdir hzn/de
				chmod 0777 hzn/de
				echo '{"country":"DE","language":"de"}' > hzn/de/init.json
				cp hzn/hzn.sh hzn/de/
				cp hzn/ch_json2xml.pl hzn/de/
				cp hzn/cid_json.pl hzn/de/
				cp hzn/epg_json2xml.pl hzn/de/
				cp hzn/settings.sh hzn/de/
				cp hzn/chlist_printer.pl hzn/de/
				cp hzn/compare_menu.pl hzn/de/
				cp hzn/compare_crid.pl hzn/de/
				cd hzn/de && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/de/channels.json ]
				then
					rm -rf hzn/de
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1112 HORIZON AT #
			# ##################
			
			elif grep -q "2" /tmp/value
			then
				mkdir hzn/at
				chmod 0777 hzn/at
				echo '{"country":"AT","language":"de"}' > hzn/at/init.json
				cp hzn/hzn.sh hzn/at/
				cp hzn/ch_json2xml.pl hzn/at/
				cp hzn/cid_json.pl hzn/at/
				cp hzn/epg_json2xml.pl hzn/at/
				cp hzn/settings.sh hzn/at/
				cp hzn/chlist_printer.pl hzn/at/
				cp hzn/compare_menu.pl hzn/at/
				cp hzn/compare_crid.pl hzn/at/
				cd hzn/at && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/at/channels.json ]
				then
					rm -rf hzn/at
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1113 HORIZON CH #
			# ##################
			
			elif grep -q "3" /tmp/value
			then
				mkdir hzn/ch
				chmod 0777 hzn/ch
				echo '{"country":"CH","language":"de"}' > hzn/ch/init.json
				cp hzn/hzn.sh hzn/ch/
				cp hzn/ch_json2xml.pl hzn/ch/
				cp hzn/cid_json.pl hzn/ch/
				cp hzn/epg_json2xml.pl hzn/ch/
				cp hzn/settings.sh hzn/ch/
				cp hzn/chlist_printer.pl hzn/ch/
				cp hzn/compare_menu.pl hzn/ch/
				cp hzn/compare_crid.pl hzn/ch/
				cd hzn/ch && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/ch/channels.json ]
				then
					rm -rf hzn/ch
				fi
				
				echo "M" > /tmp/value
				
			
			# ##################
			# M1114 HORIZON NL #
			# ##################
			
			elif grep -q "4" /tmp/value
			then
				mkdir hzn/nl
				chmod 0777 hzn/nl
				echo '{"country":"NL","language":"nl"}' > hzn/nl/init.json
				cp hzn/hzn.sh hzn/nl/
				cp hzn/ch_json2xml.pl hzn/nl/
				cp hzn/cid_json.pl hzn/nl/
				cp hzn/epg_json2xml.pl hzn/nl/
				cp hzn/settings.sh hzn/nl/
				cp hzn/chlist_printer.pl hzn/nl/
				cp hzn/compare_menu.pl hzn/nl/
				cp hzn/compare_crid.pl hzn/nl/
				cd hzn/nl && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/nl/channels.json ]
				then
					rm -rf hzn/nl
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1115 HORIZON PL #
			# ##################
			
			elif grep -q "5" /tmp/value
			then
				mkdir hzn/pl
				chmod 0777 hzn/pl
				echo '{"country":"PL","language":"pl"}' > hzn/pl/init.json
				cp hzn/hzn.sh hzn/pl/
				cp hzn/ch_json2xml.pl hzn/pl/
				cp hzn/cid_json.pl hzn/pl/
				cp hzn/epg_json2xml.pl hzn/pl/
				cp hzn/settings.sh hzn/pl/
				cp hzn/chlist_printer.pl hzn/pl/
				cp hzn/compare_menu.pl hzn/pl/
				cp hzn/compare_crid.pl hzn/pl/
				cd hzn/pl && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/pl/channels.json ]
				then
					rm -rf hzn/pl
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1116 HORIZON IE #
			# ##################
			
			elif grep -q "6" /tmp/value
			then
				mkdir hzn/ie
				chmod 0777 hzn/ie
				echo '{"country":"IE","language":"en"}' > hzn/ie/init.json
				cp hzn/hzn.sh hzn/ie/
				cp hzn/ch_json2xml.pl hzn/ie/
				cp hzn/cid_json.pl hzn/ie/
				cp hzn/epg_json2xml.pl hzn/ie/
				cp hzn/settings.sh hzn/ie/
				cp hzn/chlist_printer.pl hzn/ie/
				cp hzn/compare_menu.pl hzn/ie/
				cp hzn/compare_crid.pl hzn/ie/
				cd hzn/ie && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/ie/channels.json ]
				then
					rm -rf hzn/ie
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1117 HORIZON SK #
			# ##################
			
			elif grep -q "7" /tmp/value
			then
				mkdir hzn/sk
				chmod 0777 hzn/sk
				echo '{"country":"SK","language":"sk"}' > hzn/sk/init.json
				cp hzn/hzn.sh hzn/sk/
				cp hzn/ch_json2xml.pl hzn/sk/
				cp hzn/cid_json.pl hzn/sk/
				cp hzn/epg_json2xml.pl hzn/sk/
				cp hzn/settings.sh hzn/sk/
				cp hzn/chlist_printer.pl hzn/sk/
				cp hzn/compare_menu.pl hzn/sk/
				cp hzn/compare_crid.pl hzn/sk/
				cd hzn/sk && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/sk/channels.json ]
				then
					rm -rf hzn/sk
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1118 HORIZON CZ #
			# ##################
			
			elif grep -q "8" /tmp/value
			then
				mkdir hzn/cz
				chmod 0777 hzn/cz
				echo '{"country":"CZ","language":"cs"}' > hzn/cz/init.json
				cp hzn/hzn.sh hzn/cz/
				cp hzn/ch_json2xml.pl hzn/cz/
				cp hzn/cid_json.pl hzn/cz/
				cp hzn/epg_json2xml.pl hzn/cz/
				cp hzn/settings.sh hzn/cz/
				cp hzn/chlist_printer.pl hzn/cz/
				cp hzn/compare_menu.pl hzn/cz/
				cp hzn/compare_crid.pl hzn/cz/
				cd hzn/cz && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/cz/channels.json ]
				then
					rm -rf hzn/cz
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1119 HORIZON HU #
			# ##################
			
			elif grep -q "9" /tmp/value
			then
				mkdir hzn/hu
				chmod 0777 hzn/hu
				echo '{"country":"HU","language":"hu"}' > hzn/hu/init.json
				cp hzn/hzn.sh hzn/hu/
				cp hzn/ch_json2xml.pl hzn/hu/
				cp hzn/cid_json.pl hzn/hu/
				cp hzn/epg_json2xml.pl hzn/hu/
				cp hzn/settings.sh hzn/hu/
				cp hzn/chlist_printer.pl hzn/hu/
				cp hzn/compare_menu.pl hzn/hu/
				cp hzn/compare_crid.pl hzn/hu/
				cd hzn/hu && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/hu/channels.json ]
				then
					rm -rf hzn/hu
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M111R HORIZON RO #
			# ##################
			
			elif grep -q "0" /tmp/value
			then
				mkdir hzn/ro
				chmod 0777 hzn/ro
				echo '{"country":"RO","language":"ro"}' > hzn/ro/init.json
				cp hzn/hzn.sh hzn/ro/
				cp hzn/ch_json2xml.pl hzn/ro/
				cp hzn/cid_json.pl hzn/ro/
				cp hzn/epg_json2xml.pl hzn/ro/
				cp hzn/settings.sh hzn/ro/
				cp hzn/chlist_printer.pl hzn/ro/
				cp hzn/compare_menu.pl hzn/ro/
				cp hzn/compare_crid.pl hzn/ro/
				cd hzn/ro && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/ro/channels.json ]
				then
					rm -rf hzn/ro
				fi
				
				echo "M" > /tmp/value
			
			
			# ############
			# M111X EXIT #
			# ############
			
			else
				echo "M" > /tmp/value
			fi
		
		
		# ############
		# M1X00 EXIT #
		# ############
		
		else
			echo "M" > /tmp/value
		fi


	# #############################
	# M1200 OPEN GRABBER SETTINGS #
	# #############################

	elif grep -q "2" /tmp/value
	then
		# M1200 MENU OVERLAY
		echo 'dialog --backtitle "[M1200] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS" --title "PROVIDERS" --menu "Please select a provider you want to change:" 9 40 10 \' > /tmp/menu
		
		# M1210 HORIZON
		echo '	1 "HORIZON" \' >> /tmp/menu
		
		echo "2> /tmp/value" >> /tmp/menu

		bash /tmp/menu
		input="$(cat /tmp/value)"
		
		
		# ###############
		# M1210 HORIZON #
		# ###############
		
		if grep -q "1" /tmp/value
		then
			# M1210 MENU OVERLAY
			echo 'dialog --backtitle "[M1210] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS > HORIZON" --title "COUNTRY" --menu "Please select the service you want to change:" 11 50 10 \' > /tmp/menu 
			
			# M1211 GERMANY
			if [ -d hzn/de ]
			then
				echo '	1 "[DE] Unitymedia Germany" \' >> /tmp/menu
			fi
			
			# M1212 AUSTRIA
			if [ -d hzn/at ]
			then
				echo '	2 "[AT] UPC Austria" \' >> /tmp/menu
			fi
			
			# M1213 SWITZERLAND
			if [ -d hzn/ch ]
			then
				echo '	3 "[CH] UPC Switzerland" \' >> /tmp/menu
			fi
			
			# M1214 NETHERLANDS
			if [ -d hzn/nl ]
			then
				echo '	4 "[NL] Ziggo Netherlands" \' >> /tmp/menu
			fi
			
			# M1215 POLAND
			if [ -d hzn/pl ]
			then
				echo '	5 "[PL] Horizon Poland" \' >> /tmp/menu
			fi
			
			# M1216 IRELAND
			if [ -d hzn/ie ]
			then
				echo '	6 "[IE] Virgin Media Ireland" \' >> /tmp/menu
			fi
			
			# M1217 SLOVAKIA
			if [ -d hzn/sk ]
			then
				echo '	7 "[SK] Horizon Slovakia" \' >> /tmp/menu
			fi
			
			# M1218 CZECH REPUBLIC
			if [ -d hzn/cz ]
			then
				echo '	8 "[CZ] Horizon Czech Republic" \' >> /tmp/menu
			fi
			
			# M1219 HUNGARY
			if [ -d hzn/hu ]
			then
				echo '	9 "[HU] Horizon Hungary" \' >> /tmp/menu
			fi
			
			# M121R ROMANIA
			if [ -d hzn/ro ]
			then
				echo '	0 "[RO] Horizon Romania" \' >> /tmp/menu
			fi
			
			# M121E ERROR
			if ! grep -q '[0-9] "\[[A-Z][A-Z]\] ' /tmp/menu
			then
				dialog --backtitle "[M121E] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS > HORIZON" --title "ERROR" --infobox "No service available! Please setup a service first!" 3 55
				sleep 2s
				echo "M" > /tmp/value
			else
				echo "2> /tmp/value" >> /tmp/menu

				bash /tmp/menu
				input="$(cat /tmp/value)"
			fi
			
			
			# ##################
			# M1211 HORIZON DE #
			# ##################
			
			if grep -q "1" /tmp/value
			then
				cd hzn/de
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/de/channels.json ]
				then
					rm -rf hzn/de
				fi
				
				echo "M" > /tmp/value
				
				
			# ##################
			# M1212 HORIZON AT #
			# ##################
			
			elif grep -q "2" /tmp/value
			then
				cd hzn/at
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/at/channels.json ]
				then
					rm -rf hzn/at
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1213 HORIZON CH #
			# ##################
			
			elif grep -q "3" /tmp/value
			then
				cd hzn/ch
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/ch/channels.json ]
				then
					rm -rf hzn/ch
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1214 HORIZON NL #
			# ##################
			
			elif grep -q "4" /tmp/value
			then
				cd hzn/nl
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/nl/channels.json ]
				then
					rm -rf hzn/nl
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1215 HORIZON PL #
			# ##################
			
			elif grep -q "5" /tmp/value
			then
				cd hzn/pl
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/pl/channels.json ]
				then
					rm -rf hzn/pl
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1216 HORIZON IE #
			# ##################
			
			elif grep -q "6" /tmp/value
			then
				cd hzn/ie
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/ie/channels.json ]
				then
					rm -rf hzn/ie
				fi
				
				echo "M" > /tmp/value
				
				
			# ##################
			# M1217 HORIZON SK #
			# ##################
			
			elif grep -q "7" /tmp/value
			then
				cd hzn/sk
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/sk/channels.json ]
				then
					rm -rf hzn/sk
				fi
				
				echo "M" > /tmp/value
				
			
			# ##################
			# M1218 HORIZON CZ #
			# ##################
			
			elif grep -q "8" /tmp/value
			then
				cd hzn/cz
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/cz/channels.json ]
				then
					rm -rf hzn/cz
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1219 HORIZON HU #
			# ##################
			
			elif grep -q "9" /tmp/value
			then
				cd hzn/hu
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/hu/channels.json ]
				then
					rm -rf hzn/hu
				fi
				
				echo "M" > /tmp/value
				
			
			# ##################
			# M121R HORIZON RO #
			# ##################
			
			elif grep -q "0" /tmp/value
			then
				cd hzn/ro
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e hzn/ro/channels.json ]
				then
					rm -rf hzn/ro
				fi
				
				echo "M" > /tmp/value
			
			# ############
			# M121X EXIT #
			# ############
			
			else
				echo "M" > /tmp/value
			fi
		
		
		# ############
		# M12X0 EXIT #
		# ############
			
		else
			echo "M" > /tmp/value
		fi
	
	
	# ####################################
	# M1300 CREATE MULTI-SOURCE XML FILE #
	# ####################################
	
	elif grep -q "3" /tmp/value
	then
		echo "C" > /tmp/value
		while grep -q "C" /tmp/value
		do
			bash combine.sh
		done
		echo "M" > /tmp/value
	
	
	# ################################
	# M1400 CONTINUE IN GRABBER MODE #
	# ################################
	
	elif grep -q "4" /tmp/value
	then
		echo "G" > /tmp/value
	
	
	# ############
	# M1X00 EXIT #
	# ############
	
	else
		dialog --backtitle "[M1X00] EASYEPG SIMPLE XMLTV GRABBER > EXIT"  --title "EXIT" --yesno "Do you want to quit?" 5 30
						
		response=$?
				
		if [ $response = 1 ]
		then
			echo "M" > /tmp/value
		elif [ $response = 0 ]
		then
			clear
			exit 0
		else
			echo "M" > /tmp/value
		fi
	fi
done


# ##########################
# CONTINUE IN GRABBER MODE #
# ##########################

clear
		
#
# HORIZON
#

if grep -q "G" /tmp/value	
then
	if ls -l hzn/ | grep -q '^d'
	then
		echo ""
		echo " --------------------------------------------"
		echo " HORIZON EPG SIMPLE XMLTV GRABBER            "
		echo "                                             "
		echo " (c) 2019 Jan-Luca Neumann / sunsettrack4    "
		echo " --------------------------------------------"
		echo ""
		sleep 2s
		
		cd hzn/de 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/de/horizon.xml xml/horizon_de.xml 2> /dev/null
		cd hzn/at 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/at/horizon.xml xml/horizon_at.xml 2> /dev/null
		cd hzn/ch 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/ch/horizon.xml xml/horizon_ch.xml 2> /dev/null
		cd hzn/nl 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/nl/horizon.xml xml/horizon_nl.xml 2> /dev/null
		cd hzn/pl 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/pl/horizon.xml xml/horizon_pl.xml 2> /dev/null
		cd hzn/ie 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/ie/horizon.xml xml/horizon_ie.xml 2> /dev/null
		cd hzn/sk 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/sk/horizon.xml xml/horizon_sk.xml 2> /dev/null
		cd hzn/cz 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/cz/horizon.xml xml/horizon_cz.xml 2> /dev/null
		cd hzn/hu 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/hu/horizon.xml xml/horizon_hu.xml 2> /dev/null
		cd hzn/ro 2> /dev/null && bash hzn.sh && cd - > /dev/null && cp hzn/ro/horizon.xml xml/horizon_ro.xml 2> /dev/null
	fi
fi

#
# COMBINE XML FILES
#

ls combine > /tmp/combinefolders 2> /dev/null

if [ -s /tmp/combinefolders ]
then
	echo ""
	echo " --------------------------------------------"
	echo " CREATING CUSTOMIZED XMLTV FILES             "
	echo " --------------------------------------------"
	echo ""
	sleep 2s
fi

while [ -s /tmp/combinefolders ]
do
	folder=$(sed -n "1p" /tmp/combinefolders)

	printf "Creating combined file: $folder ..."
	
	# HORIZON DE
	if [ -s combine/$folder/hzn_de_channels.json ]
	then
		if [ -s xml/horizon_de.xml ]
		then
			sed 's/fileNAME/horizon_de.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_de_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: UNITYMEDIA GERMANY -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_de.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_de_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: UNITYMEDIA GERMANY -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON AT
	if [ -s combine/$folder/hzn_at_channels.json ]
	then
		if [ -s xml/horizon_at.xml ]
		then
			sed 's/fileNAME/horizon_at.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_at_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: UPC AUSTRIA  -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_at.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_at_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: UPC AUSTRIA -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	
	# HORIZON CH
	if [ -s combine/$folder/hzn_ch_channels.json ]
	then
		if [ -s xml/horizon_ch.xml ]
		then
			sed 's/fileNAME/horizon_ch.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_ch_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: UPC SWITZERLAND -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_ch.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_ch_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: UPC SWITZERLAND -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON NL
	if [ -s combine/$folder/hzn_nl_channels.json ]
	then
		if [ -s xml/horizon_nl.xml ]
		then
			sed 's/fileNAME/horizon_nl.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_nl_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: ZIGGO NETHERLANDS -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_nl.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_nl_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: ZIGGO NETHERLANDS -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON PL
	if [ -s combine/$folder/hzn_pl_channels.json ]
	then
		if [ -s xml/horizon_pl.xml ]
		then
			sed 's/fileNAME/horizon_pl.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_pl_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: HORIZON POLAND -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_pl.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_pl_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: HORIZON POLAND -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON IE
	if [ -s combine/$folder/hzn_ie_channels.json ]
	then
		if [ -s xml/horizon_ie.xml ]
		then
			sed 's/fileNAME/horizon_ie.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_ie_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: VIRGIN MEDIA IRELAND -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_ie.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_ie_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: VIRGIN MEDIA IRELAND -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON SK
	if [ -s combine/$folder/hzn_sk_channels.json ]
	then
		if [ -s xml/horizon_sk.xml ]
		then
			sed 's/fileNAME/horizon_sk.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_sk_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: HORIZON SLOVAKIA -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_sk.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_sk_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: HORIZON SLOVAKIA -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON CZ
	if [ -s combine/$folder/hzn_cz_channels.json ]
	then
		if [ -s xml/horizon_cz.xml ]
		then
			sed 's/fileNAME/horizon_cz.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_cz_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: HORIZON CZECH REPUBLIC -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_cz.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_cz_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: HORIZON CZECH REPUBLIC -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON HU
	if [ -s combine/$folder/hzn_hu_channels.json ]
	then
		if [ -s xml/horizon_hu.xml ]
		then
			sed 's/fileNAME/horizon_hu.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_hu_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: HORIZON HUNGARY -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_hu.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_hu_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: HORIZON HUNGARY -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# HORIZON RO
	if [ -s combine/$folder/hzn_ro_channels.json ]
	then
		if [ -s xml/horizon_ro.xml ]
		then
			sed 's/fileNAME/horizon_ro.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_ro_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: HORIZON ROMANIA -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/horizon_ro.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/hzn_ro_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: HORIZON ROMANIA -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	cat /tmp/combined_programmes >> /tmp/combined_channels && mv /tmp/combined_channels /tmp/file
	sed -i 's/\&/\&amp;/g' /tmp/file
	
	sed -i "1i<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<\!-- created on $(date) -->\n<tv>" /tmp/file
	sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>' /tmp/file
	sed '$s/.*/&\n<\/tv>/g' /tmp/file > combine/$folder/$folder.xml
	rm /tmp/combined_programmes
	sed -i '1d' /tmp/combinefolders
	
	if [ -s combine/$folder/setup.sh ]
	then
		bash combine/$folder/setup.sh
	fi
	
	printf "\rCreating combined file: $folder ... DONE!\n"
done
