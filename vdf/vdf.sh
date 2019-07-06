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


# ################
# INITIALIZATION #
# ################

#
# SETUP ENVIRONMENT
#

mkdir cache 2> /dev/null	# cache
mkdir day 2> /dev/null		# download scripts
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

if ! curl --write-out %{http_code} --silent --output /dev/null https://tv-manager.vodafone.de/tv-manager/ | grep -q "200"
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

printf "\rDeleting old files...                       "

rm -rf cache/ 2> /dev/null
rm -rf day/ 2> /dev/null
rm -rf mani/ 2> /dev/null
rm /tmp/epg_workfile 2> /dev/null
rm /tmp/workfile 2> /dev/null
rm /tmp/workfile2 2> /dev/null

mkdir cache 2> /dev/null
mkdir day 2> /dev/null
mkdir mani 2> /dev/null

#
# LOADING MANIFEST FILES
#

printf "\rFetching channel list... "
curl -s https://tv-manager.vodafone.de/tv-manager/backend/auth-service/proxy/epg-data-service/epg/tv/channels > /tmp/chlist
jq '.' /tmp/chlist > /tmp/workfile
sed '1s/\[/{"items":[/g;$s/\]/]}/g' /tmp/workfile > /tmp/chlist
cp /tmp/workfile /tmp/chlist

printf "\rChecking manifest files... "
perl chlist_printer.pl > /tmp/compare.json
perl url_printer.pl 2>errors.txt | sed '/DUMMY/d' > mani/common
printf "\n$(echo $(wc -l < mani/common)) manifest file(s) to be downloaded!\n\n"

if [ $(wc -l < mani/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < mani/common) / 7)))
	
	split -l $number --numeric-suffixes mani/common mani/day

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
			ftd=$(wc -l < mani/common) ;
			status=$(echo "$df/$ftd*100-2" | bc -l |sed -r 's/([^\.]*)\..*/\1/') ;
			if [[ $status -gt 0 && $status -lt 5 || $status -eq 0 ]]; then bar="$z5"; elif [[ $status -gt 5 && $status -lt 10 ]]; then bar="$z5"; elif [[ $status -gt 10 && $status -lt 15 ]] ; then bar="$z10"; elif [[ $status -gt 15 && $status -lt 20 ]] ; then bar="$z15"; elif [[ $status -gt 20 && $status -lt 25 ]] ; then bar="$z20"; elif [[ $status -gt 25 && $status -lt 30 ]] ; then bar="$z25"; elif [[ $status -gt 30 && $status -lt 35 ]] ; then bar="$z30"; elif [[ $status -gt 35 && $status -lt 40 ]] ; then bar="$z35"; elif [[ $status -gt 40 && $status -lt 45 ]] ; then bar="$z40"; elif [[ $status -gt 40 && $status -lt 50 ]] ; then bar="$z45"; elif [[ $status -gt 50 && $status -lt 55 ]] ; then bar="$z50"; elif [[ $status -gt 55 && $status -lt 60 ]] ; then bar="$z55"; elif [[ $status -gt 60 && $status -lt 65 ]] ; then bar="$z60"; elif [[ $status -gt 60 && $status -lt 70 ]] ; then bar="$z65"; elif [[ $status -gt 70 && $status -lt 75 ]] ; then bar="$z70"; elif [[ $status -gt 70 && $status -lt 80 ]] ; then bar="$z75"; elif [[ $status -gt 80 && $status -lt 85 ]] ; then bar="$z80"; elif [[ $status -gt 85 && $status -lt 90 ]] ; then bar="$z85"; elif [[ $status -gt 90 && $status -lt 95 ]] ; then bar="$z90"; elif [[ $status -gt 95 && $status -lt 100 ]] ; then bar="$z95"; elif [ $status -eq 100 ] ; then bar="$z100";fi

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

printf "\rDownloading manifest files..."
echo ""

status_manifest_download &

for a in {0..8..1}
do
bash mani/day0${a} 2> /dev/null  & 
done
wait

rm mani/day*
rm mani/common

printf "\rProgress [####################]  100%% "
echo "DONE!" && printf "\n"

#
# CREATE EPG BROADCAST LIST
#

printf "\rCreating EPG lists...                      "

rm /tmp/manifile.json 2> /dev/null
sed -i -e 2c'"Broadcastitem": [' mani/*
sed -i -e ':a;N;$!ba;s/\n//g' mani/*
cat mani/* > /tmp/manifile.json
jq -s '.' /tmp/manifile.json > /tmp/workfile 2>>errors.txt
sed -i '1s/\[/{ "attributes":[/g;$s/\]/&}/g' /tmp/workfile
perl compare_crid.pl > day/daydlnew


#
# SHOW ERROR MESSAGE + ABORT PROCESS IF CHANNEL IDs WERE CHANGED
#

sed -i '/Died at \/tmp\/compare_crid_day/d' errors.txt
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
	echo "Channel IDs updated, affected EPG cache data removed."
	echo ""
	echo "======================================================="
	echo ""
	
	rm errors.txt 2> /dev/null
	cp /tmp/chlist chlist_old
else
	rm errors.txt 2> /dev/null
fi


#
# DOWNLOAD EPG DETAILS
#

printf "\rPreparing multithreaded download...                   "

sed "s/.*/curl --connect-timeout 2 --max-time 10 --retry 8 --retry-delay 0 --retry-max-time 5 -s 'https:\/\/tv-manager.vodafone.de\/tv-manager\/backend\/auth-service\/proxy\/epg-data-service\/epg\/tv\/data\/item\/&' | grep 'channelId' > cache\/&/g" day/daydlnew > day/common

sed -i '/^$/d' day/common
printf "\n$(echo $(wc -l < day/common)) broadasts files to be downloaded!\n\n"

if [ $(wc -l < day/common) -ge 32 ]
then
	number=$(echo $(( $(wc -l < day/common) / 32)))

	split -l $number --numeric-suffixes day/common day/day

else
	cp day/common day/day00
fi


#
# CREATE STATUS BAR FOR DOWNLOAD SCRIPT
#

function status_detail_download { 
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

			df=$(find cache -type f | wc -l) ;
			ftd=$(wc -l < day/common) ;
			status=$(echo "$df/$ftd*100" | bc -l |sed -r 's/([^\.]*)\..*/\1/') ;
			if [[ $status -gt 0 && $status -lt 5 || $status -eq 0 ]]; then bar="$z5"; elif [[ $status -gt 5 && $status -lt 10 ]]; then bar="$z5"; elif [[ $status -gt 10 && $status -lt 15 ]] ; then bar="$z10"; elif [[ $status -gt 15 && $status -lt 20 ]] ; then bar="$z15"; elif [[ $status -gt 20 && $status -lt 25 ]] ; then bar="$z20"; elif [[ $status -gt 25 && $status -lt 30 ]] ; then bar="$z25"; elif [[ $status -gt 30 && $status -lt 35 ]] ; then bar="$z30"; elif [[ $status -gt 35 && $status -lt 40 ]] ; then bar="$z35"; elif [[ $status -gt 40 && $status -lt 45 ]] ; then bar="$z40"; elif [[ $status -gt 40 && $status -lt 50 ]] ; then bar="$z45"; elif [[ $status -gt 50 && $status -lt 55 ]] ; then bar="$z50"; elif [[ $status -gt 55 && $status -lt 60 ]] ; then bar="$z55"; elif [[ $status -gt 60 && $status -lt 65 ]] ; then bar="$z60"; elif [[ $status -gt 60 && $status -lt 70 ]] ; then bar="$z65"; elif [[ $status -gt 70 && $status -lt 75 ]] ; then bar="$z70"; elif [[ $status -gt 70 && $status -lt 80 ]] ; then bar="$z75"; elif [[ $status -gt 80 && $status -lt 85 ]] ; then bar="$z80"; elif [[ $status -gt 85 && $status -lt 90 ]] ; then bar="$z85"; elif [[ $status -gt 90 && $status -lt 95 ]] ; then bar="$z90"; elif [[ $status -gt 95 && $status -lt 100 ]] ; then bar="$z95"; elif [ $status -eq 100 ] ; then bar="$z100";fi

			printf "\rProgress $bar  $status%% ";                                  
			status_detail_download ;
        fi
        }


#
# CREATE DOWNLOAD SCRIPTS
#

for time in {0..33..1}
do	
	sed -i '1s/.*/#\!\/bin\/bash\n&/g' day/day0${time} 2> /dev/null & sed -i '1s/.*/#\!\/bin\/bash\n&/g' day/day0${time} 2> /dev/null 
done


#
# DOWNLOAD EPG DETAILS
#

printf "\rDownloading EPG details...                 "
echo ""

status_detail_download &

for a in {0..33..1}
do
	bash day/day0${a} 2> /dev/null & bash day/day${a} 2> /dev/null & 
done
wait

rm day/*

printf "\rProgress [####################]  100%% "
echo  "DONE!" && printf "\n"

#
# EXPORT 0BYTE EPGDETAILS AND TRY TO REDOWNLOAD
#

find cache -size 0 | sed 's/cache\///g' >missingbroadcasts

if [ -s missingbroadcasts ]
then
	echo  "Missing Broadcastfiles Detected" && printf "\n"
	printf "\rWaiting for 10 Seconds"
	sleep 10
	printf "\rPreparing Broadcastdatabase (Vodafone hate Screen-Scrapper)...                 "
	echo ""
	find cache -size 0 | sed 's/cache\///g' >day/daydlnew
	sed "s/.*/curl --connect-timeout 2 --max-time 10 --retry 8 --retry-delay 0 --retry-max-time 5 -s 'https:\/\/tv-manager.vodafone.de\/tv-manager\/backend\/auth-service\/proxy\/epg-data-service\/epg\/tv\/data\/item\/&' | grep 'channelId' > cache\/&/g" day/daydlnew > day/common
	sed -i '1s/.*/#\!\/bin\/bash\n&/g' day/common 2> /dev/null
	sed -i '/^$/d' day/common
	printf "\n$(echo $(wc -l < day/common)) missing Broadastsfiles to be downloaded!\n\n"
	bash day/common 2> /dev/null & wait
	find cache -size 0 | sed 's/cache\///g' >missingbroadcasts
	if [ -s missingbroadcasts ]
	then
		sed 's/.*/\[ EPG WARNING ] FAILED TO DOWNLOAD BROADCASTFILES &/g' missingbroadcasts >broadcast_warnings.txt
	fi		
fi

rm missingbroadcasts
rm day/* 2> /dev/null

echo  "DONE!" && printf "\n"

# ###################
# CREATE XMLTV FILE #
# ###################

# WORK IN PROGRESS

echo "- FILE CREATION PROCESS -" && echo ""

rm /tmp/workfile chlist 2> /dev/null


# DOWNLOAD CHANNEL LIST + RYTEC/EIT CONFIG FILES (JSON)
printf "\rRetrieving channel list and config files...          "
curl -s https://tv-manager.vodafone.de/tv-manager/backend/auth-service/proxy/epg-data-service/epg/tv/channels > /tmp/chlist
jq '.' /tmp/chlist > /tmp/workfile
sed '1s/\[/{"items":[/g;$s/\]/]}/g' /tmp/workfile > /tmp/chlist
cp /tmp/chlist chlist
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/vdf_channels.json > vdf_channels.json
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/vdf_genres.json > vdf_genres.json


# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > vodafone_channels
sort -u vodafone_channels > /tmp/vodafone_channels && mv /tmp/vodafone_channels vodafone_channels
sed -i 's/></>\n</g;s/<display-name/  &/g' vodafone_channels


# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                            "
perl cid_json.pl > vdf_cid.json && rm chlist


# COMBINING ALL EPG PARTS TO ONE FILE
printf "\rCopying JSON files to common file...                 "
find cache/ -type f -print0 | xargs -0 cat >/tmp/workfile 2> /dev/null

# SORT BY CID AND START TIME
printf "\rSorting data by channel ID and start time...         "
sed -i 's/\"startDateTimeMillis\"/~\"startDateTimeMillis\"/g' /tmp/workfile 2> /dev/null
sed -i 's/\"channelId\"/~\"channelId\"/g' /tmp/workfile 2> /dev/null
sort -t "~" -k 2 /tmp/workfile >/tmp/workfile2 2> /dev/null 
sort -t "~" -k 3 /tmp/workfile2 >/tmp/workfile 2> /dev/null
sed -i 's/~\"startDateTimeMillis\"/\"startDateTimeMillis\"/g' /tmp/workfile 2> /dev/null
sed -i 's/~\"channelId\"/\"channelId\"/g' /tmp/workfile 2> /dev/null


# VALIDATE JSON FILE
printf "\rValidating JSON EPG file...                          "
nice -n 15 jq -s '.' /tmp/workfile > /tmp/epg_workfile 2>>errors.txt
nice -n 15 sed -i '1s/\[/{ "attributes":[/g;$s/\]/&}/g' /tmp/epg_workfile


# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
perl epg_json2xml.pl > vodafone_epg 2>epg_warnings.txt && rm /tmp/epg_workfile && rm /tmp/workfile && rm /tmp/workfile2


# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat vodafone_epg >> vodafone_channels && mv vodafone_channels vodafone && rm vodafone_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<tv>' vodafone
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" vodafone
sed -i '$s/.*/&\n\n<\/tv>/g' vodafone
mv vodafone vodafone.xml


# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout vodafone.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv vodafone.xml vodafone_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm vodafone_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" vodafone.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep -q "<channel id=" vodafone.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY CHANNEL DATA!" >> errorlog
	fi
	
	if [ -e errorlog ]
	then
		mv vodafone.xml vodafone_ERROR.xml
		cat errorlog >> warnings.txt
	else
		rm errorlog 2> /dev/null
	fi
fi


# SHOW WARNINGS
cat broadcast_warnings.txt >> warnings.txt && rm broadcast_warnings.txt
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
