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
#  along with zattoo_tvh. If not, see <http://www.gnu.org/licenses/>.


# ################
# INITIALIZATION #
# ################

#
# SETUP ENVIRONMENT
#

mkdir cache 2> /dev/null	# cache
mkdir day 2> /dev/null		# download scripts

if grep -q "DE" init.json 2> /dev/null
then
	printf "+++ COUNTRY: GERMANY +++\n\n"
elif grep -q "CH" init.json 2> /dev/null
then
	printf "+++ COUNTRY: SWITZERLAND +++\n\n"
fi

if grep -q '"day": "0"' settings.json
then
	printf "EPG Grabber disabled!\n\n"
	exit 0
fi

if ! curl --write-out %{http_code} --silent --output /dev/null https://zattoo.com | grep -q "200"
then
	printf "Service provider unavailable!\n\n"
	exit 0
fi


# ######################################
# LOADING COOKIE DATA / GET SESSION ID #
# ######################################

printf "\rLoading cookie data..."

export QT_QPA_PLATFORM=offscreen

if phantomjs -platform offscreen save_page.js https://zattoo.com/login 2>&1 >/tmp/cookie_list | grep -q "This application failed to start"
then
	if phantomjs save_page.js https://zattoo.com/login 2>&1 >/tmp/cookie_list | grep -q "This application failed to start"
	then
		export QT_QPA_PLATFORM=phantom
		if phantomjs -platform phantom save_page.js https://zattoo.com/login 2>&1 >/tmp/cookie_list | grep -q "This application failed to start"
		then
			printf "\rERROR: PhantomJS failed to start!"
			sleep 2s
			exit 1
		fi
	fi
fi

grep "beaker.session.id" /tmp/cookie_list > /tmp/session
rm /tmp/login.txt 2> /dev/null


# #################
# LOGIN TO ZATTOO #
# #################

printf "\rLogin to Zattoo webservice..."
	
session=$(</tmp/session)

curl -i -X POST -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/x-www-form-urlencoded" -v --cookie "$session" --data-urlencode "$(sed '2d' user/userfile)" --data-urlencode "$(sed '1d' user/userfile)" https://zattoo.com/zapi/v2/account/login > /tmp/login.txt 2> /dev/null

if grep -q '"success": true' /tmp/login.txt
then
	rm /tmp/cookie_list
	sed '/Set-cookie/!d' /tmp/login.txt > /tmp/workfile
	sed -i 's/expires.*//g' /tmp/workfile
	sed -i 's/Set-cookie: //g' /tmp/workfile
	sed -i 's/Set-cookie: //g' /tmp/workfile
	tr -d '\n' < /tmp/workfile > user/session
	sed -i 's/; Path.*//g' user/session
	session=$(<user/session)
	printf "\rLogin to Zattoo webservice... OK!\n\n"
else
	rm -rf user/userfile
	printf "\rLogin to Zattoo webservice... FAILED!\n"
	exit 1
fi


#
# DEFINE POWER ID
#

sed 's/, "/\n/g' /tmp/login.txt | grep "power_guide_hash" > /tmp/powerid
sed -i 's/.*: "//g' /tmp/powerid && sed -i 's/.$//g' /tmp/powerid


# ##################
# DOWNLOAD PROCESS #
# ##################

echo "- DOWNLOAD PROCESS -" && echo ""

#
# DELETE OLD FILES
#

printf "\rDeleting old files...                       "

date1=$(date '+%Y%m%d')

rm -rf cache/old_* 2> /dev/null
rm day/day* 2> /dev/null

ls cache | grep "new_" > epglist

until sed '1!d' epglist | grep -q "new_$date1"
do
	if [ -s epglist ]
	then
		rm -rf cache/$(sed '1!d' epglist)
		ls cache > epglist
	else
		echo "new_$date1" > epglist
	fi
done
rm epglist

ls cache | grep "old_" > epglist

until sed '1!d' epglist | grep -q "old_$date1"
do
	if [ -s epglist ]
	then
		rm -rf cache/$(sed '1!d' epglist)
		ls cache > epglist
	else
		echo "old_$date1" > epglist
	fi
done
rm epglist


# ######################
# DOWNLOAD EPG DETAILS #
# ######################

rm day/datafile* 2> /dev/null

session=$(<user/session)
powerid=$(</tmp/powerid)

if date '+%H%M' | grep -q "235[0-9]"
then
	printf "\rWaiting until EPG services are available..."
	sleep 600s
fi

printf "\rDownloading EPG manifest files..."


# ################
# DOWNLOAD DAY 1 #
# ################

if grep -q -E '"day": "[1-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_1
	until tr ' ' '\n' < day/datafile_1  | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)

		date -d '1 day' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)

		date -d '1 day' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_1_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_1_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_1_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_1_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_1_* >> day/datafile_1
	
		if tr ' ' '\n' < day/datafile_1 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 1 - $(date '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_1
fi


# ################
# DOWNLOAD DAY 2 #
# ################

if grep -q -E '"day": "[2-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_2
	until tr ' ' '\n' < day/datafile_2 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '1 day' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '1 day' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '1 day' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '2 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '2 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_2_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_2_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_2_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_2_4 2> /dev/null

		rm /tmp/date*
		cat day/datafile_2_* >> day/datafile_2
	
		if tr ' ' '\n' < day/datafile_2 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 2 - $(date -d '1 day' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_2
fi


# ################
# DOWNLOAD DAY 3 #
# ################

if grep -q -E '"day": "[3-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_3
	until tr ' ' '\n' < day/datafile_3 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '2 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '2 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '2 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '3 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '3 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_3_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_3_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_3_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_3_4 2> /dev/null

		rm /tmp/date*
		cat day/datafile_3_* >> day/datafile_3
		
		if tr ' ' '\n' < day/datafile_3 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 3 - $(date -d '2 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_3
fi


# ################
# DOWNLOAD DAY 4 #
# ################

if grep -q -E '"day": "[4-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_4
	until tr ' ' '\n' < day/datafile_4 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '3 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '3 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '3 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '4 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '4 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_4_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_4_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_4_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_4_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_4_* >> day/datafile_4
		
		if tr ' ' '\n' < day/datafile_4 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 4 - $(date -d '3 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_4
fi


# ################
# DOWNLOAD DAY 5 #
# ################

if grep -q -E '"day": "[5-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_5
	until tr ' ' '\n' < day/datafile_5 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '4 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '4 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '4 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '5 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '5 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_5_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_5_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_5_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_5_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_5_* >> day/datafile_5
		
		if tr ' ' '\n' < day/datafile_5 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 5 - $(date -d '4 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_5
fi


# ################
# DOWNLOAD DAY 6 #
# ################

if grep -q -E '"day": "[6-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_6
	until tr ' ' '\n' < day/datafile_6 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '5 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '5 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '5 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '6 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '6 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_6_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_6_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_6_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_6_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_6_* >> day/datafile_6
		
		if tr ' ' '\n' < day/datafile_6 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 6 - $(date -d '5 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_6
fi


# ################
# DOWNLOAD DAY 7 #
# ################

if grep -q -E '"day": "[7-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_7
	until tr ' ' '\n' < day/datafile_7 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '6 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '6 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '6 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '7 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '7 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_7_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_7_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_7_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_7_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_7_* >> day/datafile_7
		
		if tr ' ' '\n' < day/datafile_7 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 7 - $(date -d '6 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_7
fi


# ################
# DOWNLOAD DAY 8 #
# ################

if grep -q -E '"day": "[8-9]"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_8
	until tr ' ' '\n' < day/datafile_8 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '7 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '7 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '7 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '8 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '8 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_8_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_8_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_8_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_8_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_8_* >> day/datafile_8
		
		if tr ' ' '\n' < day/datafile_8 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 8 - $(date -d '7 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_8
fi


# ################
# DOWNLOAD DAY 9 #
# ################

if grep -q -E '"day": "9"|"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_9
	until tr ' ' '\n' < day/datafile_9 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '8 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '8 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '8 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '9 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '9 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_9_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_9_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_9_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_9_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_9_* >> day/datafile_9
		
		if tr ' ' '\n' < day/datafile_9 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 9 - $(date -d '8 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_9
fi


# #################
# DOWNLOAD DAY 10 #
# #################

if grep -q '"day": "1[0-4]"' settings.json 2> /dev/null
then
	touch day/datafile_10
	until tr ' ' '\n' < day/datafile_10 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '9 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '9 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '9 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '10 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '10 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_10_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_10_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_10_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_10_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_10_* >> day/datafile_10
		
		if tr ' ' '\n' < day/datafile_10 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 10 - $(date -d '9 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_10
fi


# #################
# DOWNLOAD DAY 11 #
# #################

if grep -q '"day": "1[1-4]"' settings.json 2> /dev/null
then
	touch day/datafile_11
	until tr ' ' '\n' < day/datafile_11 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '10 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '10 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '10 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '11 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '11 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_11_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_11_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_11_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_11_4 2> /dev/null

		rm /tmp/date*
		cat day/datafile_11_* >> day/datafile_11
		
		if tr ' ' '\n' < day/datafile_11 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 11 - $(date -d '10 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_11
fi


# #################
# DOWNLOAD DAY 12 #
# #################

if grep -q '"day": "1[2-4]"' settings.json 2> /dev/null
then
	touch day/datafile_12
	until tr ' ' '\n' < day/datafile_12 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '11 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '11 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '11 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '12 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '12 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_12_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_12_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_12_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_12_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_12_* >> day/datafile_12
		
		if tr ' ' '\n' < day/datafile_12 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 12 - $(date -d '11 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_12
fi


# #################
# DOWNLOAD DAY 13 #
# #################

if grep -q '"day": "1[3-4]"' settings.json 2> /dev/null
then
	touch day/datafile_13
	until tr ' ' '\n' < day/datafile_13 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '12 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '12 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '12 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '13 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '13 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_13_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_13_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_13_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_13_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_13_* >> day/datafile_13
		
		if tr ' ' '\n' < day/datafile_13 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 13 - $(date -d '12 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_13
fi


# #################
# DOWNLOAD DAY 14 #
# #################

if grep -q '"day": "14"' settings.json 2> /dev/null
then
	touch day/datafile_14
	until tr ' ' '\n' < day/datafile_14 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
	do
		date -d '13 days' '+%Y-%m-%d 06:00:00' > /tmp/date0
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date0
		date0=$(bash /tmp/date0)

		date -d '13 days' '+%Y-%m-%d 12:00:00' > /tmp/date1
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date1
		date1=$(bash /tmp/date1)
		
		date -d '13 days' '+%Y-%m-%d 18:00:00' > /tmp/date2
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date2
		date2=$(bash /tmp/date2)
		
		date -d '14 days' '+%Y-%m-%d 00:00:00' > /tmp/date3
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date3
		date3=$(bash /tmp/date3)
		
		date -d '14 days' '+%Y-%m-%d 06:00:00' > /tmp/date4
		sed -i 's/.*/#\!\/bin\/bash\ndate -d "&" +%s/g' /tmp/date4
		date4=$(bash /tmp/date4)
		
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date1&start=$date0" > day/datafile_14_1 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date2&start=$date1" > day/datafile_14_2 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date3&start=$date2" > day/datafile_14_3 2> /dev/null
		curl -X GET --cookie "$session" "https://zattoo.com/zapi/v2/cached/program/power_guide/$powerid?end=$date4&start=$date3" > day/datafile_14_4 2> /dev/null
		
		rm /tmp/date*
		cat day/datafile_14_* >> day/datafile_14
		
		if tr ' ' '\n' < day/datafile_14 | sed 's/"success":true/\n&/g' | grep '"success":true' | wc -l | grep -q 4 2> /dev/null
		then :
		else
			echo ""
			echo "- ERROR: FAILED TO LOAD EPG MAIN FILE! -"
			echo "DAY 14 - $(date -d '13 days' '+%Y%m%d'): Failed to check EPG manifest file!"
			echo "Retry in 10 secs..." && echo ""
			sleep 10s
		fi
	done
	
	rm day/datafile_14
fi


#
# CREATE EPG BROADCAST LIST
#

printf "\rCreating EPG lists...                      "

rm /tmp/chlist 2> /dev/null

until grep -q '"channel_groups"' /tmp/chlist 2> /dev/null
do
	curl -X GET --cookie "$session" https://zattoo.com/zapi/v2/cached/channels/$powerid?details=False > /tmp/chlist 2> /dev/null
done

perl chlist_printer.pl > /tmp/compare.json

for time in {1..14..1}
do
	for part in {1..4..1}
	do
		sed "s/dayNUMBER/datafile_${time}_${part}/g" compare_crid.pl > /tmp/compare_crid_day${time}_${part}.pl 2> /dev/null
		perl /tmp/compare_crid_day${time}_${part}.pl 2>/tmp/errors_${time}_${part}.txt > day/daydlnew_${time}_${part}
		cat day/daydlnew_${time}_${part} >> day/daydlnew_${time} 2> /dev/null
		cp day/daydlnew_${time} day/day${time} 2> /dev/null
		rm day/daydlnew_${time}_${part} day/datafile_${time}_${part} 2> /dev/null
		touch day/day${time}
		
		cat /tmp/errors_${time}_${part}.txt >> /tmp/errors.txt 2> /dev/null
	done
done


#
# COPY CACHE FILES TO NEW FOLDER
#

printf "\rUpdating cache setup...                     "

date1=$(date '+%Y%m%d')
date2=$(date -d '1 day' '+%Y%m%d')
date3=$(date -d '2 days' '+%Y%m%d')
date4=$(date -d '3 days' '+%Y%m%d')
date5=$(date -d '4 days' '+%Y%m%d')
date6=$(date -d '5 days' '+%Y%m%d')
date7=$(date -d '6 days' '+%Y%m%d')
date8=$(date -d '7 days' '+%Y%m%d')
date9=$(date -d '8 days' '+%Y%m%d')
date_10=$(date -d '9 days' '+%Y%m%d')
date_11=$(date -d '10 days' '+%Y%m%d')
date_12=$(date -d '11 days' '+%Y%m%d')
date_13=$(date -d '12 days' '+%Y%m%d')
date_14=$(date -d '13 days' '+%Y%m%d')

if ! grep -q "<cache incomplete>" init.txt 2> /dev/null
then
	mv cache/new_$date1 cache/old_$date1 2> /dev/null
	mv cache/new_$date2 cache/old_$date2 2> /dev/null
	mv cache/new_$date3 cache/old_$date3 2> /dev/null
	mv cache/new_$date4 cache/old_$date4 2> /dev/null
	mv cache/new_$date5 cache/old_$date5 2> /dev/null
	mv cache/new_$date6 cache/old_$date6 2> /dev/null
	mv cache/new_$date7 cache/old_$date7 2> /dev/null
	mv cache/new_$date8 cache/old_$date8 2> /dev/null
	mv cache/new_$date9 cache/old_$date9 2> /dev/null
	mv cache/new_$date_10 cache/old_$date_10 2> /dev/null
	mv cache/new_$date_11 cache/old_$date_11 2> /dev/null
	mv cache/new_$date_12 cache/old_$date_12 2> /dev/null
	mv cache/new_$date_13 cache/old_$date_13 2> /dev/null
	mv cache/new_$date_14 cache/old_$date_14 2> /dev/null
	echo "<cache incomplete>" > init.txt
else
	rm -rf cache/new_$date1 cache/new_$date2 cache/new_$date3 cache/new_$date4 cache/new_$date5 cache/new_$date6 cache/new_$date7 cache/new_$date8 cache/new_$date9 cache/new_$date_10 cache/new_$date_11 cache/new_$date_12 cache/new_$date_13 cache/new_$date_14 2> /dev/null
fi

	mkdir cache/new_$date1 2> /dev/null
	mkdir cache/new_$date2 2> /dev/null
	mkdir cache/new_$date3 2> /dev/null
	mkdir cache/new_$date4 2> /dev/null
	mkdir cache/new_$date5 2> /dev/null
	mkdir cache/new_$date6 2> /dev/null
	mkdir cache/new_$date7 2> /dev/null
	mkdir cache/new_$date8 2> /dev/null
	mkdir cache/new_$date9 2> /dev/null
	mkdir cache/new_$date_10 2> /dev/null
	mkdir cache/new_$date_11 2> /dev/null
	mkdir cache/new_$date_12 2> /dev/null
	mkdir cache/new_$date_13 2> /dev/null
	mkdir cache/new_$date_14 2> /dev/null


#
# COMPARING: DATABASE <==> MANIFEST TO FIND DUPLICATES
#

printf "\rPreparing database transmission...             "

find cache/old_$date1 -size 0 -delete 2> /dev/null
find cache/old_$date2 -size 0 -delete 2> /dev/null
find cache/old_$date3 -size 0 -delete 2> /dev/null
find cache/old_$date4 -size 0 -delete 2> /dev/null
find cache/old_$date5 -size 0 -delete 2> /dev/null
find cache/old_$date6 -size 0 -delete 2> /dev/null
find cache/old_$date7 -size 0 -delete 2> /dev/null
find cache/old_$date8 -size 0 -delete 2> /dev/null
find cache/old_$date9 -size 0 -delete 2> /dev/null
find cache/old_$date_10 -size 0 -delete 2> /dev/null
find cache/old_$date_11 -size 0 -delete 2> /dev/null
find cache/old_$date_12 -size 0 -delete 2> /dev/null
find cache/old_$date_13 -size 0 -delete 2> /dev/null
find cache/old_$date_14 -size 0 -delete 2> /dev/null

ls cache/old_$date1 > compare 2> /dev/null
comm -12 <(sort -u day/day1 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_1
ls cache/old_$date2 > compare 2> /dev/null
comm -12 <(sort -u day/day2 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_2
ls cache/old_$date3 > compare 2> /dev/null
comm -12 <(sort -u day/day3 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_3
ls cache/old_$date4 > compare 2> /dev/null
comm -12 <(sort -u day/day4 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_4
ls cache/old_$date5 > compare 2> /dev/null
comm -12 <(sort -u day/day5 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_5
ls cache/old_$date6 > compare 2> /dev/null
comm -12 <(sort -u day/day6 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_6
ls cache/old_$date7 > compare 2> /dev/null
comm -12 <(sort -u day/day7 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_7
ls cache/old_$date8 > compare 2> /dev/null
comm -12 <(sort -u day/day8 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_8
ls cache/old_$date9 > compare 2> /dev/null
comm -12 <(sort -u day/day9 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_9
ls cache/old_$date_10 > compare 2> /dev/null
comm -12 <(sort -u day/day10 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_10
ls cache/old_$date_11 > compare 2> /dev/null
comm -12 <(sort -u day/day11 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_11
ls cache/old_$date_12 > compare 2> /dev/null
comm -12 <(sort -u day/day12 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_12
ls cache/old_$date_13 > compare 2> /dev/null
comm -12 <(sort -u day/day13 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_13
ls cache/old_$date_14 > compare 2> /dev/null
comm -12 <(sort -u day/day14 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_14
rm compare

for x in {1..14..1}
do
	sed -i "s/.*/cp cache\/old_day${x}\/& cache\/new_day${x}\/&/g" day/daydpl_${x}
done

cat day/daydpl_1 <(echo) day/daydpl_2 <(echo) day/daydpl_3 <(echo) day/daydpl_4 <(echo) day/daydpl_5 <(echo) day/daydpl_6 <(echo) day/daydpl_7 <(echo) day/daydpl_8 <(echo) day/daydpl_9 <(echo) day/daydpl_10 <(echo) day/daydpl_11 <(echo) day/daydpl_12 <(echo) day/daydpl_13 <(echo) day/daydpl_14 <(echo) > day/common

sed -i '/^$/d' day/common
printf "\n$(echo $(wc -l < day/common)) broadcast files found!\n\n"

if [ $(wc -l < day/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < day/common) / 7)))
	
	split --lines=$(( $number + 1 )) --numeric-suffixes day/common day/day

	rm day/common 2> /dev/null
else	
	mv day/common day/day00
fi


#
# CREATE STATUS BAR FOR COPY/PASTE SCRIPT
#

x=$(wc -l < day/day00)
y=20
h=100

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
	echo "Progress [                    ]   0%% ' day/day00" >> progressbar

	# 5%
	echo "sed -i '$z5 i\\" >> progressbar
	echo "Progress [#                   ]   5%% ' day/day00" >> progressbar

	# 10%
	echo "sed -i '$z10 i\\" >> progressbar
	echo "Progress [##                  ]  10%% ' day/day00" >> progressbar
	
	# 15%
	echo "sed -i '$z15 i\\" >> progressbar
	echo "Progress [###                 ]  15%% ' day/day00" >> progressbar

	# 20%
	echo "sed -i '$z20 i\\" >> progressbar
	echo "Progress [####                ]  20%% ' day/day00" >> progressbar

	# 25%
	echo "sed -i '$z25 i\\" >> progressbar
	echo "Progress [#####               ]  25%% ' day/day00" >> progressbar

	# 30%
	echo "sed -i '$z30 i\\" >> progressbar
	echo "Progress [######              ]  30%% ' day/day00" >> progressbar

	# 35%
	echo "sed -i '$z35 i\\" >> progressbar
	echo "Progress [#######             ]  35%% ' day/day00" >> progressbar

	# 40%
	echo "sed -i '$z40 i\\" >> progressbar
	echo "Progress [########            ]  40%% ' day/day00" >> progressbar

	# 45%
	echo "sed -i '$z45 i\\" >> progressbar
	echo "Progress [#########           ]  45%% ' day/day00" >> progressbar

	# 50%
	echo "sed -i '$z50 i\\" >> progressbar
	echo "Progress [##########          ]  50%% ' day/day00" >> progressbar

	# 55%
	echo "sed -i '$z55 i\\" >> progressbar
	echo "Progress [###########         ]  55%% ' day/day00" >> progressbar

	# 60%
	echo "sed -i '$z60 i\\" >> progressbar
	echo "Progress [############        ]  60%% ' day/day00" >> progressbar

	# 65%
	echo "sed -i '$z65 i\\" >> progressbar
	echo "Progress [#############       ]  65%% ' day/day00" >> progressbar

	# 70%
	echo "sed -i '$z70 i\\" >> progressbar
	echo "Progress [##############      ]  70%% ' day/day00" >> progressbar

	# 75%
	echo "sed -i '$z75 i\\" >> progressbar
	echo "Progress [###############     ]  75%% ' day/day00" >> progressbar

	# 80%
	echo "sed -i '$z80 i\\" >> progressbar
	echo "Progress [################    ]  80%% ' day/day00" >> progressbar

	# 85%
	echo "sed -i '$z85 i\\" >> progressbar
	echo "Progress [#################   ]  85%% ' day/day00" >> progressbar

	# 90%
	echo "sed -i '$z90 i\\" >> progressbar
	echo "Progress [##################  ]  90%% ' day/day00" >> progressbar

	# 95%
	echo "sed -i '$z95 i\\" >> progressbar
	echo "Progress [################### ]  95%% ' day/day00" >> progressbar

	# 100%
	echo "sed -i '\$i\\" >> progressbar
	echo "Progress [####################] 100%% ' day/day00" >> progressbar

	sed -i 's/ i/i/g' progressbar
	bash progressbar
	sed -i -e 's/Progress/printf "\\rProgress/g' -e '/Progress/s/.*/&"/g' day/day00
	rm progressbar
fi


#
# CREATE COPY/PASTE SCRIPTS
#

for time in {0..8..1}
do	
	sed -i '1s/.*/#\!\/bin\/bash\n&/g' day/day0${time} 2> /dev/null
	sed -i 's/; then /\nthen\n  /g;s/; fi/\nfi/g' day/day0${time} 2> /dev/null

	sed -i "s/new_day10/new_$date_10/g;s/old_day10/old_$date_10/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day11/new_$date_11/g;s/old_day11/old_$date_11/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day12/new_$date_12/g;s/old_day12/old_$date_12/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day13/new_$date_13/g;s/old_day13/old_$date_13/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day14/new_$date_14/g;s/old_day14/old_$date_14/g" day/day0${time} 2> /dev/null
	
	sed -i "s/new_day1/new_$date1/g;s/old_day1/old_$date1/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day2/new_$date2/g;s/old_day2/old_$date2/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day3/new_$date3/g;s/old_day3/old_$date3/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day4/new_$date4/g;s/old_day4/old_$date4/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day5/new_$date5/g;s/old_day5/old_$date5/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day6/new_$date6/g;s/old_day6/old_$date6/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day7/new_$date7/g;s/old_day7/old_$date7/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day8/new_$date8/g;s/old_day8/old_$date8/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day9/new_$date9/g;s/old_day9/old_$date9/g" day/day0${time} 2> /dev/null
done


#
# COPY/PASTE EPG DETAILS
#

printf "\rLoading cached data files into new database..."
echo ""

for a in {0..8..1}
do
	bash day/day0${a} 2> /dev/null &
done
wait

rm day/day0* init.txt 2> /dev/null
	
echo "DONE!" && printf "\n"


#
# SHOW ERROR MESSAGE + ABORT PROCESS IF CHANNEL IDs WERE CHANGED
#

sed -i '/Died at \/tmp\/compare_crid_day/d' /tmp/errors.txt
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
	echo "Channel IDs updated, affected EPG cache data removed."
	echo ""
	echo "======================================================="
	echo ""
	
	rm /tmp/errors.txt 2> /dev/null
	cp /tmp/chlist chlist_old
else
	rm /tmp/errors.txt 2> /dev/null
fi


#
# COMPARING: DATABASE <==> MANIFEST TO FIND NEW FILES
#

printf "\rPreparing download...                              "

ls cache/new_$date1 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_1 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_1 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_1
ls cache/new_$date2 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_2 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_2 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_2
ls cache/new_$date3 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_3 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_3 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_3
ls cache/new_$date4 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_4 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_4 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_4
ls cache/new_$date5 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_5 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_5 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_5
ls cache/new_$date6 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_6 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_6 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_6
ls cache/new_$date7 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_7 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_7 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_7
ls cache/new_$date8 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_8 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_8 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_8
ls cache/new_$date9 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_9 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_9 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_9
ls cache/new_$date_10 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_10 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_10 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_10
ls cache/new_$date_11 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_11 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_11 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_11
ls cache/new_$date_12 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_12 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_12 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_12
ls cache/new_$date_13 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_13 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_13 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_13
ls cache/new_$date_14 > compare 2> /dev/null && sed -i 's/_NEW_ID//g' day/daydlnew_14 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_14 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_14
rm compare

for x in {1..14..1}
do
	sed -i "s/.*/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=&+ | grep '+t+: +' > cache\/new_day${x}\/&/g" day/daynew_${x}
	sed -i 's/+/"/g' day/daynew_${x}
done

cat day/daynew_1 <(echo) day/daynew_2 <(echo) day/daynew_3 <(echo) day/daynew_4 <(echo) day/daynew_5 <(echo) day/daynew_6 <(echo) day/daynew_7 <(echo) day/daynew_8 <(echo) day/daynew_9 <(echo) day/daynew_10 <(echo) day/daynew_11 <(echo) day/daynew_12 <(echo) day/daynew_13 <(echo) day/daynew_14 <(echo) > day/common

sed -i '/^$/d' day/common
printf "\n$(echo $(wc -l < day/common)) broadcast files to be downloaded!\n\n"

mv day/common day/day00


#
# CREATE STATUS BAR FOR DOWNLOAD SCRIPT
#

x=$(wc -l < day/day00)
y=20
h=100

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
	echo "Progress [                    ]   0%%'  day/day00" >> progressbar

	# 5%
	echo "sed -i '$z5 i\\" >> progressbar
	echo "Progress [#                   ]   5%% ' day/day00" >> progressbar

	# 10%
	echo "sed -i '$z10 i\\" >> progressbar
	echo "Progress [##                  ]  10%% ' day/day00" >> progressbar
	
	# 15%
	echo "sed -i '$z15 i\\" >> progressbar
	echo "Progress [###                 ]  15%% ' day/day00" >> progressbar

	# 20%
	echo "sed -i '$z20 i\\" >> progressbar
	echo "Progress [####                ]  20%% ' day/day00" >> progressbar

	# 25%
	echo "sed -i '$z25 i\\" >> progressbar
	echo "Progress [#####               ]  25%% ' day/day00" >> progressbar

	# 30%
	echo "sed -i '$z30 i\\" >> progressbar
	echo "Progress [######              ]  30%% ' day/day00" >> progressbar

	# 35%
	echo "sed -i '$z35 i\\" >> progressbar
	echo "Progress [#######             ]  35%% ' day/day00" >> progressbar

	# 40%
	echo "sed -i '$z40 i\\" >> progressbar
	echo "Progress [########            ]  40%% ' day/day00" >> progressbar

	# 45%
	echo "sed -i '$z45 i\\" >> progressbar
	echo "Progress [#########           ]  45%% ' day/day00" >> progressbar

	# 50%
	echo "sed -i '$z50 i\\" >> progressbar
	echo "Progress [##########          ]  50%% ' day/day00" >> progressbar

	# 55%
	echo "sed -i '$z55 i\\" >> progressbar
	echo "Progress [###########         ]  55%% ' day/day00" >> progressbar

	# 60%
	echo "sed -i '$z60 i\\" >> progressbar
	echo "Progress [############        ]  60%% ' day/day00" >> progressbar

	# 65%
	echo "sed -i '$z65 i\\" >> progressbar
	echo "Progress [#############       ]  65%% ' day/day00" >> progressbar

	# 70%
	echo "sed -i '$z70 i\\" >> progressbar
	echo "Progress [##############      ]  70%% ' day/day00" >> progressbar

	# 75%
	echo "sed -i '$z75 i\\" >> progressbar
	echo "Progress [###############     ]  75%% ' day/day00" >> progressbar

	# 80%
	echo "sed -i '$z80 i\\" >> progressbar
	echo "Progress [################    ]  80%% ' day/day00" >> progressbar

	# 85%
	echo "sed -i '$z85 i\\" >> progressbar
	echo "Progress [#################   ]  85%% ' day/day00" >> progressbar

	# 90%
	echo "sed -i '$z90 i\\" >> progressbar
	echo "Progress [##################  ]  90%% ' day/day00" >> progressbar

	# 95%
	echo "sed -i '$z95 i\\" >> progressbar
	echo "Progress [################### ]  95%% ' day/day00" >> progressbar

	# 100%
	echo "sed -i '\$i\\" >> progressbar
	echo "Progress [####################] 100%% ' day/day00" >> progressbar

	sed -i 's/ i/i/g' progressbar
	bash progressbar
	sed -i -e 's/Progress/printf "\\rProgress/g' -e '/Progress/s/.*/&"/g' day/day00
	rm progressbar
fi


#
# CREATE DOWNLOAD SCRIPTS
#

sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" day/day00 2> /dev/null
sed -i '/curl/s/ > / \\\n  > /g' day/day00 2> /dev/null
	
sed -i "s/new_day10/new_$date_10/g;s/old_day10/old_$date_10/g" day/day00 2> /dev/null
sed -i "s/new_day11/new_$date_11/g;s/old_day11/old_$date_11/g" day/day00 2> /dev/null
sed -i "s/new_day12/new_$date_12/g;s/old_day12/old_$date_12/g" day/day00 2> /dev/null
sed -i "s/new_day13/new_$date_13/g;s/old_day13/old_$date_13/g" day/day00 2> /dev/null
sed -i "s/new_day14/new_$date_14/g;s/old_day14/old_$date_14/g" day/day00 2> /dev/null
	
sed -i "s/new_day1/new_$date1/g;s/old_day1/old_$date1/g" day/day00 2> /dev/null
sed -i "s/new_day2/new_$date2/g;s/old_day2/old_$date2/g" day/day00 2> /dev/null
sed -i "s/new_day3/new_$date3/g;s/old_day3/old_$date3/g" day/day00 2> /dev/null
sed -i "s/new_day4/new_$date4/g;s/old_day4/old_$date4/g" day/day00 2> /dev/null
sed -i "s/new_day5/new_$date5/g;s/old_day5/old_$date5/g" day/day00 2> /dev/null
sed -i "s/new_day6/new_$date6/g;s/old_day6/old_$date6/g" day/day00 2> /dev/null
sed -i "s/new_day7/new_$date7/g;s/old_day7/old_$date7/g" day/day00 2> /dev/null
sed -i "s/new_day8/new_$date8/g;s/old_day8/old_$date8/g" day/day00 2> /dev/null
sed -i "s/new_day9/new_$date9/g;s/old_day9/old_$date9/g" day/day00 2> /dev/null


#
# DOWNLOAD EPG DETAILS
#

printf "\rDownloading EPG details...                 "
echo ""

bash day/day00 2> /dev/null

rm day/* 2> /dev/null

echo  "DONE!" && printf "\n"


# ###############
# LOOP DOWNLOAD #
# ###############

# DAY 1
if grep -q -E '"day": "[1-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date1 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date1\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 1 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 2
if grep -q -E '"day": "[2-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date2 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date2\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 2 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 3
if grep -q -E '"day": "[3-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date3 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date3\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 3 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 4
if grep -q -E '"day": "[4-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date4 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date4\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 4 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 5
if grep -q -E '"day": "[5-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date5 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date5\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 5 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 6
if grep -q -E '"day": "[6-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date6 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date6\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 6 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 7
if grep -q -E '"day": "[7-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date7 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date7\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 7 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 8
if grep -q -E '"day": "[8-9]"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date8 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date8\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 8 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 9
if grep -q -E '"day": "9"|"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date9 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date9\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY 9 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 10
if grep -q '"day": "1[0-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date_10 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date_10\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY10 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 11
if grep -q '"day": "1[1-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date_11 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date_11\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY11 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 12
if grep -q '"day": "1[2-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date_12 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date_12\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY12 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 13
if grep -q '"day": "1[3-4]"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date_13 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date_13\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY13 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

# DAY 14
if grep -q '"day": "14"' settings.json
then
	i=1

	while [ $i -le 5 ]
	do
	  sleep 0.4s
	  find cache/new_$date_14 -size 0 -print > /tmp/missings 2> /dev/null
	  sed -i "s/\(cache\/new_$date_14\/\)\(.*\)/curl -X GET --cookie +\$session+ +https:\/\/\zattoo.com\/zapi\/v2\/cached\/program\/power_details\/$powerid?program_ids=\2+ | grep '+t+: +' > \1\2/g" /tmp/missings
	  sed -i 's/+/"/g' /tmp/missings
	  files=$(echo $(wc -l < /tmp/missings))
	  printf "\rDownloading missing files... [ DAY14 LOOP $i FILES: $files ]"
	  sed -i "1s/.*/#\!\/bin\/bash\npowerid=\$(<\/tmp\/powerid)\nsession=\$(<user\/session)\n&/g" /tmp/missings 2> /dev/null
	  bash /tmp/missings 2> /dev/null
	  ((i++))
	done
fi

printf "\rDownloading missing files... OK!                            \n\n"


# ###################
# CREATE XMLTV FILE #
# ###################

# WORK IN PROGRESS

echo "- FILE CREATION PROCESS -" && echo ""

rm workfile chlist 2> /dev/null

# DOWNLOAD CHANNEL LIST + RYTEC/EIT CONFIG FILES (JSON)
printf "\rRetrieving channel list and config files...          "

until grep -q '"channel_groups"' chlist 2> /dev/null
do
	curl -X GET --cookie "$session" https://zattoo.com/zapi/v2/cached/channels/$powerid?details=False > chlist 2> /dev/null
done
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/ztt_channels.json > ztt_channels.json
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/ztt_genres.json > ztt_genres.json

# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > zattoo_channels
sort -u zattoo_channels > /tmp/zattoo_channels && mv /tmp/zattoo_channels zattoo_channels
sed -i 's/></>\n</g;s/<display-name/  &/g' zattoo_channels

# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                            "
perl cid_json.pl > ztt_cid.json && rm chlist

# COMBINING ALL EPG PARTS TO ONE FILE
printf "\rCopying JSON files to common file...                 "

cat cache/new_$date1/* > workfile 2> /dev/null
cat cache/new_$date2/* >> workfile 2> /dev/null
cat cache/new_$date3/* >> workfile 2> /dev/null
cat cache/new_$date4/* >> workfile 2> /dev/null
cat cache/new_$date5/* >> workfile 2> /dev/null
cat cache/new_$date6/* >> workfile 2> /dev/null
cat cache/new_$date7/* >> workfile 2> /dev/null
cat cache/new_$date8/* >> workfile 2> /dev/null
cat cache/new_$date9/* >> workfile 2> /dev/null
cat cache/new_$date_10/* >> workfile 2> /dev/null
cat cache/new_$date_11/* >> workfile 2> /dev/null
cat cache/new_$date_12/* >> workfile 2> /dev/null
cat cache/new_$date_13/* >> workfile 2> /dev/null
cat cache/new_$date_14/* >> workfile 2> /dev/null

# SORT BY CID AND START TIME
printf "\rSorting data by channel ID and start time...         "
sed -i 's/{"success": true, "programs": \[{\(.*\)\("cid": "[^"]*",\)\(.*\)\("s": [^,]*,\)\(.*\)}\]}/{"attributes":{\2\4\1\3\5}}/g' workfile
sort -u workfile > workfile2 && mv workfile2 workfile

# VALIDATE JSON FILE
printf "\rValidating JSON EPG file...                          "
jq -s '{ attributes: map(.attributes) }' workfile > workfile2 && mv workfile2 workfile

# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
perl epg_json2xml.pl > zattoo_epg 2>epg_warnings.txt && rm workfile

# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat zattoo_epg >> zattoo_channels && mv zattoo_channels zattoo && rm zattoo_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<tv>' zattoo
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" zattoo
sed -i '$s/.*/&\n\n<\/tv>/g' zattoo
mv zattoo zattoo.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout zattoo.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv zattoo.xml zattoo_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm zattoo_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" zattoo.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep -q "<channel id=" zattoo.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY CHANNEL DATA!" >> errorlog
	fi
	
	if [ -e errorlog ]
	then
		mv zattoo.xml zattoo_ERROR.xml
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
