#!/bin/bash

#      Copyright (C) 2019 Jan-Luca Neumann
#      https://github.com/sunsettrack4/easyepg/hzn
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
echo " HORIZON EPG SIMPLE XMLTV GRABBER            "
echo " Release v0.1.0 BETA - 2019/03/10            "
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
sleep 2s

# ################
# INITIALIZATION #
# ################

#
# SETUP ENVIRONMENT
#

mkdir ~/hzn 2> /dev/null		# main folder
mkdir ~/hzn/cache 2> /dev/null	# cache
mkdir ~/hzn/day 2> /dev/null	# download scripts

cd ~/hzn 

#
# SET VARIABLES
#

if [ ! -s init.json ]
then
	echo "Please choose your country:"
	echo "[1] DE | 2 [AT] | 3 [CH] | 4 [NL] | 5 [PL]"
	echo "[6] IE | 7 [SK] | 8 [CZ] | 9 [HU] | 0 [RO]"
	
	printf "\n"
	read -p "Number....: " -n1 n
	printf "\n"
	
	case $n in
	1) 	echo '{"country":"DE","language":"de"}' > init.json
		echo "Country selected: DE" && printf "\n";;
	2) 	echo '{"country":"AT","language":"de"}' > init.json
		echo "Country selected: AT" && printf "\n";;
	3) 	echo '{"country":"CH","language":"de"}' > init.json
		echo "Country selected: CH" && printf "\n";;
	4) 	echo '{"country":"NL","language":"nl"}' > init.json
		echo "Country selected: NL" && printf "\n";;
	5) 	echo '{"country":"PL","language":"pl"}' > init.json
		echo "Country selected: PL" && printf "\n";;
	6) 	echo '{"country":"IE","language":"en"}' > init.json
		echo "Country selected: IE" && printf "\n";;
	7) 	echo '{"country":"SK","language":"sk"}' > init.json
		echo "Country selected: SK" && printf "\n";;
	8) 	echo '{"country":"CZ","language":"cz"}' > init.json
		echo "Country selected: CZ" && printf "\n";;
	9) 	echo '{"country":"HU","language":"hu"}' > init.json
		echo "Country selected: HU" && printf "\n";;
	0) 	echo '{"country":"RO","language":"ro"}' > init.json
		echo "Country selected: RO" && printf "\n";;
	esac
fi

if grep -q "DE" init.json 2> /dev/null
then
	echo "+++ COUNTRY: GERMANY +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/DE/deu/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/DE\/deu\/web'
elif grep -q "AT" init.json 2> /dev/null
then
	echo "+++ COUNTRY: AUSTRIA +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/AT/deu/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/AT\/deu\/web'
elif grep -q "CH" init.json 2> /dev/null
then
	echo "+++ COUNTRY: SWITZERLAND +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/CH/deu/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/CH\/deu\/web'
elif grep -q "NL" init.json 2> /dev/null
then
	echo "+++ COUNTRY: NETHERLANDS +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/NL/nld/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/NL\/nld\/web'
elif grep -q "PL" init.json 2> /dev/null
then
	echo "+++ COUNTRY: POLAND +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/PL/pol/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/PL\/pol\/web'
elif grep -q "IE" init.json 2> /dev/null
then
	echo "+++ COUNTRY: IRELAND +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/IE/eng/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/IE\/eng\/web'
elif grep -q "SK" init.json 2> /dev/null
then
	echo "+++ COUNTRY: SLOVAKIA +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/SK/slk/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/SK\/slk\/web'
elif grep -q "CZ" init.json 2> /dev/null
then
	echo "+++ COUNTRY: CZECH REPUBLIC +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/CZ/ces/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/CZ\/ces\/web'
elif grep -q "HU" init.json 2> /dev/null
then
	echo "+++ COUNTRY: HUNGARY +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/HU/hun/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/HU\/hun\/web'
elif grep -q "RO" init.json 2> /dev/null
then
	echo "+++ COUNTRY: ROMANIA +++"
	baseurl='https://web-api-pepper.horizon.tv/oesp/v2/RO/ron/web'
	baseurl_sed='web-api-pepper.horizon.tv\/oesp\/v2\/RO\/ron\/web'
else
	echo "ERROR: WRONG INIT INPUT DETECTED - Stop."
	rm init.json 2> /dev/null
	exit 1
fi

printf "\n"

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

#
# DOWNLOAD EPG MANIFESTS
#

printf "\rDownloading EPG manifest files...            "

for i in {1..4..1}
do
	curl -s $baseurl/programschedules/$date1/${i}	| grep '"updated"' >> day/day1 &
	curl -s $baseurl/programschedules/$date2/${i} 	| grep '"updated"' >> day/day2 &
	curl -s $baseurl/programschedules/$date3/${i} 	| grep '"updated"' >> day/day3 &
	curl -s $baseurl/programschedules/$date4/${i} 	| grep '"updated"' >> day/day4 &
	curl -s $baseurl/programschedules/$date5/${i} 	| grep '"updated"' >> day/day5 &
	curl -s $baseurl/programschedules/$date6/${i} 	| grep '"updated"' >> day/day6 &
	curl -s $baseurl/programschedules/$date7/${i} 	| grep '"updated"' >> day/day7 &
done
wait


#
# CREATE EPG BROADCAST LIST
#

printf "\rCreating EPG lists...                      "

for time in {1..7..1}
do
	sed -i 's/"i":"/\n/g' day/day${time}
	sed -i '/{"entryCount/d' day/day${time}
	sed -i 's/","r":.*//g' day/day${time}
	cp day/day${time} day/daydlnew_${time}
done
	

#
# COPY CACHE FILES TO NEW FOLDER
#

printf "\rUpdating cache setup...                     "

if ! grep -q "<cache incomplete>" init.txt 2> /dev/null
then
	mv cache/new_$date1 cache/old_$date1 2> /dev/null
	mv cache/new_$date2 cache/old_$date2 2> /dev/null
	mv cache/new_$date3 cache/old_$date3 2> /dev/null
	mv cache/new_$date4 cache/old_$date4 2> /dev/null
	mv cache/new_$date5 cache/old_$date5 2> /dev/null
	mv cache/new_$date6 cache/old_$date6 2> /dev/null
	mv cache/new_$date7 cache/old_$date7 2> /dev/null
	echo "<cache incomplete>" > init.txt
else
	rm -rf cache/new_$date1 cache/new_$date2 cache/new_$date3 cache/new_$date4 cache/new_$date5 cache/new_$date6 cache/new_$date7 2> /dev/null
fi

	mkdir cache/new_$date1
	mkdir cache/new_$date2
	mkdir cache/new_$date3
	mkdir cache/new_$date4
	mkdir cache/new_$date5
	mkdir cache/new_$date6
	mkdir cache/new_$date7


#
# COMPARING: DATABASE <==> MANIFEST TO FIND DUPLICATES
#

printf "\rPreparing database transmission...             "

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
rm compare

for x in {1..7..1}
do
	sed -i "s/.*/cp cache\/old_day${x}\/& cache\/new_day${x}\/&/g" day/daydpl_${x}
done

cat day/daydpl_1 <(echo) day/daydpl_2 <(echo) day/daydpl_3 <(echo) day/daydpl_4 <(echo) day/daydpl_5 <(echo) day/daydpl_6 <(echo) day/daydpl_7 <(echo) > day/common

sed -i '/^$/d' day/common
printf "\n$(echo $(wc -l < day/common)) broadcast files found!\n\n"

if [ $(wc -l < day/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < day/common) / 7)))

	split -l $number --numeric-suffixes day/common day/day

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

for time in {0..7..1}
do	
	sed -i '1s/.*/#\!\/bin\/bash/g' day/day0${time} 2> /dev/null
	sed -i 's/; then /\nthen\n  /g;s/; fi/\nfi/g' day/day0${time} 2> /dev/null

	sed -i "s/new_day1/new_$date1/g;s/old_day1/old_$date1/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day2/new_$date2/g;s/old_day2/old_$date2/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day3/new_$date3/g;s/old_day3/old_$date3/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day4/new_$date4/g;s/old_day4/old_$date4/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day5/new_$date5/g;s/old_day5/old_$date5/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day6/new_$date6/g;s/old_day6/old_$date6/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day7/new_$date7/g;s/old_day7/old_$date7/g" day/day0${time} 2> /dev/null
done


#
# COPY/PASTE EPG DETAILS
#

printf "\rLoading cached data files into new database..."
echo ""

for a in {0..7..1}
do
	bash day/day0${a} 2> /dev/null &
done
wait

rm day/day0* init.txt 2> /dev/null
	
echo "DONE!" && printf "\n"


#
# COMPARING: DATABASE <==> MANIFEST TO FIND NEW FILES
#

printf "\rPreparing multithreaded download...                   "

ls cache/new_$date1 > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_1 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_1
ls cache/new_$date2 > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_2 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_2
ls cache/new_$date3 > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_3 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_3
ls cache/new_$date4 > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_4 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_4
ls cache/new_$date5 > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_5 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_5
ls cache/new_$date6 > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_6 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_6
ls cache/new_$date7 > compare 2> /dev/null
comm -2 -3 <(sort -u day/daydlnew_7 2> /dev/null) <(sort -u compare 2> /dev/null) > day/daynew_7
rm compare

for x in {1..7..1}
do
	sed -i "s/.*/curl -s $baseurl_sed\/listings\/& | grep 'title' > cache\/new_day${x}\/&/g" day/daynew_${x}
done

cat day/daynew_1 <(echo) day/daynew_2 <(echo) day/daynew_3 <(echo) day/daynew_4 <(echo) day/daynew_5 <(echo) day/daynew_6 <(echo) day/daynew_7 <(echo) > day/common

sed -i '/^$/d' day/common
printf "\n$(echo $(wc -l < day/common)) broadcast files to be downloaded!\n\n"

if [ $(wc -l < day/common) -ge 7 ]
then
	number=$(echo $(( $(wc -l < day/common) / 7)))

	split -l $number --numeric-suffixes day/common day/day

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

for time in {0..7..1}
do	
	sed -i '1s/.*/#\!\/bin\/bash/g' day/day0${time} 2> /dev/null
	sed -i '/curl/s/ > / \\\n  > /g' day/day0${time} 2> /dev/null
	sed -i '/curl/s/:/%3A/g' day/day0${time} 2> /dev/null
	sed -i 's/web-api/https:\/\/&/g' day/day0${time} 2> /dev/null

	sed -i "s/new_day1/new_$date1/g;s/old_day1/old_$date1/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day2/new_$date2/g;s/old_day2/old_$date2/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day3/new_$date3/g;s/old_day3/old_$date3/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day4/new_$date4/g;s/old_day4/old_$date4/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day5/new_$date5/g;s/old_day5/old_$date5/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day6/new_$date6/g;s/old_day6/old_$date6/g" day/day0${time} 2> /dev/null
	sed -i "s/new_day7/new_$date7/g;s/old_day7/old_$date7/g" day/day0${time} 2> /dev/null
done


#
# DOWNLOAD EPG DETAILS
#

printf "\rDownloading EPG details...                 "
echo ""

for a in {0..7..1}
do
	bash day/day0${a} 2> /dev/null &
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


# DOWNLOAD CHANNEL LIST
printf "\rRetrieving channel lists...                           "
curl -s $baseurl/channels > chlist
curl -s https://gist.githubusercontent.com/sunsettrack4/6016c6228a5450d5fd2fd137a5806351/raw/4bec83a1068cc3e3ee1c95add45792ac77929ca1/hzn_channels.json > hzn_channels.json

# CONVERT JSON INTO XML: CHANNELS
printf "\rConverting CHANNEL JSON file into XML format...      "
perl ch_json2xml.pl 2>warnings.txt > horizon_channels

# CREATE CHANNEL ID LIST AS JSON FILE
printf "\rRetrieving Channel IDs...                            "
perl cid_json.pl > hzn_cid.json && rm chlist

# COMBINING ALL EPG PARTS TO ONE FILE
printf "\rCopying JSON files to common file...                 "

cat cache/new_$date1/* > workfile
cat cache/new_$date2/* >> workfile
cat cache/new_$date3/* >> workfile
cat cache/new_$date4/* >> workfile
cat cache/new_$date5/* >> workfile
cat cache/new_$date6/* >> workfile
cat cache/new_$date7/* >> workfile

# SORT BY CID AND START TIME
printf "\rSorting data by channel ID and start time...         "
sed -i 's/{\(.*\)\("startTime":[^,]*,\)\(.*\)\("stationId":"[^"]*",\)\(.*\)/{\4\2\1\3\5/g' workfile
sort -u workfile > workfile2 && mv workfile2 workfile

# VALIDATE JSON FILE
printf "\rValidating JSON EPG file...                          "
sed -i 's/.*/{"attributes":&}/g' workfile
jq -s '{ attributes: map(.attributes) }' workfile > workfile2 && mv workfile2 workfile

# CONVERT JSON INTO XML: EPG
printf "\rConverting EPG JSON file into XML format...          "
perl epg_json2xml.pl > horizon_epg 2>epg_warnings.txt && rm workfile

# COMBINE: CHANNELS + EPG
printf "\rCreating EPG XMLTV file...                           "
cat horizon_epg >> horizon_channels && mv horizon_channels horizon && rm horizon_epg
sed -i '1i<?xml version="1.0" encoding="UTF-8" ?>\n<\!-- EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019 Jan-Luca Neumann -->\n<tv>' horizon
sed -i "s/<tv>/<\!-- created on $(date) -->\n&/g" horizon
sed -i '$s/.*/&\n\n<\/tv>/g' horizon
mv horizon horizon.xml

# VALIDATING XML FILE
printf "\rValidating EPG XMLTV file..."
xmllint --noout horizon.xml

# MAP CATEGORIES
# perl genremapper.pl < horizon.xml > workfile && mv workfile horizon.xml

# APPEND RATINGS TO 1st DESCRIPTION LINE
if [ -e ratingmapper.pl ]
then
	perl ratingmapper.pl horizon.xml > workfile && mv workfile horizon.xml
fi

echo " DONE!" && echo ""

# SHOW WARNINGS
cat epg_warnings.txt >> warnings.txt && rm epg_warnings.txt
sort -u warnings.txt > sorted_warnings.txt && mv sorted_warnings.txt warnings.txt
sed -i '/^$/d' warnings.txt

if [ -s warnings.txt ]
then
	echo "================= EPG CREATION: WARNING LOG ======================"
	echo ""
	echo "It seems that some Channel IDs are not defined by the provider.   "
	echo "Please send this log to the developer to fix the following issues:"
	echo ""
	
	input="warnings.txt"
	while IFS= read -r var
	do
		echo "$var"
	done < "$input"
	
	echo ""
	echo "=================================================================="
fi
