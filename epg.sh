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
echo " Release v0.1.4 BETA - 2019/03/29            "
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

chmod 0777 hzn 2> /dev/null && chmod 0777 hzn/* 2> /dev/null
chmod 0777 ztt 2> /dev/null && chmod 0777 ztt/* 2> /dev/null
chmod 0777 swc 2> /dev/null && chmod 0777 swc/* 2> /dev/null

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

if [ ! -e ztt/ch_json2xml.pl ]
then
	printf "\nMissing file in Zattoo folder: ztt/ch_json2xml.pl"
	ERROR="true"
fi

if [ ! -e ztt/chlist_printer.pl ]
then
	printf "\nMissing file in Zattoo folder: ztt/chlist_printer.pl"
	ERROR="true"
fi

if [ ! -e ztt/cid_json.pl ]
then
	printf "\nMissing file in Zattoo folder: ztt/cid_json.pl"
	ERROR="true"
fi

if [ ! -e ztt/compare_crid.pl ]
then
	printf "\nMissing file in Zattoo folder: ztt/compare_crid.pl"
	ERROR="true"
fi

if [ ! -e ztt/compare_menu.pl ]
then
	printf "\nMissing file in Zattoo folder: ztt/compare_menu.pl"
	ERROR="true"
fi

if [ ! -e ztt/epg_json2xml.pl ]
then
	printf "\nMissing file in Zattoo folder: ztt/epg_json2xml.pl"
	ERROR="true"
fi

if [ ! -e ztt/save_page.js ]
then
	printf "\nMissing file in Zattoo folder: ztt/save_page.js"
	ERROR="true"
fi

if [ ! -e ztt/settings.sh ]
then
	printf "\nMissing file in Zattoo folder: ztt/settings.sh"
	ERROR="true"
fi

if [ ! -e ztt/ztt.sh ]
then
	printf "\nMissing file in Zattoo folder: ztt/ztt.sh"
	ERROR="true"
fi

if [ ! -e swc/ch_json2xml.pl ]
then
	printf "\nMissing file in Swisscom folder: swc/ch_json2xml.pl"
	ERROR="true"
fi

if [ ! -e swc/chlist_printer.pl ]
then
	printf "\nMissing file in Swisscom folder: swc/chlist_printer.pl"
	ERROR="true"
fi

if [ ! -e swc/cid_json.pl ]
then
	printf "\nMissing file in Swisscom folder: swc/cid_json.pl"
	ERROR="true"
fi

if [ ! -e swc/compare_crid.pl ]
then
	printf "\nMissing file in Swisscom folder: swc/compare_crid.pl"
	ERROR="true"
fi

if [ ! -e swc/compare_menu.pl ]
then
	printf "\nMissing file in Swisscom folder: swc/compare_menu.pl"
	ERROR="true"
fi

if [ ! -e swc/epg_json2xml.pl ]
then
	printf "\nMissing file in Swisscom folder: swc/epg_json2xml.pl"
	ERROR="true"
fi

if [ ! -e swc/settings.sh ]
then
	printf "\nMissing file in Swisscom folder: swc/settings.sh"
	ERROR="true"
fi

if [ ! -e swc/swc.sh ]
then
	printf "\nMissing file in Swisscom folder: swc/swc.sh"
	ERROR="true"
fi

if [ ! -e swc/url_printer.pl ]
then
	printf "\nMissing file in Swisscom folder: swc/url_printer.pl"
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
command -v wget >/dev/null 2>&1 || { printf "\nwget is required but it's not installed!" >&2; ERROR2="true"; }
command -v phantomjs >/dev/null 2>&1 || { printf "\nPhantomJS is required but it's not installed!" >&2; ERROR2="true"; }
command -v xmllint >/dev/null 2>&1 || { printf "\nlibxml2-utils is required but it's not installed!" >&2; ERROR2="true"; }
command -v perl >/dev/null 2>&1 || { printf "\nperl is required but it's not installed!" >&2; ERROR2="true"; }
command -v cpan >/dev/null 2>&1 || { printf "\ncpan is required but it's not installed!" >&2; ERROR2="true"; }
command -v jq >/dev/null 2>&1 || { printf "\nperl is required but it's not installed!" >&2; ERROR2="true"; }
command -v php >/dev/null 2>&1 || { printf "\nphp is required but it's not installed!" >&2; ERROR2="true"; }

if command -v perldoc >/dev/null
then
	perldoc -l JSON >/dev/null 2>&1 || { printf "\nJSON module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l XML::Rules >/dev/null 2>&1 || { printf "\nXML::Rules module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l Data::Dumper >/dev/null 2>&1 || { printf "\nData::Dumper module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l Time::Piece >/dev/null 2>&1 || { printf "\nTime::Piece module for perl is requried but not installed!" >&2; ERROR2="true"; }
	perldoc -l Time::Seconds >/dev/null 2>&1 || { printf "\nTime::Seconds module for perl is requried but not installed!" >&2; ERROR2="true"; }
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

ls -l hzn/ >  /tmp/providerlist
ls -l ztt/ >>  /tmp/providerlist
ls -l swc/ >>  /tmp/providerlist
if grep -q '^d' /tmp/providerlist 2> /dev/null
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
	ls -l hzn/ >  /tmp/providerlist
	ls -l ztt/ >> /tmp/providerlist
	ls -l swc/ >> /tmp/providerlist
	if grep -q '^d' /tmp/providerlist 2> /dev/null
	then
		echo '	2 "OPEN GRABBER SETTINGS" \' >> /tmp/menu
	fi
	
	# M1300 CREATE SINGLE-/MULTI-SOURCE XML FILE
	if ls xml/ | grep -q ".xml"
	then
		echo '	3 "MODIFY XML FILES" \' >> /tmp/menu
	fi
	
	# M1400 CONTINUE IN GRABBER MODE
	ls -l hzn/ >  /tmp/providerlist
	ls -l ztt/ >> /tmp/providerlist
	ls -l swc/ >> /tmp/providerlist
	if grep -q '^d' /tmp/providerlist 2> /dev/null
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
		echo 'dialog --backtitle "[M1100] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER" --title "PROVIDERS" --menu "Please select a provider you want to use as EPG source:" 11 40 10 \' > /tmp/menu

		# M1110 HORIZON
		echo '	1 "HORIZON" \' >> /tmp/menu
		
		# M1120 ZATTOO
		echo '	2 "ZATTOO" \' >> /tmp/menu
		
		# M1130 SWISSCOM
		echo '	3 "SWISSCOM" \' >> /tmp/menu

		echo "2> /tmp/value" >> /tmp/menu

		bash /tmp/menu
		input="$(cat /tmp/value)"
		
		
		# ###############
		# M1110 HORIZON #
		# ###############

		if grep -q "1" /tmp/value
		then
			# M1110 MENU OVERLAY
			echo 'dialog --backtitle "[M1110] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER > HORIZON" --title "SERVICE" --menu "Please select the service you want to grab:" 11 50 10 \' > /tmp/menu 
			
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
			
			# M111E ERROR
			if ! grep -q '[0-9] "\[[A-Z][A-Z]\] ' /tmp/menu
			then
				dialog --backtitle "[M111E] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER > HORIZON" --title "ERROR" --infobox "All services already exist! Please modify them in settings!" 3 65
				sleep 2s
				echo "M" > /tmp/value
			else
				echo "2> /tmp/value" >> /tmp/menu

				bash /tmp/menu
				input="$(cat /tmp/value)"
			fi
		
		
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
		
		
		# ###############
		# M1120 ZATTOO  #
		# ###############

		elif grep -q "2" /tmp/value
		then
			# M1120 MENU OVERLAY
			echo 'dialog --backtitle "[M1120] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER > ZATTOO" --title "SERVICE" --menu "Please select the service you want to grab:" 11 50 10 \' > /tmp/menu 
			
			# M1121 GERMANY
			if [ ! -d ztt/de ]
			then
				echo '	1 "[DE] Zattoo Germany" \' >> /tmp/menu
			fi
			
			# M1122 SWITZERLAND
			if [ ! -d ztt/at ]
			then
				echo '	2 "[CH] Zattoo Switzerland" \' >> /tmp/menu
			fi
			
			# M112E ERROR
			if ! grep -q '[0-9] "\[[A-Z][A-Z]\] ' /tmp/menu
			then
				dialog --backtitle "[M112E] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER > ZATTOO" --title "ERROR" --infobox "All services already exist! Please modify them in settings!" 3 65
				sleep 2s
				echo "M" > /tmp/value
			else
				echo "2> /tmp/value" >> /tmp/menu

				bash /tmp/menu
				input="$(cat /tmp/value)"
			fi
			
		
			# ##################
			# M1121 ZATTOO DE  #
			# ##################
			
			if grep -q "1" /tmp/value
			then
				mkdir ztt/de
				chmod 0777 ztt/de
				echo '{"country":"DE","language":"de"}' > ztt/de/init.json
				sed '138s/XX/DE/g' ztt/settings.sh > ztt/de/settings.sh
				cp ztt/ztt.sh ztt/de/ztt.sh
				cp ztt/compare_crid.pl ztt/de/
				cp ztt/save_page.js ztt/de/
				cp ztt/epg_json2xml.pl ztt/de/
				cp ztt/ch_json2xml.pl ztt/de/
				cp ztt/cid_json.pl ztt/de/
				cp ztt/chlist_printer.pl ztt/de/
				cp ztt/compare_menu.pl ztt/de/
				cd ztt/de && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e ztt/de/channels.json ]
				then
					rm -rf ztt/de
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1122 ZATTOO CH  #
			# ##################
			
			elif grep -q "2" /tmp/value
			then
				mkdir ztt/ch
				chmod 0777 ztt/ch
				echo '{"country":"CH","language":"de"}' > ztt/ch/init.json
				sed '138s/XX/CH/g' ztt/settings.sh > ztt/ch/settings.sh
				cp ztt/ztt.sh ztt/ch/ztt.sh
				cp ztt/compare_crid.pl ztt/ch/
				cp ztt/save_page.js ztt/ch/
				cp ztt/epg_json2xml.pl ztt/ch/
				cp ztt/ch_json2xml.pl ztt/ch/
				cp ztt/cid_json.pl ztt/ch
				cp ztt/chlist_printer.pl ztt/ch/
				cp ztt/compare_menu.pl ztt/ch/
				cd ztt/ch && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e ztt/ch/channels.json ]
				then
					rm -rf ztt/ch
				fi
				
				echo "M" > /tmp/value
				
			
			# ############
			# M112X EXIT #
			# ############
			
			else
				echo "M" > /tmp/value
			fi
		
		
		# #################
		# M1130 SWISSCOM  #
		# #################

		elif grep -q "3" /tmp/value
		then
			# M1130 MENU OVERLAY
			echo 'dialog --backtitle "[M1130] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER > SWISSCOM" --title "SERVICE" --menu "Please select the service you want to grab:" 11 50 10 \' > /tmp/menu 
			
			# M1131 SWITZERLAND
			if [ ! -d swc/ch ]
			then
				echo '	1 "[CH] SWISSCOM" \' >> /tmp/menu
			fi
			
			# M113E ERROR
			if ! grep -q '[0-9] "\[[A-Z][A-Z]\] ' /tmp/menu
			then
				dialog --backtitle "[M131E] EASYEPG SIMPLE XMLTV GRABBER > ADD GRABBER > SWISSCOM" --title "ERROR" --infobox "All services already exist! Please modify them in settings!" 3 65
				sleep 2s
				echo "M" > /tmp/value
			else
				echo "2> /tmp/value" >> /tmp/menu

				bash /tmp/menu
				input="$(cat /tmp/value)"
			fi
			
			
			# ####################
			# M1131 SWISSCOM CH  #
			# ####################
			
			if grep -q "1" /tmp/value
			then
				mkdir swc/ch
				chmod 0777 swc/ch
				echo '{"country":"CH","language":"de"}' > swc/ch/init.json
				cp swc/settings.sh swc/ch/settings.sh
				cp swc/swc.sh swc/ch/swc.sh
				cp swc/compare_crid.pl swc/ch/
				cp swc/epg_json2xml.pl swc/ch/
				cp swc/ch_json2xml.pl swc/ch/
				cp swc/cid_json.pl swc/ch/
				cp swc/chlist_printer.pl swc/ch/
				cp swc/compare_menu.pl swc/ch/
				cp swc/url_printer.pl swc/ch/
				cd swc/ch && bash settings.sh
				cd - > /dev/null
				
				if [ ! -e swc/ch/channels.json ]
				then
					rm -rf swc/ch
				fi
				
				echo "M" > /tmp/value
			
			
			# ############
			# M113X EXIT #
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
		echo 'dialog --backtitle "[M1200] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS" --title "PROVIDERS" --menu "Please select a provider you want to change:" 11 40 10 \' > /tmp/menu
		
		# M1210 HORIZON
		if ls -l hzn/ | grep -q '^d' 2> /dev/null
		then
			echo '	1 "HORIZON" \' >> /tmp/menu
		fi
		
		# M1220 ZATTOO
		if ls -l ztt/ | grep -q '^d' 2> /dev/null
		then
			echo '	2 "ZATTOO" \' >> /tmp/menu
		fi
		
		# M1230 SWISSCOM
		if ls -l swc/ | grep -q '^d' 2> /dev/null
		then
			echo '	3 "SWISSCOM" \' >> /tmp/menu
		fi
		
		echo "2> /tmp/value" >> /tmp/menu

		bash /tmp/menu
		input="$(cat /tmp/value)"
		
		
		# ###############
		# M1210 HORIZON #
		# ###############
		
		if grep -q "1" /tmp/value
		then
			# M1210 MENU OVERLAY
			echo 'dialog --backtitle "[M1210] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS > HORIZON" --title "SERVICE" --menu "Please select the service you want to change:" 11 50 10 \' > /tmp/menu 
			
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
					rm -rf hzn/de xml/horizon_de.xml
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
					rm -rf hzn/at xml/horizon_at.xml
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
					rm -rf hzn/ch xml/horizon_ch.xml
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
					rm -rf hzn/nl xml/horizon_nl.xml
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
					rm -rf hzn/pl xml/horizon_pl.xml
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
					rm -rf hzn/ie xml/horizon_ie.xml
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
					rm -rf hzn/sk xml/horizon_sk.xml
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
					rm -rf hzn/cz xml/horizon_cz.xml
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
					rm -rf hzn/hu xml/horizon_hu.xml
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
					rm -rf hzn/ro xml/horizon_ro.xml
				fi
				
				echo "M" > /tmp/value
			
			# ############
			# M121X EXIT #
			# ############
			
			else
				echo "M" > /tmp/value
			fi
		
		
		# ###############
		# M1220 ZATTOO  #
		# ###############
		
		elif grep -q "2" /tmp/value
		then
			# M1220 MENU OVERLAY
			echo 'dialog --backtitle "[M1220] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS > ZATTOO" --title "SERVICE" --menu "Please select the service you want to change:" 11 50 10 \' > /tmp/menu 
			
			# M1221 GERMANY
			if [ -d ztt/de ]
			then
				echo '	1 "[DE] Zattoo Germany" \' >> /tmp/menu
			fi
			
			# M1222 SWITZERLAND
			if [ -d ztt/ch ]
			then
				echo '	2 "[CH] Zattoo Switzerland" \' >> /tmp/menu
			fi
			
			# M122E ERROR
			if ! grep -q '[0-9] "\[[A-Z][A-Z]\] ' /tmp/menu
			then
				dialog --backtitle "[M122E] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS > ZATTOO" --title "ERROR" --infobox "No service available! Please setup a service first!" 3 55
				sleep 2s
				echo "M" > /tmp/value
			else
				echo "2> /tmp/value" >> /tmp/menu

				bash /tmp/menu
				input="$(cat /tmp/value)"
			fi
			
			
			# ##################
			# M1221 ZATTOO DE  #
			# ##################
			
			if grep -q "1" /tmp/value
			then
				cd ztt/de
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e ztt/de/channels.json ]
				then
					rm -rf ztt/de xml/zattoo_de.xml 2> /dev/null
				fi
				
				echo "M" > /tmp/value
			
			
			# ##################
			# M1222 ZATTOO CH  #
			# ##################
			
			elif grep -q "2" /tmp/value
			then
				cd ztt/ch
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e ztt/ch/channels.json ]
				then
					rm -rf ztt/ch xml/zattoo_ch.xml 2> /dev/null
				fi
				
				echo "M" > /tmp/value
			
			
			# ############
			# M122X EXIT #
			# ############
			
			else
				echo "M" > /tmp/value
			fi
			
		
		# #################
		# M1230 SWISSCOM  #
		# #################
		
		elif grep -q "3" /tmp/value
		then
			# M1230 MENU OVERLAY
			echo 'dialog --backtitle "[M1230] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS > SWISSCOM" --title "SERVICE" --menu "Please select the service you want to change:" 11 50 10 \' > /tmp/menu 
			
			# M1231 SWISSCOM CH
			if [ -d swc/ch ]
			then
				echo '	1 "[CH] SWISSCOM" \' >> /tmp/menu
			fi
			
			# M123E ERROR
			if ! grep -q '[0-9] "\[[A-Z][A-Z]\] ' /tmp/menu
			then
				dialog --backtitle "[M123E] EASYEPG SIMPLE XMLTV GRABBER > SETTINGS > SWISSCOM" --title "ERROR" --infobox "No service available! Please setup a service first!" 3 55
				sleep 2s
				echo "M" > /tmp/value
			else
				echo "2> /tmp/value" >> /tmp/menu

				bash /tmp/menu
				input="$(cat /tmp/value)"
			fi
			
			
			# ####################
			# M1231 SWISSCOM CH  #
			# ####################
			
			if grep -q "1" /tmp/value
			then
				cd swc/ch
				bash settings.sh
				cd - > /dev/null
				
				if [ ! -e swc/ch/channels.json ]
				then
					rm -rf swc/ch xml/swisscom_ch.xml 2> /dev/null
				fi
				
				echo "M" > /tmp/value
			
			
			# ############
			# M123X EXIT #
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
	
	if ls -l ztt/ | grep -q '^d'
	then
		echo ""
		echo " --------------------------------------------"
		echo " ZATTOO EPG SIMPLE XMLTV GRABBER             "
		echo "                                             "
		echo " (c) 2019 Jan-Luca Neumann / sunsettrack4    "
		echo " --------------------------------------------"
		echo ""
		sleep 2s
		
		cd ztt/de 2> /dev/null && bash ztt.sh && cd - > /dev/null && cp ztt/de/zattoo.xml xml/zattoo_de.xml 2> /dev/null
		cd ztt/ch 2> /dev/null && bash ztt.sh && cd - > /dev/null && cp ztt/ch/zattoo.xml xml/zattoo_ch.xml 2> /dev/null
	fi
	
	if ls -l swc/ | grep -q '^d'
	then
		echo ""
		echo " --------------------------------------------"
		echo " SWISSCOM EPG SIMPLE XMLTV GRABBER           "
		echo "                                             "
		echo " (c) 2019 Jan-Luca Neumann / sunsettrack4    "
		echo " --------------------------------------------"
		echo ""
		sleep 2s
		
		cd swc/ch 2> /dev/null && bash swc.sh && cd - > /dev/null && cp swc/ch/swisscom.xml xml/swisscom_ch.xml 2> /dev/null
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

	printf "Creating XML file: $folder.xml ..."
	rm /tmp/file /tmp/combined_channels /tmp/combined_programmes 2> /dev/null
	
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
	
	# ZATTOO DE
	if [ -s combine/$folder/ztt_de_channels.json ]
	then
		if [ -s xml/zattoo_de.xml ]
		then
			sed 's/fileNAME/zattoo_de.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/ztt_de_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: ZATTOO GERMANY -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/zattoo_de.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/ztt_de_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: ZATTOO GERMANY -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# ZATTOO CH
	if [ -s combine/$folder/ztt_ch_channels.json ]
	then
		if [ -s xml/zattoo_ch.xml ]
		then
			sed 's/fileNAME/zattoo_ch.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/ztt_ch_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: ZATTOO SWITZERLAND -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/zattoo_ch.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/ztt_ch_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: ZATTOO SWITZERLAND -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	# SWISSCOM CH
	if [ -s combine/$folder/swc_ch_channels.json ]
	then
		if [ -s xml/swisscom_ch.xml ]
		then
			sed 's/fileNAME/swisscom_ch.xml/g' ch_combine.pl > /tmp/ch_combine.pl
			sed -i "s/channelsFILE/$folder\/swc_ch_channels.json/g" /tmp/ch_combine.pl
			printf "\n<!-- CHANNEL LIST: SWISSCOM SWITZERLAND -->\n\n" >> /tmp/combined_channels
			perl /tmp/ch_combine.pl >> /tmp/combined_channels
			
			sed 's/fileNAME/swisscom_ch.xml/g' prog_combine.pl > /tmp/prog_combine.pl
			sed -i "s/channelsFILE/$folder\/swc_ch_channels.json/g" /tmp/prog_combine.pl
			printf "\n<!-- PROGRAMMES: SWISSCOM SWITZERLAND -->\n\n" >> /tmp/combined_programmes
			perl /tmp/prog_combine.pl >> /tmp/combined_programmes
		fi
	fi
	
	cat /tmp/combined_programmes >> /tmp/combined_channels 2> /dev/null && mv /tmp/combined_channels /tmp/file 2> /dev/null
	
	if [ -s /tmp/file ]
	then
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
		
		if [ -s combine/$folder/imdbmapper.pl ]
		then
			printf "\n\n --------------------------------------\n\nRunning addon: IMDB MAPPER for $folder.xml ...\n\n"
			perl combine/$folder/imdbmapper.pl combine/$folder/$folder.xml > combine/$folder/$folder_1.xml && mv combine/$folder/$folder_1.xml combine/$folder/$folder.xml
			printf "\n\nDONE!\n\n"
		fi
		
		if [ -s combine/$folder/ratingmapper.pl ]
		then
			printf "\n\n --------------------------------------\n\nRunning addon: RATING MAPPER for $folder.xml ...\n\n"
			perl combine/$folder/ratingmapper.pl combine/$folder/$folder.xml > combine/$folder/$folder_1.xml && mv combine/$folder/$folder_1.xml combine/$folder/$folder.xml
			printf "\n\nDONE!\n\n"
		fi
		
		cp combine/$folder/$folder.xml xml/$folder.xml
		printf "\rXML file $folder.xml created!                            \n"
	else
		printf "\rCreation of XML file $folder.xml failed!\nNo XML or setup file available! Please check your setup!\n"
		sed -i '1d' /tmp/combinefolders
	fi
done
