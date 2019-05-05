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

mkdir mani 2> /dev/null && chmod 0777 mani 2> /dev/null

if grep -q "DE" init.json 2> /dev/null
then
	printf "+++ COUNTRY: GERMANY +++\n\n"
fi

if grep -q '"day": "0"' settings.json
then
	printf "EPG Grabber disabled!\n\n"
	exit 0
fi

if ! curl --write-out %{http_code} --silent --output /dev/null https://www.waipu.tv/ | grep -q "200"
then
	printf "Service provider unavailable!\n\n"
	exit 0
fi


# ###################
# LOGIN TO WAIPU.TV #
# ###################

printf "\rLogin to waipu.tv webservice..."

curl -i -s -X POST -H "User-Agent: WAIPU_USER_AGENT" -H "Authorization: Basic YW5kcm9pZENsaWVudDpzdXBlclNlY3JldA==" -H "Content-Type: application/x-www-form-urlencoded" -v --data-urlencode "$(sed '2d' user/userfile)" --data-urlencode "$(sed '1d' user/userfile)" --data-urlencode "grant_type=password" https://auth.waipu.tv/oauth/token > /tmp/login.txt 2> /dev/null

if grep -q '"access_token"' /tmp/login.txt
then
	grep '"access_token"' /tmp/login.txt | jq -r '.access_token' > user/session
	session=$(curl -s -X POST -H "User-Agent: WAIPU_USER_AGENT" -H "Authorization: Bearer $(<user/session)" -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "$(sed '2d' user/userfile)" --data-urlencode "$(sed '1d' user/userfile)" --data-urlencode "grant_type=password" https://auth.waipu.tv/oauth/token 2>/dev/null | jq -r '.access_token')
	printf "\rLogin to waipu.tv webservice... OK!\n\n"
else
	rm -rf user/userfile
	printf "\rLogin to waipu.tv webservice... FAILED!"
	sleep 2s
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
rm /tmp/chlist 2> /dev/null


# ######################
# DOWNLOAD EPG DETAILS #
# ######################

printf "\rDownloading EPG manifest file... "

date1=$(date '+%Y-%m-%d')
date2=$(date -d '1 day' '+%Y-%m-%d')
date3=$(date -d '2 days' '+%Y-%m-%d')
date4=$(date -d '3 days' '+%Y-%m-%d')
date5=$(date -d '4 days' '+%Y-%m-%d')
date6=$(date -d '5 days' '+%Y-%m-%d')
date7=$(date -d '6 days' '+%Y-%m-%d')
date8=$(date -d '7 days' '+%Y-%m-%d')


# ################
# DOWNLOAD DAY 1 #
# ################

if grep -q -E '"day": "1"' settings.json 2> /dev/null
then
	rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
	curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T06:00:00&stopTime='"$date2"'T05:59:59' > /tmp/chlist.gz 2>/tmp/errors.txt
	gzip -d /tmp/chlist.gz 2>/tmp/errors.txt && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist 2>/tmp/errors.txt && jq '.' /tmp/chlist > workfile 2>/tmp/errors.txt
	

# ##################
# DOWNLOAD DAY 1-2 #
# ##################

elif grep -q -E '"day": "2"' settings.json 2> /dev/null
then
	rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
	curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T06:00:00&stopTime='"$date3"'T05:59:59' > /tmp/chlist.gz 2>/tmp/errors.txt
	gzip -d /tmp/chlist.gz 2>/tmp/errors.txt && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist 2>/tmp/errors.txt && jq '.' /tmp/chlist > workfile 2>/tmp/errors.txt


# ##################
# DOWNLOAD DAY 1-3 #
# ##################

elif grep -q -E '"day": "3"' settings.json 2> /dev/null
then
	rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
	curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T06:00:00&stopTime='"$date4"'T05:59:59' > /tmp/chlist.gz 2>/tmp/errors.txt
	gzip -d /tmp/chlist.gz 2>/tmp/errors.txt && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist 2>/tmp/errors.txt && jq '.' /tmp/chlist > workfile 2>/tmp/errors.txt


# ##################
# DOWNLOAD DAY 1-4 #
# ##################

elif grep -q -E '"day": "4"' settings.json 2> /dev/null
then
	rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
	curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T06:00:00&stopTime='"$date5"'T05:59:59' > /tmp/chlist.gz 2>/tmp/errors.txt
	gzip -d /tmp/chlist.gz 2>/tmp/errors.txt && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist 2>/tmp/errors.txt && jq '.' /tmp/chlist > workfile 2>/tmp/errors.txt


# ##################
# DOWNLOAD DAY 1-5 #
# ##################

elif grep -q -E '"day": "5"' settings.json 2> /dev/null
then
	rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
	curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T06:00:00&stopTime='"$date6"'T05:59:59' > /tmp/chlist.gz 2>/tmp/errors.txt
	gzip -d /tmp/chlist.gz 2>/tmp/errors.txt && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist 2>/tmp/errors.txt && jq '.' /tmp/chlist > workfile 2>/tmp/errors.txt


# ##################
# DOWNLOAD DAY 1-6 #
# ##################

elif grep -q -E '"day": "6"' settings.json 2> /dev/null
then
	rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
	curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T06:00:00&stopTime='"$date7"'T05:59:59' > /tmp/chlist.gz 2>/tmp/errors.txt
	gzip -d /tmp/chlist.gz 2>/tmp/errors.txt && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist 2>/tmp/errors.txt && jq '.' /tmp/chlist > workfile 2>/tmp/errors.txt


# ##################
# DOWNLOAD DAY 1-7 #
# ##################

elif grep -q -E '"day": "7"' settings.json 2> /dev/null
then
	rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
	curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T06:00:00&stopTime='"$date8"'T05:59:59' > /tmp/chlist.gz 2>/tmp/errors.txt
	gzip -d /tmp/chlist.gz 2>/tmp/errors.txt && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist 2>/tmp/errors.txt && jq '.' /tmp/chlist > workfile 2>/tmp/errors.txt
fi
	
echo "DONE!" && printf "\n"


#
# SHOW ERROR MESSAGE + ABORT PROCESS IF CHANNEL IDs WERE CHANGED
#

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

# DOWNLOAD CHANNEL LIST + RYTEC/EIT CONFIG FILES (JSON)
printf "\rRetrieving channel list and config files...          "

rm /tmp/chlist /tmp/chlist.gz chlist 2> /dev/null
curl -s -X GET -H "Host: epg.waipu.tv" -H "Connection: keep-alive" -H "Accept: application/vnd.waipu.epg-channels-and-programs-v1+json" -H "Origin: https://play.waipu.tv" -H "Authorization: Bearer $session" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36" -H "Referer: https://play.waipu.tv/programm" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7" 'https://epg.waipu.tv/api/programs?includeRunningAtStartTime=true&startTime='"$date1"'T00:00:00&stopTime='"$date1"'T00:00:01' > /tmp/chlist.gz
gzip -d /tmp/chlist.gz && sed -i 's/.*/{"attributes":&}/g' /tmp/chlist && jq '.' /tmp/chlist > chlist

perl chlist_printer.pl > /tmp/compare.json

curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/wpu_channels.json > wpu_channels.json
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/wpu_genres.json > wpu_genres.json

# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > waipu_channels

# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                            "
perl cid_json.pl > wpu_cid.json

# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
perl epg_json2xml.pl > waipu_epg 2>epg_warnings.txt && rm workfile

# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat waipu_epg >> waipu_channels && mv waipu_channels waipu && rm waipu_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<tv>' waipu
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" waipu
sed -i '$s/.*/&\n\n<\/tv>/g' waipu
mv waipu waipu.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout waipu.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv waipu.xml waipu_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm waipu_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" waipu.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep -q "<channel id=" waipu.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY CHANNEL DATA!" >> errorlog
	fi
	
	if [ -e errorlog ]
	then
		mv waipu.xml waipu_ERROR.xml
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
