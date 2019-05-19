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
# SETUP ENVIRONMENT
#

mkdir cache 2> /dev/null	# cache
mkdir day 2> /dev/null		# download scripts

if grep -q '"day": "0"' settings.json
then
	printf "EPG Grabber disabled!\n\n"
	exit 0
fi

if ! curl --write-out %{http_code} --silent --output /dev/null https://tvplayer.com | grep -q "200"
then
	printf "Service provider unavailable!\n\n"
	exit 0
fi

date1=$(date '+%Y%m%d')
date2=$(date -d '1 day' '+%Y%m%d')
date3=$(date -d '2 days' '+%Y%m%d')
date4=$(date -d '3 days' '+%Y%m%d')
date5=$(date -d '4 days' '+%Y%m%d')
date6=$(date -d '5 days' '+%Y%m%d')
date7=$(date -d '6 days' '+%Y%m%d')


# ##################
# DOWNLOAD PROCESS #
# ##################

echo "- DOWNLOAD PROCESS -" && echo ""

#
# DELETE OLD FILES
#

printf "\rDeleting old files...                       "

rm day/epgdata 2> /dev/null


#
# DOWNLOAD EPG MANIFESTS
#

printf "\rDownloading EPG manifest files... "

if grep -q '"day": "[1-7]"' settings.json; then curl -s https://tvplayer.com/tvguide?date=$date1 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' >> day/epgdata; fi &
if grep -q '"day": "[2-7]"' settings.json; then curl -s https://tvplayer.com/tvguide?date=$date2 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' >> day/epgdata; fi &
if grep -q '"day": "[3-7]"' settings.json; then curl -s https://tvplayer.com/tvguide?date=$date3 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' >> day/epgdata; fi &
if grep -q '"day": "[4-7]"' settings.json; then curl -s https://tvplayer.com/tvguide?date=$date4 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' >> day/epgdata; fi &
if grep -q '"day": "[5-7]"' settings.json; then curl -s https://tvplayer.com/tvguide?date=$date5 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' >> day/epgdata; fi &
if grep -q '"day": "[6-7]"' settings.json; then curl -s https://tvplayer.com/tvguide?date=$date6 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' >> day/epgdata; fi &
if grep -q '"day": "[7]"'   settings.json; then curl -s https://tvplayer.com/tvguide?date=$date7 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' >> day/epgdata; fi &
wait

echo  "DONE!" && printf "\n"


#
# SHOW ERROR MESSAGE + ABORT PROCESS IF CHANNEL IDs WERE CHANGED
#

curl -s https://tvplayer.com/tvguide?date=$date1 | grep "var channels" | sed 's/\(.*var channels = \)\(.*\)}\];/{ "attributes": \2}]}/g' > /tmp/chlist
perl chlist_printer.pl > /tmp/compare.json
perl compare_menu.pl 2>/tmp/errors.txt > /tmp/xxx

sort -u /tmp/errors.txt > /tmp/errors_sorted.txt && mv /tmp/errors_sorted.txt /tmp/errors.txt

if [ -s /tmp/errors.txt ]
then
	echo "================= CHANNEL LIST: LOG ==================="
	echo ""
	
	input="/tmp/errors.txt"
	while IFS= read -r var
	do
		echo "$var"
	done < "$input"

	echo ""
	echo "======================================================="
	echo ""
	
	rm /tmp/errors.txt 2> /dev/null
	cp /tmp/chlist chlist_old
else
	rm /tmp/errors.txt 2> /dev/null
fi


# ###################
# CREATE XMLTV FILE #
# ###################

# WORK IN PROGRESS

echo "- FILE CREATION PROCESS -" && echo ""

rm workfile chlist 2> /dev/null


# DOWNLOAD CHANNEL LIST + RYTEC/EIT CONFIG FILES (JSON)
printf "\rRetrieving channel list and config files...          "
cp /tmp/chlist chlist
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/tvp_channels.json > tvp_channels.json
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/tvp_genres.json > tvp_genres.json

# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > tvp_channels
sort -u tvp_channels > /tmp/tvp_channels && mv /tmp/tvp_channels tvp_channels
sed -i 's/></>\n</g;s/<display-name/  &/g' tvp_channels

# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                            "
perl cid_json.pl > tvp_cid.json && rm chlist

# COMBINING ALL EPG PARTS TO ONE FILE
printf "\rCopying JSON files to common file...                 "
cp day/epgdata workfile

# VALIDATE JSON FILE
printf "\rValidating JSON EPG file...                          "
jq -s '{ attributes: map(.attributes) }' workfile > workfile2 && mv workfile2 workfile

# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
perl epg_json2xml.pl > tvp_epg 2>epg_warnings.txt && rm workfile

# SORT BY CID AND START TIME
printf "\rSorting data by channel ID and start time...         "
sed -i 's/\(.*\)\(channel=[^>]*>\)\(.*\)/{\2\1\2\3/g' tvp_epg
sort -u tvp_epg > workfile
sed -i 's/\({channel=[^>]*>\)\(.*\)/\2/g;s/<sub-title lang="en"><\/sub-title>//g;s/></>\n</g;1i\\n<\!-- PROGRAMMES LIST: TVPLAYER UK -->\n' workfile
sed 's/<icon/  <icon/g;s/<title/  <title/g;s/<sub-title/  <sub-title/g;s/<desc/  <desc/g;s/<category/  <category/g;s/<episode/  <episode/g' workfile > tvp_epg && rm workfile

# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat tvp_epg >> tvp_channels && mv tvp_channels tvp && rm tvp_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<tv>' tvp
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" tvp
sed -i '$s/.*/&\n\n<\/tv>/g' tvp
mv tvp tvp.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout tvp.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv tvp.xml tvp_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm tvp_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" tvp.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep "<channel id=" tvp.xml > /tmp/id_check
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
		mv tvp.xml tvp_ERROR.xml
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
