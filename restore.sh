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
# RESTORE SCRIPT #
# ################

#
# CHECK IF BACKUP ZIP ALREADY EXISTS
#

if [ ! -e easyepg_backup.zip ]
then
	printf "Backup ZIP does not exist! - STOP.\n\n"
	exit 0
fi


#
# DECOMPRESS ZIP
#

printf "Decompressing ZIP file...\n\n"

rm -rf easyepg_backup 2> /dev/null
unzip easyepg_backup.zip -d easyepg_backup

if [ -e easyepg_backup/easyepg_backup ]
then
	rm easyepg_backup/* 2> /dev/null
	cp easyepg_backup/easyepg_backup/* easyepg_backup/
	rm -rf easyepg_backup/easyepg_backup
else
	printf "Backup ZIP does not provide expected data files! - STOP.\n"
	exit 0
fi


#
# RESET SETUP
#

printf "\nResetting setup...\n\n"

rm -rf hzn/de hzn/at hzn/ch hzn/nl hzn/pl hzn/ie hzn/sk hzn/cz hzn/hu hzn/ro ztt/de ztt/ch swc/ch tvp/uk tkm/de rdt/uk wpu/de tvs/de vdf/de ext/oa ext/ob ext/oc 2> /dev/null


#
# START RESTORE PROCESS: PROVIDER SETUPS + XML FILES
#

printf "\nStarting RESTORE process...\n\n"

mkdir xml 2> /dev/null

# HORIZON DE

if [ -e easyepg_backup/hzn_de_init.json ]
then
	echo "Restoring: Horizon DE"
	mkdir hzn/de 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/de/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/de/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/de/cid_json.pl
	cp hzn/compare_menu.pl		hzn/de/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/de/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/de/hzn.sh
	cp hzn/settings.sh			hzn/de/settings.sh
	sed 's/XX/DE/g;s/YYY/deu/g' hzn/url_printer.pl > hzn/de/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_de_init.json			hzn/de/init.json
	cp easyepg_backup/hzn_de_chlist_old			hzn/de/chlist_old
	cp easyepg_backup/hzn_de_channels.json		hzn/de/channels.json
	cp easyepg_backup/hzn_de_settings.json		hzn/de/settings.json
	cp easyepg_backup/xml_hzn_de.xml			xml/horizon_de.xml	2> /dev/null
else
	echo "Skipping restore: Horizon DE - no setup found"
fi

# HORIZON AT

if [ -e easyepg_backup/hzn_at_init.json ]
then
	echo "Restoring: Horizon AT"
	mkdir hzn/at 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/at/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/at/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/at/cid_json.pl
	cp hzn/compare_menu.pl		hzn/at/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/at/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/at/hzn.sh
	cp hzn/settings.sh			hzn/at/settings.sh
	sed 's/XX/AT/g;s/YYY/deu/g;s/legacy-dynamic.oesp.horizon.tv/prod.oesp.magentatv.at/g' hzn/url_printer.pl > hzn/at/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_at_init.json			hzn/at/init.json
	cp easyepg_backup/hzn_at_chlist_old			hzn/at/chlist_old
	cp easyepg_backup/hzn_at_channels.json		hzn/at/channels.json
	cp easyepg_backup/hzn_at_settings.json		hzn/at/settings.json
	cp easyepg_backup/xml_hzn_at.xml			xml/horizon_at.xml 2> /dev/null
else
	echo "Skipping restore: Horizon AT - no setup found"
fi

# HORIZON CH

if [ -e easyepg_backup/hzn_ch_init.json ]
then
	echo "Restoring: Horizon CH"
	mkdir hzn/ch 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/ch/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/ch/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/ch/cid_json.pl
	cp hzn/compare_menu.pl		hzn/ch/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/ch/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/ch/hzn.sh
	cp hzn/settings.sh			hzn/ch/settings.sh
	sed 's/XX/CH/g;s/YYY/deu/g;s/legacy-dynamic.oesp.horizon.tv/obo-prod.oesp.upctv.ch/g' hzn/url_printer.pl > hzn/ch/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_ch_init.json			hzn/ch/init.json
	cp easyepg_backup/hzn_ch_chlist_old			hzn/ch/chlist_old
	cp easyepg_backup/hzn_ch_channels.json		hzn/ch/channels.json
	cp easyepg_backup/hzn_ch_settings.json		hzn/ch/settings.json
	cp easyepg_backup/xml_hzn_ch.xml			xml/horizon_ch.xml 2> /dev/null
else
	echo "Skipping restore: Horizon CH - no setup found"
fi

# HORIZON NL

if [ -e easyepg_backup/hzn_nl_init.json ]
then
	echo "Restoring: Horizon NL"
	mkdir hzn/nl 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/nl/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/nl/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/nl/cid_json.pl
	cp hzn/compare_menu.pl		hzn/nl/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/nl/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/nl/hzn.sh
	cp hzn/settings.sh			hzn/nl/settings.sh
	sed 's/XX/NL/g;s/YYY/nld/g;s/legacy-dynamic.oesp.horizon.tv/obo-prod.oesp.ziggogo.tv/g' hzn/url_printer.pl > hzn/nl/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_nl_init.json			hzn/nl/init.json
	cp easyepg_backup/hzn_nl_chlist_old			hzn/nl/chlist_old
	cp easyepg_backup/hzn_nl_channels.json		hzn/nl/channels.json
	cp easyepg_backup/hzn_nl_settings.json		hzn/nl/settings.json
	cp easyepg_backup/xml_hzn_nl.xml			xml/horizon_nl.xml 2> /dev/null
else
	echo "Skipping restore: Horizon NL - no setup found"
fi

# HORIZON PL

if [ -e easyepg_backup/hzn_pl_init.json ]
then
	echo "Restoring: Horizon PL"
	mkdir hzn/pl 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/pl/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/pl/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/pl/cid_json.pl
	cp hzn/compare_menu.pl		hzn/pl/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/pl/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/pl/hzn.sh
	cp hzn/settings.sh			hzn/pl/settings.sh
	sed 's/XX/PL/g;s/YYY/pol/g;s/legacy-dynamic.oesp.horizon.tv/prod.oesp.upctv.pl/g' hzn/url_printer.pl > hzn/pl/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_pl_init.json			hzn/pl/init.json
	cp easyepg_backup/hzn_pl_chlist_old			hzn/pl/chlist_old
	cp easyepg_backup/hzn_pl_channels.json		hzn/pl/channels.json
	cp easyepg_backup/hzn_pl_settings.json		hzn/pl/settings.json
	cp easyepg_backup/xml_hzn_pl.xml			xml/horizon_pl.xml 2> /dev/null
else
	echo "Skipping restore: Horizon PL - no setup found"
fi

# HORIZON IE

if [ -e easyepg_backup/hzn_ie_init.json ]
then
	echo "Restoring: Horizon IE"
	mkdir hzn/ie 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/ie/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/ie/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/ie/cid_json.pl
	cp hzn/compare_menu.pl		hzn/ie/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/ie/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/ie/hzn.sh
	cp hzn/settings.sh			hzn/ie/settings.sh
	sed 's/XX/IE/g;s/YYY/eng/g;s/legacy-dynamic.oesp.horizon.tv/prod.oesp.virginmediatv.ie/g' hzn/url_printer.pl > hzn/ie/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_ie_init.json			hzn/ie/init.json
	cp easyepg_backup/hzn_ie_chlist_old			hzn/ie/chlist_old
	cp easyepg_backup/hzn_ie_channels.json		hzn/ie/channels.json
	cp easyepg_backup/hzn_ie_settings.json		hzn/ie/settings.json
	cp easyepg_backup/xml_hzn_ie.xml			xml/horizon_ie.xml 2> /dev/null
else
	echo "Skipping restore: Horizon IE - no setup found"
fi

# HORIZON SK

if [ -e easyepg_backup/hzn_sk_init.json ]
then
	echo "Restoring: Horizon SK"
	mkdir hzn/sk 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/sk/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/sk/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/sk/cid_json.pl
	cp hzn/compare_menu.pl		hzn/sk/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/sk/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/sk/hzn.sh
	cp hzn/settings.sh			hzn/sk/settings.sh
	sed 's/XX/SK/g;s/YYY/slk/g' hzn/url_printer.pl > hzn/sk/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_sk_init.json			hzn/sk/init.json
	cp easyepg_backup/hzn_sk_chlist_old			hzn/sk/chlist_old
	cp easyepg_backup/hzn_sk_channels.json		hzn/sk/channels.json
	cp easyepg_backup/hzn_sk_settings.json		hzn/sk/settings.json
	cp easyepg_backup/xml_hzn_sk.xml			xml/horizon_sk.xml 2> /dev/null
else
	echo "Skipping restore: Horizon SK - no setup found"
fi

# HORIZON CZ

if [ -e easyepg_backup/hzn_cz_init.json ]
then
	echo "Restoring: Horizon CZ"
	mkdir hzn/cz 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/cz/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/cz/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/cz/cid_json.pl
	cp hzn/compare_menu.pl		hzn/cz/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/cz/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/cz/hzn.sh
	cp hzn/settings.sh			hzn/cz/settings.sh
	sed 's/XX/CZ/g;s/YYY/ces/g' hzn/url_printer.pl > hzn/cz/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_cz_init.json			hzn/cz/init.json
	cp easyepg_backup/hzn_cz_chlist_old			hzn/cz/chlist_old
	cp easyepg_backup/hzn_cz_channels.json		hzn/cz/channels.json
	cp easyepg_backup/hzn_cz_settings.json		hzn/cz/settings.json
	cp easyepg_backup/xml_hzn_cz.xml			xml/horizon_cz.xml 2> /dev/null
else
	echo "Skipping restore: Horizon CZ - no setup found"
fi

# HORIZON HU

if [ -e easyepg_backup/hzn_cz_init.json ]
then
	echo "Restoring: Horizon HU"
	mkdir hzn/hu 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/hu/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/hu/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/hu/cid_json.pl
	cp hzn/compare_menu.pl		hzn/hu/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/hu/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/hu/hzn.sh
	cp hzn/settings.sh			hzn/hu/settings.sh
	sed 's/XX/HU/g;s/YYY/hun/g' hzn/url_printer.pl > hzn/hu/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_hu_init.json			hzn/hu/init.json
	cp easyepg_backup/hzn_hu_chlist_old			hzn/hu/chlist_old
	cp easyepg_backup/hzn_hu_channels.json		hzn/hu/channels.json
	cp easyepg_backup/hzn_hu_settings.json		hzn/hu/settings.json
	cp easyepg_backup/xml_hzn_hu.xml			xml/horizon_hu.xml 2> /dev/null
else
	echo "Skipping restore: Horizon HU - no setup found"
fi

# HORIZON RO

if [ -e easyepg_backup/hzn_cz_init.json ]
then
	echo "Restoring: Horizon RO"
	mkdir hzn/ro 2> /dev/null
	
	cp hzn/ch_json2xml.pl 		hzn/ro/ch_json2xml.pl 
	cp hzn/chlist_printer.pl 	hzn/ro/chlist_printer.pl
	cp hzn/cid_json.pl 			hzn/ro/cid_json.pl
	cp hzn/compare_menu.pl		hzn/ro/compare_menu.pl
	cp hzn/epg_json2xml.pl		hzn/ro/epg_json2xml.pl
	cp hzn/hzn.sh				hzn/ro/hzn.sh
	cp hzn/settings.sh			hzn/ro/settings.sh
	sed 's/XX/RO/g;s/YYY/ron/g' hzn/url_printer.pl > hzn/ro/url_printer.pl 2> /dev/null
	
	cp easyepg_backup/hzn_ro_init.json			hzn/ro/init.json
	cp easyepg_backup/hzn_ro_chlist_old			hzn/ro/chlist_old
	cp easyepg_backup/hzn_ro_channels.json		hzn/ro/channels.json
	cp easyepg_backup/hzn_ro_settings.json		hzn/ro/settings.json
	cp easyepg_backup/xml_hzn_ro.xml			xml/horizon_ro.xml 2> /dev/null
else
	echo "Skipping restore: Horizon RO - no setup found"
fi

# ZATTOO DE

if [ -e easyepg_backup/ztt_de_init.json ]
then
	echo "Restoring: Zattoo DE"
	mkdir ztt/de 2> /dev/null
	mkdir ztt/de/user 2> /dev/null
	
	cp ztt/ch_json2xml.pl 		ztt/de/ch_json2xml.pl 
	cp ztt/chlist_printer.pl 	ztt/de/chlist_printer.pl
	cp ztt/cid_json.pl 			ztt/de/cid_json.pl
	cp ztt/compare_crid.pl		ztt/de/compare_crid.pl
	cp ztt/compare_menu.pl		ztt/de/compare_menu.pl
	cp ztt/epg_json2xml.pl		ztt/de/epg_json2xml.pl
	cp ztt/ztt.sh				ztt/de/ztt.sh
	cp ztt/save_page.js			ztt/de/save_page.js
	sed 's/\[XX\]/[DE]/g;s/XXXX/DE/g' ztt/settings.sh > ztt/de/settings.sh 2> /dev/null
	
	cp easyepg_backup/ztt_de_init.json			ztt/de/init.json
	cp easyepg_backup/ztt_de_chlist_old			ztt/de/chlist_old
	cp easyepg_backup/ztt_de_channels.json		ztt/de/channels.json
	cp easyepg_backup/ztt_de_settings.json		ztt/de/settings.json
	cp easyepg_backup/ztt_de_user_userfile		ztt/de/user/userfile
	cp easyepg_backup/xml_ztt_de.xml			xml/zattoo_de.xml 2> /dev/null
else
	echo "Skipping restore: Zattoo DE - no setup found"
fi

# ZATTOO CH

if [ -e easyepg_backup/ztt_ch_init.json ]
then
	echo "Restoring: Zattoo CH"
	mkdir ztt/ch 2> /dev/null
	mkdir ztt/ch/user 2> /dev/null
	
	cp ztt/ch_json2xml.pl 		ztt/ch/ch_json2xml.pl 
	cp ztt/chlist_printer.pl 	ztt/ch/chlist_printer.pl
	cp ztt/cid_json.pl			ztt/ch/cid_json.pl
	cp ztt/compare_crid.pl		ztt/ch/compare_crid.pl
	cp ztt/compare_menu.pl		ztt/ch/compare_menu.pl
	cp ztt/epg_json2xml.pl		ztt/ch/epg_json2xml.pl
	cp ztt/ztt.sh				ztt/ch/ztt.sh
	cp ztt/save_page.js			ztt/ch/save_page.js
	sed 's/\[XX\]/[CH]/g;s/XXXX/CH/g' ztt/settings.sh > ztt/ch/settings.sh 2> /dev/null
	
	cp easyepg_backup/ztt_ch_init.json			ztt/ch/init.json
	cp easyepg_backup/ztt_ch_chlist_old			ztt/ch/chlist_old
	cp easyepg_backup/ztt_ch_channels.json		ztt/ch/channels.json
	cp easyepg_backup/ztt_ch_settings.json		ztt/ch/settings.json
	cp easyepg_backup/ztt_ch_user_userfile		ztt/ch/user/userfile
	cp easyepg_backup/xml_ztt_ch.xml			xml/zattoo_ch.xml 2> /dev/null
else
	echo "Skipping restore: Zattoo CH - no setup found"
fi

# SWISSCOM CH

if [ -e easyepg_backup/swc_ch_init.json ]
then
	echo "Restoring: Swisscom CH"
	mkdir swc/ch 2> /dev/null
	
	cp swc/ch_json2xml.pl 		swc/ch/ch_json2xml.pl 
	cp swc/chlist_printer.pl 	swc/ch/chlist_printer.pl
	cp swc/cid_json.pl			swc/ch/cid_json.pl
	cp swc/compare_menu.pl		swc/ch/compare_menu.pl
	cp swc/epg_json2xml.pl		swc/ch/epg_json2xml.pl
	cp swc/swc.sh				swc/ch/swc.sh
	cp swc/settings.sh			swc/ch/settings.sh
	cp swc/url_printer.pl		swc/ch/url_printer.pl
	
	cp easyepg_backup/swc_ch_init.json			swc/ch/init.json
	cp easyepg_backup/swc_ch_chlist_old			swc/ch/chlist_old
	cp easyepg_backup/swc_ch_channels.json		swc/ch/channels.json
	cp easyepg_backup/swc_ch_settings.json		swc/ch/settings.json
	cp easyepg_backup/xml_swc_ch.xml			xml/swisscom_ch.xml 2> /dev/null
else
	echo "Skipping restore: Swisscom CH - no setup found"
fi

# TVPLAYER UK

if [ -e easyepg_backup/tvp_uk_init.json ]
then
	echo "Restoring: tvPlayer UK"
	mkdir tvp/uk 2> /dev/null
	
	cp tvp/ch_json2xml.pl 		tvp/uk/ch_json2xml.pl 
	cp tvp/chlist_printer.pl 	tvp/uk/chlist_printer.pl
	cp tvp/cid_json.pl 			tvp/uk/cid_json.pl
	cp tvp/compare_crid.pl		tvp/uk/compare_crid.pl
	cp tvp/compare_menu.pl		tvp/uk/compare_menu.pl
	cp tvp/epg_json2xml.pl		tvp/uk/epg_json2xml.pl
	cp tvp/tvp.sh				tvp/uk/tvp.sh
	cp tvp/settings.sh			tvp/uk/settings.sh
	
	cp easyepg_backup/tvp_uk_init.json			tvp/uk/init.json
	cp easyepg_backup/tvp_uk_chlist_old			tvp/uk/chlist_old
	cp easyepg_backup/tvp_uk_channels.json		tvp/uk/channels.json
	cp easyepg_backup/tvp_uk_settings.json		tvp/uk/settings.json
	cp easyepg_backup/xml_tvp_uk.xml			xml/tvp_uk.xml 2> /dev/null
else
	echo "Skipping restore: tvPlayer UK - no setup found"
fi

# MAGENTA TV DE

if [ -e easyepg_backup/tkm_de_init.json ]
then
	echo "Restoring: Magenta TV DE"
	mkdir tkm/de 2> /dev/null
	
	cp tkm/ch_json2xml.pl 		tkm/de/ch_json2xml.pl 
	cp tkm/chlist_printer.pl 	tkm/de/chlist_printer.pl
	cp tkm/cid_json.pl 			tkm/de/cid_json.pl
	cp tkm/compare_menu.pl		tkm/de/compare_menu.pl
	cp tkm/epg_json2xml.pl		tkm/de/epg_json2xml.pl
	cp tkm/tkm.sh				tkm/de/tkm.sh
	cp tkm/settings.sh			tkm/de/settings.sh
	cp tkm/proxy.sh			tkm/de/proxy.sh
	cp tkm/url_printer.pl		tkm/de/url_printer.pl
	cp tkm/web_magentatv_de.php tkm/de/web_magentatv_de.php
	
	cp easyepg_backup/tkm_de_init.json			tkm/de/init.json
	cp easyepg_backup/tkm_de_chlist_old			tkm/de/chlist_old
	cp easyepg_backup/tkm_de_channels.json		tkm/de/channels.json
	cp easyepg_backup/tkm_de_settings.json		tkm/de/settings.json
	cp easyepg_backup/xml_tkm_de.xml			xml/magentatv_de.xml 2> /dev/null
else
	echo "Skipping restore: Magenta TV DE - no setup found"
fi

# RADIOTIMES UK

if [ -e easyepg_backup/rdt_uk_init.json ]
then
	echo "Restoring: RadioTimes UK"
	mkdir rdt/uk 2> /dev/null
	
	cp rdt/ch_json2xml.pl 		rdt/uk/ch_json2xml.pl 
	cp rdt/chlist_printer.pl 	rdt/uk/chlist_printer.pl
	cp rdt/cid_json.pl 			rdt/uk/cid_json.pl
	cp rdt/compare_crid.pl		rdt/uk/compare_crid.pl
	cp rdt/compare_menu.pl		rdt/uk/compare_menu.pl
	cp rdt/epg_json2xml.pl		rdt/uk/epg_json2xml.pl
	cp rdt/rdt.sh				rdt/uk/rdt.sh
	cp rdt/settings.sh			rdt/uk/settings.sh
	cp rdt/url_printer.pl		rdt/uk/url_printer.pl
	
	cp easyepg_backup/rdt_uk_init.json			rdt/uk/init.json
	cp easyepg_backup/rdt_uk_chlist_old			rdt/uk/chlist_old
	cp easyepg_backup/rdt_uk_channels.json		rdt/uk/channels.json
	cp easyepg_backup/rdt_uk_settings.json		rdt/uk/settings.json
	cp easyepg_backup/xml_rdt_uk.xml			xml/radiotimes_uk.xml 2> /dev/null
else
	echo "Skipping restore: RadioTimes UK - no setup found"
fi

# WAIPU.TV DE

if [ -e easyepg_backup/wpu_de_init.json ]
then
	echo "Restoring: waipu.tv DE"
	mkdir wpu/de 2> /dev/null
	mkdir wpu/de/user 2> /dev/null
	
	cp wpu/ch_json2xml.pl 		wpu/de/ch_json2xml.pl 
	cp wpu/chlist_printer.pl 	wpu/de/chlist_printer.pl
	cp wpu/cid_json.pl 			wpu/de/cid_json.pl
	cp wpu/compare_menu.pl		wpu/de/compare_menu.pl
	cp wpu/epg_json2xml.pl		wpu/de/epg_json2xml.pl
	cp wpu/wpu.sh				wpu/de/wpu.sh
	cp wpu/settings.sh			wpu/de/settings.sh
	
	cp easyepg_backup/wpu_de_init.json			wpu/de/init.json
	cp easyepg_backup/wpu_de_chlist_old			wpu/de/chlist_old
	cp easyepg_backup/wpu_de_channels.json		wpu/de/channels.json
	cp easyepg_backup/wpu_de_settings.json		wpu/de/settings.json
	cp easyepg_backup/wpu_de_user_userfile		wpu/de/user/userfile
	cp easyepg_backup/xml_wpu_de.xml			xml/waipu_de.xml 2> /dev/null
else
	echo "Skipping restore: waipu.tv DE - no setup found"
fi

# TV-SPIELFILM DE

if [ -e easyepg_backup/tvs_de_init.json ]
then
	echo "Restoring: TV-Spielfilm DE"
	mkdir tvs/de 2> /dev/null
	
	cp tvs/ch_json2xml.pl 		tvs/de/ch_json2xml.pl 
	cp tvs/chlist_printer.pl 	tvs/de/chlist_printer.pl
	cp tvs/cid_json.pl 			tvs/de/cid_json.pl
	cp tvs/compare_menu.pl		tvs/de/compare_menu.pl
	cp tvs/epg_json2xml.pl		tvs/de/epg_json2xml.pl
	cp tvs/tvs.sh				tvs/de/tvs.sh
	cp tvs/settings.sh			tvs/de/settings.sh
	cp tvs/url_printer.pl		tvs/de/url_printer.pl
	
	cp easyepg_backup/tvs_de_init.json			tvs/de/init.json
	cp easyepg_backup/tvs_de_chlist_old			tvs/de/chlist_old
	cp easyepg_backup/tvs_de_channels.json		tvs/de/channels.json
	cp easyepg_backup/tvs_de_settings.json		tvs/de/settings.json
	cp easyepg_backup/xml_tvs_de.xml			xml/tv-spielfilm_de.xml 2> /dev/null
else
	echo "Skipping restore: TV-Spielfilm DE - no setup found"
fi

# VODAFONE DE

if [ -e easyepg_backup/vdf_de_init.json ]
then
	echo "Restoring: Vodafone DE"
	mkdir vdf/de 2> /dev/null
	
	cp vdf/ch_json2xml.pl 		vdf/de/ch_json2xml.pl 
	cp vdf/chlist_printer.pl 	vdf/de/chlist_printer.pl
	cp vdf/cid_json.pl 			vdf/de/cid_json.pl
	cp vdf/compare_crid.pl		vdf/de/compare_crid.pl
	cp vdf/compare_menu.pl		vdf/de/compare_menu.pl
	cp vdf/epg_json2xml.pl		vdf/de/epg_json2xml.pl
	cp vdf/vdf.sh				vdf/de/vdf.sh
	cp vdf/settings.sh			vdf/de/settings.sh
	cp vdf/url_printer.pl		vdf/de/url_printer.pl
	
	cp easyepg_backup/vdf_de_init.json			vdf/de/init.json
	cp easyepg_backup/vdf_de_chlist_old			vdf/de/chlist_old
	cp easyepg_backup/vdf_de_channels.json		vdf/de/channels.json
	cp easyepg_backup/vdf_de_settings.json		vdf/de/settings.json
	cp easyepg_backup/xml_vdf_de.xml			xml/vodafone_de.xml 2> /dev/null
else
	echo "Skipping restore: Vodafone DE - no setup found"
fi

# TVTV US

if [ -e easyepg_backup/tvtv_us_init.json ]
then
	echo "Restoring: TVTV USA"
	mkdir tvtv/us 2> /dev/null

	cp tvtv/chlist_printer.pl 	tvtv/us/chlist_printer.pl
	cp tvtv/cid_json.pl 		tvtv/us/cid_json.pl
	cp tvtv/compare_crid.pl		tvtv/us/compare_crid.pl
	cp tvtv/compare_menu.pl		tvtv/us/compare_menu.pl	
	sed 's/XXX/us/g;s/ZZZ/2381D/g;s/YYY/USA/g;s/XYZ/USA/g' tvtv/tvtv.sh > tvtv/us/tvtv.sh 2> /dev/null
	sed 's/XXX/us/g;s/ZZZ/2381D/g;s/YYY/USA/g;s/XYZ/USA/g' tvtv/ch_json2xml.pl > tvtv/us/ch_json2xml.pl 2> /dev/null
	sed 's/XXX/us/g;s/ZZZ/2381D/g;s/YYY/USA/g;s/XYZ/USA/g' tvtv/epg_json2xml.pl > tvtv/us/epg_json2xml.pl 2> /dev/null
	sed 's/XXX/us/g;s/ZZZ/2381D/g;s/YYY/USA/g;s/XYZ/USA/g' tvtv/settings.sh > tvtv/us/settings.sh 2> /dev/null
	sed 's/XXX/us/g;s/ZZZ/2381D/g;s/YYY/USA/g;s/XYZ/USA/g' tvtv/url_printer.pl > tvtv/us/url_printer.pl 2> /dev/null

	cp easyepg_backup/tvtv_us_init.json			tvtv/us/init.json
	cp easyepg_backup/tvtv_us_chlist_old		tvtv/us/chlist_old
	cp easyepg_backup/tvtv_us_channels.json		tvtv/us/channels.json
	cp easyepg_backup/tvtv_us_settings.json		tvtv/us/settings.json
	cp easyepg_backup/xml_tvtv_us.xml			xml/tvtv_us.xml 2> /dev/null
else
	echo "Skipping restore: TVTV USA - no setup found"
fi

# TVTV CA

if [ -e easyepg_backup/tvtv_ca_init.json ]
then
	echo "Restoring: TVTV CANADA"
	mkdir tvtv/ca 2> /dev/null

	cp tvtv/chlist_printer.pl 	tvtv/ca/chlist_printer.pl
	cp tvtv/cid_json.pl			tvtv/ca/cid_json.pl
	cp tvtv/compare_crid.pl		tvtv/ca/compare_crid.pl
	cp tvtv/compare_menu.pl		tvtv/ca/compare_menu.pl
	sed 's/XXX/ca/g;s/ZZZ/1743/g;s/YYY/CANADA/g;s/XYZ/CN/g' tvtv/tvtv.sh > tvtv/ca/tvtv.sh 2> /dev/null
	sed 's/XXX/ca/g;s/ZZZ/1743/g;s/YYY/CANADA/g;s/XYZ/CN/g' tvtv/ch_json2xml.pl > tvtv/ca/ch_json2xml.pl 2> /dev/null
	sed 's/XXX/ca/g;s/ZZZ/1743/g;s/YYY/CANADA/g;s/XYZ/CN/g' tvtv/epg_json2xml.pl > tvtv/ca/epg_json2xml.pl 2> /dev/null
	sed 's/XXX/ca/g;s/ZZZ/1743/g;s/YYY/CANADA/g;s/XYZ/CN/g' tvtv/settings.sh > tvtv/ca/settings.sh 2> /dev/null
	sed 's/XXX/ca/g;s/ZZZ/1743/g;s/YYY/CANADA/g;s/XYZ/CN/g' tvtv/url_printer.pl > tvtv/ca/url_printer.pl 2> /dev/null

	cp easyepg_backup/tvtv_ca_init.json			tvtv/ca/init.json
	cp easyepg_backup/tvtv_ca_chlist_old		tvtv/ca/chlist_old
	cp easyepg_backup/tvtv_ca_channels.json		tvtv/ca/channels.json
	cp easyepg_backup/tvtv_ca_settings.json		tvtv/ca/settings.json
	cp easyepg_backup/xml_tvtv_ca.xml			xml/tvtv_ca.xml 2> /dev/null
else
	echo "Skipping restore: TVTV CANADA - no setup found"
fi

# EXTERNAL 1

if [ -e easyepg_backup/ext_oa_channels.json ]
then
	echo "Restoring: External 1"
	mkdir ext/oa 2> /dev/null
	
	cp ext/ch_ext.pl							ext/oa/ch_ext.pl
	cp ext/compare_menu.pl						ext/oa/compare_menu.pl
	cp ext/epg_ext.pl							ext/oa/epg_ext.pl
	cp ext/ext.sh								ext/oa/ext.sh
	cp ext/settings.sh							ext/oa/settings.sh
	
	cp easyepg_backup/ext_oa_chlist_old			ext/oa/chlist_old
	cp easyepg_backup/ext_oa_channels.json		ext/oa/channels.json
	cp easyepg_backup/ext_oa_settings.json		ext/oa/settings.json
	cp easyepg_backup/xml_ext_oa.xml			xml/external_oa.xml 2> /dev/null
else
	echo "Skipping restore: External 1 - no setup found"
fi

# EXTERNAL 2

if [ -e easyepg_backup/ext_ob_channels.json ]
then
	echo "Restoring: External 2"
	mkdir ext/ob 2> /dev/null
	
	cp ext/ch_ext.pl							ext/ob/ch_ext.pl
	cp ext/compare_menu.pl						ext/ob/compare_menu.pl
	cp ext/epg_ext.pl							ext/ob/epg_ext.pl
	cp ext/ext.sh								ext/ob/ext.sh
	cp ext/settings.sh							ext/ob/settings.sh
	
	cp easyepg_backup/ext_ob_chlist_old			ext/ob/chlist_old
	cp easyepg_backup/ext_ob_channels.json		ext/ob/channels.json
	cp easyepg_backup/ext_ob_settings.json		ext/ob/settings.json
	cp easyepg_backup/xml_ext_ob.xml			xml/external_ob.xml 2> /dev/null
else
	echo "Skipping restore: External 2 - no setup found"
fi

# EXTERNAL 3

if [ -e easyepg_backup/ext_oc_channels.json ]
then
	echo "Restoring: External 3"
	mkdir ext/oc 2> /dev/null
	
	cp ext/ch_ext.pl							ext/oc/ch_ext.pl
	cp ext/compare_menu.pl						ext/oc/compare_menu.pl
	cp ext/epg_ext.pl							ext/oc/epg_ext.pl
	cp ext/ext.sh								ext/oc/ext.sh
	cp ext/settings.sh							ext/oc/settings.sh
	
	cp easyepg_backup/ext_oc_chlist_old			ext/oc/chlist_old
	cp easyepg_backup/ext_oc_channels.json		ext/oc/channels.json
	cp easyepg_backup/ext_oc_settings.json		ext/oc/settings.json
	cp easyepg_backup/xml_ext_oc.xml			xml/external_oc.xml 2> /dev/null
else
	echo "Skipping restore: External 3 - no setup found"
fi


#
# RESTORE SETUP FILES FOR COMBINED XML
#

printf "\nRestoring combined XML setups...\n\n"

mkdir combine 2> /dev/null

# DEFINE FOLDERS

ls easyepg_backup/ | grep "combine" | grep "-settings.json" | sed "s/\(.*combine_\)\(.*\)\(-settings.json\)/\2/g" | uniq > /tmp/combine_list

if [ ! -s /tmp/combine_list ]
then
	echo "Skipping restore: No combined XML setups found"
fi

while [ -s /tmp/combine_list ]
do
	folder=$(sed -n "1p" /tmp/combine_list)
	echo "Restoring up files for $folder..."
	
	mkdir combine/$folder 2> /dev/null
	
	cp easyepg_backup/combine_$folder-settings.json			combine/$folder/settings.json			2> /dev/null
	cp easyepg_backup/combine_$folder-pre_setup.sh			combine/$folder/pre_setup.sh			2> /dev/null
	cp easyepg_backup/combine_$folder-setup.sh			 	combine/$folder/setup.sh				2> /dev/null
	cp easyepg_backup/combine_$folder.xml					xml/$folder.xml							2> /dev/null
	
	cp easyepg_backup/combine_$folder-hzn_de_channels.json 	combine/$folder/hzn_de_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_at_channels.json 	combine/$folder/hzn_at_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_ch_channels.json 	combine/$folder/hzn_ch_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_nl_channels.json 	combine/$folder/hzn_nl_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_pl_channels.json 	combine/$folder/hzn_pl_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_ie_channels.json 	combine/$folder/hzn_ie_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_sk_channels.json 	combine/$folder/hzn_sk_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_cz_channels.json 	combine/$folder/hzn_cz_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_hu_channels.json 	combine/$folder/hzn_hu_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-hzn_ro_channels.json 	combine/$folder/hzn_ro_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-ztt_de_channels.json 	combine/$folder/ztt_de_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-ztt_ch_channels.json 	combine/$folder/ztt_ch_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-swc_ch_channels.json 	combine/$folder/swc_ch_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-tvp_uk_channels.json 	combine/$folder/tvp_uk_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-tkm_de_channels.json 	combine/$folder/tkm_de_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-rdt_uk_channels.json 	combine/$folder/rdt_uk_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-wpu_de_channels.json 	combine/$folder/wpu_de_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-tvs_de_channels.json 	combine/$folder/tvs_de_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-vdf_de_channels.json 	combine/$folder/vdf_de_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-tvtv_us_channels.json 	combine/$folder/tvtv_us_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-tvtv_ca_channels.json 	combine/$folder/tvtv_ca_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-ext_oa_channels.json 	combine/$folder/ext_oa_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-ext_ob_channels.json 	combine/$folder/ext_ob_channels.json	2> /dev/null
	cp easyepg_backup/combine_$folder-ext_oc_channels.json 	combine/$folder/ext_oc_channels.json	2> /dev/null
	
	sed -i '1d' /tmp/combine_list
done

rm -rf /tmp/combine_list easyepg_backup 2> /dev/null

printf "\nDONE!\n\n"
