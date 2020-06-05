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

if grep -q "DE" init.json 2> /dev/null
then
	printf "+++ COUNTRY: GERMANY +++\n\n"
fi

if grep -q '"day": "0"' settings.json
then
	printf "EPG Grabber disabled!\n\n"
	exit 0
fi

if ! curl --write-out %{http_code} --silent --output /dev/null https://live.tvspielfilm.de | grep -q "200"
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

printf "\rDeleting old files...               "

rm mani/* 2> /dev/null


#
# LOADING MANIFEST FILES
#

printf "\rFetching channel list...               "
curl --compressed -s https://live.tvspielfilm.de/static/content/channel-list/livetv > /tmp/workfile
jq '.' /tmp/workfile > /tmp/chlist
sed -i -e 1c'\{\n "items": \[' /tmp/chlist
echo '}' >> /tmp/chlist

######################################
# Dirty Workaround until TVS fix their Channellist
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/chlist_hack_tvs.json > /tmp/chlist
#######################################

printf "\rChecking manifest files... "
perl chlist_printer.pl > /tmp/compare.json
perl url_printer.pl 2>errors.txt | sed '/DUMMY/d' > mani/common

printf "\n$(echo $(wc -l < mani/common)) manifest file(s) to be downloaded!\n\n"

if [ $(wc -l < mani/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < mani/common) / 7)))
	
	split --lines=$(( $number + 1 )) --numeric-suffixes mani/common mani/day
	
else	
	cp mani/common mani/day00
fi

#
# CREATE STATUS INFO FOR MANIFEST FILE DOWNLOAD
#


function status_manifest_download { 
    #setup_scroll_area
	sleep 2 2> /dev/null ;
    thread=$(ps ax)
	if [[ $thread =~ ^.*curl.*$ ]] ;
        then 
			z0="[                    ]"
			z5="[#                   ]"
			z10="[##                  ]"
			z15="[###                 ]"
			z20="[####                ]"
			z25="[#####               ]"
			z30="[######              ]"
			z35="[#######             ]"
			z40="[########            ]"
			z45="[#########           ]"
			z50="[##########          ]"
			z55="[###########         ]"
			z60="[############        ]"
			z65="[#############       ]"
			z70="[##############      ]"
			z75="[###############     ]"
			z80="[################    ]"
			z85="[#################   ]"
			z90="[##################  ]"
			z95="[################### ]"
			z100="[####################]"

			df=$(find mani/ -type f | wc -l) ;
			if [ -e mani/common ]; then ftd=$(wc -l < mani/common); else ftd=$(wc -l < mani/day00); fi;
			status=$(expr $df \* 100 / $ftd - 2) ;
			if [[ $status -gt 100 || $status -eq 100 ]]; then status="100"; fi
			if [[ $status -gt 0 && $status -lt 5 || $status -eq 0 ]]; then bar="$z0"; elif [[ $status -gt 5 && $status -lt 10 ]]; then bar="$z5"; elif [[ $status -gt 10 && $status -lt 15 ]] ; then bar="$z10"; elif [[ $status -gt 15 && $status -lt 20 ]] ; then bar="$z15"; elif [[ $status -gt 20 && $status -lt 25 ]] ; then bar="$z20"; elif [[ $status -gt 25 && $status -lt 30 ]] ; then bar="$z25"; elif [[ $status -gt 30 && $status -lt 35 ]] ; then bar="$z30"; elif [[ $status -gt 35 && $status -lt 40 ]] ; then bar="$z35"; elif [[ $status -gt 40 && $status -lt 45 ]] ; then bar="$z40"; elif [[ $status -gt 40 && $status -lt 50 ]] ; then bar="$z45"; elif [[ $status -gt 50 && $status -lt 55 ]] ; then bar="$z50"; elif [[ $status -gt 55 && $status -lt 60 ]] ; then bar="$z55"; elif [[ $status -gt 60 && $status -lt 65 ]] ; then bar="$z60"; elif [[ $status -gt 60 && $status -lt 70 ]] ; then bar="$z65"; elif [[ $status -gt 70 && $status -lt 75 ]] ; then bar="$z70"; elif [[ $status -gt 70 && $status -lt 80 ]] ; then bar="$z75"; elif [[ $status -gt 80 && $status -lt 85 ]] ; then bar="$z80"; elif [[ $status -gt 85 && $status -lt 90 ]] ; then bar="$z85"; elif [[ $status -gt 90 && $status -lt 95 ]] ; then bar="$z90"; elif [[ $status -gt 95 && $status -lt 100 ]] ; then bar="$z95"; elif [ $status -eq 100 ] ; then bar="$z100";fi
			printf "\rProgress $bar  $status%% ";                                  
			status_manifest_download ;
        fi
        }

#
# CREATE MANIFEST DOWNLOAD SCRIPTS
#

for time in {0..8..1}
do	
	sed -i '1i#\!\/bin\/bash\n' mani/day0${time} 2> /dev/null
done


#
# COPY/PASTE EPG DETAILS
#

printf "\rLoading manifest files..."
echo ""
printf "\rProgress [                    ]    0%% "

status_manifest_download &

for a in {0..8..1}
do
	bash mani/day0${a} 2> /dev/null &
done
wait

rm mani/day0* 2> /dev/null && rm mani/common 2> /dev/null

printf "\rProgress [####################]  100%% "
echo "DONE!" && printf "\n"


#
# CREATE EPG BROADCAST LIST
#

printf "\rCreating EPG manifest file... "

rm /tmp/manifile.json 2> /dev/null
sed -i -e '$a]}' mani/* #REQUIED TO TO READ JSON CORRECTLY (IF AVAIVIBLE DATA < DAYSETTINGS)
cat mani/* > /tmp/manifile.json
jq -s '.' /tmp/manifile.json > /tmp/epg_workfile 2>>errors.txt
sed -i '1s/\[/{ "attributes":[/g;$s/\]/&}/g' /tmp/epg_workfile
rm mani/*
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
	
	cp /tmp/chlist chlist_old
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
curl --compressed -s https://live.tvspielfilm.de/static/content/channel-list/livetv > /tmp/chlist
jq '.' /tmp/chlist > chlist
sed -i -e 1c'\{\n "items": \[' chlist
echo '}' >> chlist
cp chlist /tmp/chlist

######################################
# Dirty Workaround until TVS fix their Channellist
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/chlist_hack_tvs.json > /tmp/chlist
cp /tmp/chlist chlist
#######################################

curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/tvs_channels.json > tvs_channels.json
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/tvs_genres.json > tvs_genres.json

# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > tv-spielfilm_channels
sort -u tv-spielfilm_channels > /tmp/tv-spielfilm_channels && mv /tmp/tv-spielfilm_channels tv-spielfilm_channels
sed -i 's/></>\n</g;s/<display-name/  &/g;s/<icon src/  &/g' tv-spielfilm_channels

# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                    "
perl cid_json.pl > tvs_cid.json && rm chlist

# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
perl epg_json2xml.pl > tv-spielfilm_epg 2>epg_warnings.txt && rm /tmp/epg_workfile 2> /dev/null


# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                   "
cat tv-spielfilm_epg >> tv-spielfilm_channels && mv tv-spielfilm_channels tv-spielfilm && rm tv-spielfilm_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019-2020 Jan-Luca Neumann -->\n<tv>' tv-spielfilm
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" tv-spielfilm
sed -i '$s/.*/&\n\n<\/tv>/g' tv-spielfilm
mv tv-spielfilm tv-spielfilm.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout tv-spielfilm.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv tv-spielfilm.xml tv-spielfilm_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm tv-spielfilm_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" tv-spielfilm.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep "<channel id=" tv-spielfilm.xml > /tmp/id_check
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
		mv tv-spielfilm.xml tv-spielfilm_ERROR.xml
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
