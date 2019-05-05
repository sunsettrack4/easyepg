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

mkdir mani 2> /dev/null		# manifest files
mkdir day 2> /dev/null		# download scripts
mkdir cache 2> /dev/null	# cache

if grep -q "UK" init.json 2> /dev/null
then
	printf "+++ COUNTRY: UNITED KINGDOM +++\n\n"
fi

if grep -q '"day": "0"' settings.json
then
	printf "EPG Grabber disabled!\n\n"
	exit 0
fi

if ! curl --write-out %{http_code} --silent --output /dev/null https://www.radiotimes.com | grep -q "200"
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

rm main/* 2> /dev/null
rm /tmp/chlist chlist /tmp/workfile workfile 2> /dev/null


#
# LOADING MANIFEST FILES
#

printf "\rFetching channel list... "
curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedulesettings?media=tv' > /tmp/chlist
jq '.' /tmp/chlist > /tmp/workfile

printf "\rChecking manifest files... "
perl chlist_printer.pl > /tmp/compare.json
perl url_printer.pl 2>/tmp/errors.txt | sed '/DUMMY/d' > mani/common

printf "\n$(echo $(wc -l < mani/common)) manifest file(s) to be downloaded!\n\n"

if [ $(wc -l < mani/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < mani/common) / 7)))

	split --lines=$(( $number + 1 )) --numeric-suffixes mani/common mani/day

	rm mani/common 2> /dev/null
else	
	mv mani/common mani/day00
fi


#
# CREATE STATUS BAR FOR MANIFEST FILE DOWNLOAD
#

x=$(wc -l < mani/day00)
y=20
h=40

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
	echo "Progress [                    ]   0%% ' mani/day00" >> progressbar

	# 5%
	echo "sed -i '$z5 i\\" >> progressbar
	echo "Progress [#                   ]   5%% ' mani/day00" >> progressbar

	# 10%
	echo "sed -i '$z10 i\\" >> progressbar
	echo "Progress [##                  ]  10%% ' mani/day00" >> progressbar
	
	# 15%
	echo "sed -i '$z15 i\\" >> progressbar
	echo "Progress [###                 ]  15%% ' mani/day00" >> progressbar

	# 20%
	echo "sed -i '$z20 i\\" >> progressbar
	echo "Progress [####                ]  20%% ' mani/day00" >> progressbar

	# 25%
	echo "sed -i '$z25 i\\" >> progressbar
	echo "Progress [#####               ]  25%% ' mani/day00" >> progressbar

	# 30%
	echo "sed -i '$z30 i\\" >> progressbar
	echo "Progress [######              ]  30%% ' mani/day00" >> progressbar

	# 35%
	echo "sed -i '$z35 i\\" >> progressbar
	echo "Progress [#######             ]  35%% ' mani/day00" >> progressbar

	# 40%
	echo "sed -i '$z40 i\\" >> progressbar
	echo "Progress [########            ]  40%% ' mani/day00" >> progressbar

	# 45%
	echo "sed -i '$z45 i\\" >> progressbar
	echo "Progress [#########           ]  45%% ' mani/day00" >> progressbar

	# 50%
	echo "sed -i '$z50 i\\" >> progressbar
	echo "Progress [##########          ]  50%% ' mani/day00" >> progressbar

	# 55%
	echo "sed -i '$z55 i\\" >> progressbar
	echo "Progress [###########         ]  55%% ' mani/day00" >> progressbar

	# 60%
	echo "sed -i '$z60 i\\" >> progressbar
	echo "Progress [############        ]  60%% ' mani/day00" >> progressbar

	# 65%
	echo "sed -i '$z65 i\\" >> progressbar
	echo "Progress [#############       ]  65%% ' mani/day00" >> progressbar

	# 70%
	echo "sed -i '$z70 i\\" >> progressbar
	echo "Progress [##############      ]  70%% ' mani/day00" >> progressbar

	# 75%
	echo "sed -i '$z75 i\\" >> progressbar
	echo "Progress [###############     ]  75%% ' mani/day00" >> progressbar

	# 80%
	echo "sed -i '$z80 i\\" >> progressbar
	echo "Progress [################    ]  80%% ' mani/day00" >> progressbar

	# 85%
	echo "sed -i '$z85 i\\" >> progressbar
	echo "Progress [#################   ]  85%% ' mani/day00" >> progressbar

	# 90%
	echo "sed -i '$z90 i\\" >> progressbar
	echo "Progress [##################  ]  90%% ' mani/day00" >> progressbar

	# 95%
	echo "sed -i '$z95 i\\" >> progressbar
	echo "Progress [################### ]  95%% ' mani/day00" >> progressbar

	# 100%
	echo "sed -i '\$i\\" >> progressbar
	echo "Progress [####################] 100%% ' mani/day00" >> progressbar

	sed -i 's/ i/i/g' progressbar
	bash progressbar
	sed -i -e 's/Progress/printf "\\rProgress/g' -e '/Progress/s/.*/&"/g' mani/day00
	rm progressbar
fi


#
# CREATE MANIFEST DOWNLOAD SCRIPTS
#

for time in {0..8..1}
do	
	sed -i '1i#\!\/bin\/bash\n' mani/day0${time} 2> /dev/null
done


#
# DOWNLOAD EPG MANIFESTS
#

printf "\rLoading manifest files..."
echo ""

for a in {0..8..1}
do
	bash mani/day0${a} 2> /dev/null &
done
wait

rm mani/day0* 2> /dev/null

echo "DONE!" && printf "\n"


#
# CREATE EPG BROADCAST LIST
#

printf "\rCreating EPG manifest file... "

rm /tmp/manifile.json 2> /dev/null
cat mani/* > /tmp/manifile.json
sed -i 's/}\]}}/}]}/g' /tmp/manifile.json
jq -s '.' /tmp/manifile.json > /tmp/epg_workfile 2>/tmp/errors.txt
sed -i '1s/\[/{ "attributes":[/g;$s/\]/&}/g' /tmp/epg_workfile

perl compare_crid.pl > day/daydlnew_1 2>/tmp/errors.txt
sort -u day/daydlnew_1 > day/daydlnew_sorted && mv day/daydlnew_sorted day/daydlnew_1
cp day/daydlnew_1 day/day1 2> /dev/null

echo "DONE!" && printf "\n"


#
# COPY CACHE FILES TO NEW FOLDER
#

if ! grep -q "<cache incomplete>" init.txt 2> /dev/null
then
	rm -rf cache/old 2> /dev/null
	mv cache/new cache/old 2> /dev/null
	echo "<cache incomplete>" > init.txt
else
	rm -rf cache/new 2> /dev/null
fi

	mkdir cache/new 2> /dev/null
	
	
printf "\rPreparing database transmission...             "

find cache/old -size 0 -delete 2> /dev/null

ls cache/old > compare 2> /dev/null
comm -12 <(sort -u day/day1 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daydpl_1
rm compare

sed -i "s/.*/cp cache\/old\/& cache\/new\/&/g" day/daydpl_1

cat day/daydpl_1 <(echo) > day/common

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


#
# COMPARING: DATABASE <==> MANIFEST TO FIND NEW FILES
#

printf "\rPreparing download...                              "

ls cache/new > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_1 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew
rm compare

sed -i "s/\(.*\)_TV/curl -s 'https:\/\/immediate-prod.apigee.net\/broadcast-content\/1\/episodes\/\1' | grep '+id+:+\1' > cache\/new\/&/g" day/daynew
sed -i "s/\(.*\)_MV/curl -s 'https:\/\/immediate-prod.apigee.net\/broadcast-content\/1\/films\/\1' | grep '+id+:+\1' > cache\/new\/&/g" day/daynew
sed -i 's/+id+:+/"id":"/g' day/daynew

cat day/daynew > day/common

sed -i '/^$/d' day/common
printf "\n$(echo $(wc -l < day/common)) broadcast files to be downloaded!\n\n"

if [ $(wc -l < day/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < day/common) / 7)))
	
	split --lines=$(( $number + 1 )) --numeric-suffixes day/common day/day

	rm day/common 2> /dev/null
else	
	mv day/common day/day00
fi


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

for time in {0..8..1}
do	
	sed -i "1s/.*/#\!\/bin\/bash\n\n&/g" day/day0${time} 2> /dev/null
done


#
# DOWNLOAD EPG DETAILS
#

printf "\rDownloading EPG details...                 "
echo ""

for i in {0..8..1}
do
	bash day/day0${i} 2> /dev/null &
done
wait

rm day/* 2> /dev/null

echo  "DONE!" && printf "\n"


# ###################
# CREATE XMLTV FILE #
# ###################

# WORK IN PROGRESS

echo "- FILE CREATION PROCESS -" && echo ""

rm workfile chlist 2> /dev/null

# DOWNLOAD CHANNEL LIST + RYTEC/EIT CONFIG FILES (JSON)
printf "\rRetrieving channel list and config files...          "
curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedulesettings?media=tv' > /tmp/chlist
jq '.' /tmp/chlist > chlist
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/rdt_channels.json > rdt_channels.json
curl -s https://raw.githubusercontent.com/sunsettrack4/config_files/master/rdt_genres.json > rdt_genres.json

# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > radiotimes_channels
sort -u radiotimes_channels > /tmp/radiotimes_channels && mv /tmp/radiotimes_channels radiotimes_channels
sed -i 's/></>\n</g;s/<display-name/  &/g' radiotimes_channels

# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                            "
perl cid_json.pl > rdt_cid.json && rm chlist

# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
perl epg_json2xml.pl > radiotimes_epg 2>epg_warnings.txt && rm /tmp/epg_workfile 2> /dev/null

# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat radiotimes_epg >> radiotimes_channels && mv radiotimes_channels radiotimes && rm radiotimes_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<tv>' radiotimes
sed -i "s/<tv>/<\!-- created on $(date) -->\n&\n\n<!-- CHANNEL LIST -->\n/g" radiotimes
sed -i '$s/.*/&\n\n<\/tv>/g' radiotimes
mv radiotimes radiotimes.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout radiotimes.xml > errorlog 2>&1

if grep -q "parser error" errorlog
then
	printf " DONE!\n\n"
	mv radiotimes.xml radiotimes_ERROR.xml
	echo "[ EPG ERROR ] XMLTV FILE VALIDATION FAILED DUE TO THE FOLLOWING ERRORS:" >> warnings.txt
	cat errorlog >> warnings.txt
else
	printf " DONE!\n\n"
	rm radiotimes_ERROR.xml 2> /dev/null
	rm errorlog 2> /dev/null
	
	if ! grep -q "<programme start=" radiotimes.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY PROGRAMME DATA!" >> errorlog
	fi
	
	if ! grep -q "<channel id=" radiotimes.xml
	then
		echo "[ EPG ERROR ] XMLTV FILE DOES NOT CONTAIN ANY CHANNEL DATA!" >> errorlog
	fi
	
	if [ -e errorlog ]
	then
		mv radiotimes.xml radiotimes_ERROR.xml
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
