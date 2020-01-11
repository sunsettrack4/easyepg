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

# ###############
# BACKUP SCRIPT #
# ###############

#
# CHECK IF BACKUP ZIP ALREADY EXISTS
#

if [ -e easyepg_backup.zip ]
then
	printf "Backup ZIP already exists - overwrite file?\n\n[0] NO\n[X] YES\n"
	read -n1 option
	
	if echo "$option" | grep -q "0"
	then
		printf " - STOP.\n\n"
		exit 0
	else
		rm easyepg_backup.zip
	fi
fi

#
# CREATE BACKUP FOLDER TO STORE THE FILES
#

mkdir easyepg_backup 2> /dev/null
rm easyepg_backup/* 2> /dev/null

#
# START BACKUP PROCESS
#

printf "Starting BACKUP process...\n\n"

# HORIZON DE

if [ -e hzn/de ]
then
	echo "Backing up: Horizon DE"
	cp hzn/de/chlist_old 		easyepg_backup/hzn_de_chlist_old
	cp hzn/de/channels.json 	easyepg_backup/hzn_de_channels.json
	cp hzn/de/init.json 		easyepg_backup/hzn_de_init.json
	cp hzn/de/settings.json 	easyepg_backup/hzn_de_settings.json
else
	echo "Skipping backup: Horizon DE - no setup found"
fi

# HORIZON AT

if [ -e hzn/at ]
then
	echo "Backing up: Horizon AT"
	cp hzn/at/chlist_old 		easyepg_backup/hzn_at_chlist_old
	cp hzn/at/channels.json 	easyepg_backup/hzn_at_channels.json
	cp hzn/at/init.json 		easyepg_backup/hzn_at_init.json
	cp hzn/at/settings.json 	easyepg_backup/hzn_at_settings.json
else
	echo "Skipping backup: Horizon AT - no setup found"
fi

# HORIZON CH

if [ -e hzn/ch ]
then
	echo "Backing up: Horizon CH"
	cp hzn/ch/chlist_old 		easyepg_backup/hzn_ch_chlist_old
	cp hzn/ch/channels.json 	easyepg_backup/hzn_ch_channels.json
	cp hzn/ch/init.json 		easyepg_backup/hzn_ch_init.json
	cp hzn/ch/settings.json 	easyepg_backup/hzn_ch_settings.json
else
	echo "Skipping backup: Horizon CH - no setup found"
fi

# HORIZON NL

if [ -e hzn/nl ]
then
	echo "Backing up: Horizon NL"
	cp hzn/nl/chlist_old 		easyepg_backup/hzn_nl_chlist_old
	cp hzn/nl/channels.json 	easyepg_backup/hzn_nl_channels.json
	cp hzn/nl/init.json 		easyepg_backup/hzn_nl_init.json
	cp hzn/nl/settings.json 	easyepg_backup/hzn_nl_settings.json
else
	echo "Skipping backup: Horizon NL - no setup found"
fi

# HORIZON PL

if [ -e hzn/pl ]
then
	echo "Backing up: Horizon PL"
	cp hzn/pl/chlist_old 		easyepg_backup/hzn_pl_chlist_old
	cp hzn/pl/channels.json 	easyepg_backup/hzn_pl_channels.json
	cp hzn/pl/init.json 		easyepg_backup/hzn_pl_init.json
	cp hzn/pl/settings.json 	easyepg_backup/hzn_pl_settings.json
else
	echo "Skipping backup: Horizon PL - no setup found"
fi

# HORIZON IE

if [ -e hzn/ie ]
then
	echo "Backing up: Horizon IE"
	cp hzn/ie/chlist_old 		easyepg_backup/hzn_ie_chlist_old
	cp hzn/ie/channels.json 	easyepg_backup/hzn_ie_channels.json
	cp hzn/ie/init.json 		easyepg_backup/hzn_ie_init.json
	cp hzn/ie/settings.json 	easyepg_backup/hzn_ie_settings.json
else
	echo "Skipping backup: Horizon IE - no setup found"
fi

# HORIZON SK

if [ -e hzn/sk ]
then
	echo "Backing up: Horizon SK"
	cp hzn/sk/chlist_old 		easyepg_backup/hzn_sk_chlist_old
	cp hzn/sk/channels.json 	easyepg_backup/hzn_sk_channels.json
	cp hzn/sk/init.json 		easyepg_backup/hzn_sk_init.json
	cp hzn/sk/settings.json 	easyepg_backup/hzn_sk_settings.json
else
	echo "Skipping backup: Horizon SK - no setup found"
fi

# HORIZON CZ

if [ -e hzn/cz ]
then
	echo "Backing up: Horizon CZ"
	cp hzn/cz/chlist_old 		easyepg_backup/hzn_cz_chlist_old
	cp hzn/cz/channels.json 	easyepg_backup/hzn_cz_channels.json
	cp hzn/cz/init.json 		easyepg_backup/hzn_cz_init.json
	cp hzn/cz/settings.json 	easyepg_backup/hzn_cz_settings.json
else
	echo "Skipping backup: Horizon CZ - no setup found"
fi

# HORIZON HU

if [ -e hzn/hu ]
then
	echo "Backing up: Horizon HU"
	cp hzn/hu/chlist_old 		easyepg_backup/hzn_hu_chlist_old
	cp hzn/hu/channels.json 	easyepg_backup/hzn_hu_channels.json
	cp hzn/hu/init.json 		easyepg_backup/hzn_hu_init.json
	cp hzn/hu/settings.json 	easyepg_backup/hzn_hu_settings.json
else
	echo "Skipping backup: Horizon HU - no setup found"
fi

# HORIZON RO

if [ -e hzn/ro ]
then
	echo "Backing up: Horizon RO"
	cp hzn/ro/chlist_old 		easyepg_backup/hzn_ro_chlist_old
	cp hzn/ro/channels.json 	easyepg_backup/hzn_ro_channels.json
	cp hzn/ro/init.json 		easyepg_backup/hzn_ro_init.json
	cp hzn/ro/settings.json 	easyepg_backup/hzn_ro_settings.json
else
	echo "Skipping backup: Horizon RO - no setup found"
fi

# ZATTOO DE

if [ -e ztt/de ]
then
	echo "Backing up: Zattoo DE"
	cp ztt/de/user/userfile		easyepg_backup/ztt_de_user_userfile
	cp ztt/de/chlist_old		easyepg_backup/ztt_de_chlist_old
	cp ztt/de/channels.json 	easyepg_backup/ztt_de_channels.json
	cp ztt/de/init.json 		easyepg_backup/ztt_de_init.json
	cp ztt/de/settings.json 	easyepg_backup/ztt_de_settings.json
else
	echo "Skipping backup: Zattoo DE - no setup found"
fi

# ZATTOO CH

if [ -e ztt/ch ]
then
	echo "Backing up: Zattoo CH"
	cp ztt/ch/user/userfile		easyepg_backup/ztt_ch_user_userfile
	cp ztt/ch/chlist_old		easyepg_backup/ztt_ch_chlist_old
	cp ztt/ch/channels.json 	easyepg_backup/ztt_ch_channels.json
	cp ztt/ch/init.json 		easyepg_backup/ztt_ch_init.json
	cp ztt/ch/settings.json 	easyepg_backup/ztt_ch_settings.json
else
	echo "Skipping backup: Zattoo CH - no setup found"
fi

# SWISSCOM CH

if [ -e swc/ch ]
then
	echo "Backing up: Swisscom CH"
	cp swc/ch/chlist_old 		easyepg_backup/swc_ch_chlist_old
	cp swc/ch/channels.json 	easyepg_backup/swc_ch_channels.json
	cp swc/ch/init.json 		easyepg_backup/swc_ch_init.json
	cp swc/ch/settings.json 	easyepg_backup/swc_ch_settings.json
else
	echo "Skipping backup: Swisscom CH - no setup found"
fi

# TVPLAYER UK

if [ -e tvp/uk ]
then
	echo "Backing up: tvPlayer UK"
	cp tvp/uk/chlist_old 		easyepg_backup/tvp_uk_chlist_old
	cp tvp/uk/channels.json 	easyepg_backup/tvp_uk_channels.json
	cp tvp/uk/init.json 		easyepg_backup/tvp_uk_init.json
	cp tvp/uk/settings.json 	easyepg_backup/tvp_uk_settings.json
else
	echo "Skipping backup: tvPlayer UK - no setup found"
fi

# MAGENTA TV DE

if [ -e tkm/de ]
then
	echo "Backing up: Magenta TV DE"
	cp tkm/de/chlist_old 		easyepg_backup/tkm_de_chlist_old
	cp tkm/de/channels.json 	easyepg_backup/tkm_de_channels.json
	cp tkm/de/init.json 		easyepg_backup/tkm_de_init.json
	cp tkm/de/settings.json 	easyepg_backup/tkm_de_settings.json
else
	echo "Skipping backup: Magenta TV DE - no setup found"
fi

# RADIOTIMES UK

if [ -e rdt/uk ]
then
	echo "Backing up: RadioTimes UK"
	cp rdt/uk/chlist_old 		easyepg_backup/rdt_uk_chlist_old
	cp rdt/uk/channels.json 	easyepg_backup/rdt_uk_channels.json
	cp rdt/uk/init.json 		easyepg_backup/rdt_uk_init.json
	cp rdt/uk/settings.json 	easyepg_backup/rdt_uk_settings.json
else
	echo "Skipping backup: RadioTimes UK - no setup found"
fi

# WAIPU.TV DE

if [ -e wpu/de ]
then
	echo "Backing up: waipu.tv DE"
	cp wpu/de/user/userfile		easyepg_backup/wpu_de_user_userfile
	cp wpu/de/chlist_old		easyepg_backup/wpu_de_chlist_old
	cp wpu/de/channels.json 	easyepg_backup/wpu_de_channels.json
	cp wpu/de/init.json 		easyepg_backup/wpu_de_init.json
	cp wpu/de/settings.json 	easyepg_backup/wpu_de_settings.json
else
	echo "Skipping backup: waipu.tv DE - no setup found"
fi

# TV-SPIELFILM DE

if [ -e tvs/de ]
then
	echo "Backing up: TV-Spielfilm DE"
	cp tvs/de/chlist_old 		easyepg_backup/tvs_de_chlist_old
	cp tvs/de/channels.json 	easyepg_backup/tvs_de_channels.json
	cp tvs/de/init.json 		easyepg_backup/tvs_de_init.json
	cp tvs/de/settings.json 	easyepg_backup/tvs_de_settings.json
else
	echo "Skipping backup: TV-Spielfilm DE - no setup found"
fi

# VODAFONE DE

if [ -e vdf/de ]
then
	echo "Backing up: Vodafone DE"
	cp vdf/de/chlist_old 		easyepg_backup/vdf_de_chlist_old
	cp vdf/de/channels.json 	easyepg_backup/vdf_de_channels.json
	cp vdf/de/init.json 		easyepg_backup/vdf_de_init.json
	cp vdf/de/settings.json 	easyepg_backup/vdf_de_settings.json
else
	echo "Skipping backup: Vodafone DE - no setup found"
fi

# TVTV US

if [ -e tvtv/us ]
then
	echo "Backing up: TVTV USA"
	cp tvtv/us/user/userfile		easyepg_backup/tvtv_us_user_userfile
	cp tvtv/us/chlist_old		easyepg_backup/tvtv_us_chlist_old
	cp tvtv/us/channels.json 	easyepg_backup/tvtv_us_channels.json
	cp tvtv/us/init.json 		easyepg_backup/tvtv_us_init.json
	cp tvtv/us/settings.json 	easyepg_backup/tvtv_us_settings.json
else
	echo "Skipping backup: TVTV USA - no setup found"
fi

# TVTV CA

if [ -e tvtv/ca ]
then
	echo "Backing up: TVTV CANNADA"
	cp tvtv/ca/user/userfile		easyepg_backup/tvtv_ca_user_userfile
	cp tvtv/ca/chlist_old		easyepg_backup/tvtv_ca_chlist_old
	cp tvtv/ca/channels.json 	easyepg_backup/tvtv_ca_channels.json
	cp tvtv/ca/init.json 		easyepg_backup/tvtv_ca_init.json
	cp tvtv/ca/settings.json 	easyepg_backup/tvtv_ca_settings.json
else
	echo "Skipping backup: TVTV CANNADA - no setup found"
fi

# EXTERNAL 1

if [ -e ext/oa ]
then
	echo "Backing up: External 1"
	cp ext/oa/chlist_old 		easyepg_backup/ext_oa_chlist_old
	cp ext/oa/channels.json 	easyepg_backup/ext_oa_channels.json
	cp ext/oa/settings.json 	easyepg_backup/ext_oa_settings.json
else
	echo "Skipping backup: External 1 - no setup found"
fi

# EXTERNAL 2

if [ -e ext/ob ]
then
	echo "Backing up: External 2"
	cp ext/ob/chlist_old 		easyepg_backup/ext_ob_chlist_old
	cp ext/ob/channels.json 	easyepg_backup/ext_ob_channels.json
	cp ext/ob/settings.json 	easyepg_backup/ext_ob_settings.json
else
	echo "Skipping backup: External 2 - no setup found"
fi

# EXTERNAL 3

if [ -e ext/oc ]
then
	echo "Backing up: External 3"
	cp ext/oc/chlist_old 		easyepg_backup/ext_oc_chlist_old
	cp ext/oc/channels.json 	easyepg_backup/ext_oc_channels.json
	cp ext/oc/settings.json 	easyepg_backup/ext_oc_settings.json
else
	echo "Skipping backup: External 3 - no setup found"
fi

#
# BACKUP XML FILES FOR COMBINED SETUP
#

printf "\nBacking up provider XML files...\n\n"

# HORIZON DE

if [ -e xml/horizon_de.xml ]
then
	echo "Backing up XML: Horizon DE"
	cp xml/horizon_de.xml		easyepg_backup/xml_hzn_de.xml
else
	echo "Skipping backup: Horizon DE - XML file not found"
fi

# HORIZON AT

if [ -e xml/horizon_at.xml ]
then
	echo "Backing up XML: Horizon AT"
	cp xml/horizon_at.xml		easyepg_backup/xml_hzn_at.xml
else
	echo "Skipping backup: Horizon AT - XML file not found"
fi

# HORIZON CH

if [ -e xml/horizon_ch.xml ]
then
	echo "Backing up XML: Horizon CH"
	cp xml/horizon_ch.xml		easyepg_backup/xml_hzn_ch.xml
else
	echo "Skipping backup: Horizon CH - XML file not found"
fi

# HORIZON NL

if [ -e xml/horizon_nl.xml ]
then
	echo "Backing up XML: Horizon NL"
	cp xml/horizon_nl.xml		easyepg_backup/xml_hzn_nl.xml
else
	echo "Skipping backup: Horizon NL - XML file not found"
fi

# HORIZON PL

if [ -e xml/horizon_pl.xml ]
then
	echo "Backing up XML: Horizon PL"
	cp xml/horizon_pl.xml		easyepg_backup/xml_hzn_pl.xml
else
	echo "Skipping backup: Horizon PL - XML file not found"
fi

# HORIZON IE

if [ -e xml/horizon_ie.xml ]
then
	echo "Backing up XML: Horizon IE"
	cp xml/horizon_ie.xml		easyepg_backup/xml_hzn_ie.xml
else
	echo "Skipping backup: Horizon IE - XML file not found"
fi

# HORIZON SK

if [ -e xml/horizon_sk.xml ]
then
	echo "Backing up XML: Horizon SK"
	cp xml/horizon_sk.xml		easyepg_backup/xml_hzn_sk.xml
else
	echo "Skipping backup: Horizon SK - XML file not found"
fi

# HORIZON CZ

if [ -e xml/horizon_cz.xml ]
then
	echo "Backing up XML: Horizon CZ"
	cp xml/horizon_cz.xml		easyepg_backup/xml_hzn_cz.xml
else
	echo "Skipping backup: Horizon CZ - XML file not found"
fi

# HORIZON HU

if [ -e xml/horizon_hu.xml ]
then
	echo "Backing up XML: Horizon HU"
	cp xml/horizon_hu.xml		easyepg_backup/xml_hzn_hu.xml
else
	echo "Skipping backup: Horizon HU - XML file not found"
fi

# HORIZON RO

if [ -e xml/horizon_ro.xml ]
then
	echo "Backing up XML: Horizon RO"
	cp xml/horizon_ro.xml		easyepg_backup/xml_hzn_ro.xml
else
	echo "Skipping backup: Horizon RO - XML file not found"
fi

# ZATTOO DE

if [ -e xml/zattoo_de.xml ]
then
	echo "Backing up XML: Zattoo DE"
	cp xml/zattoo_de.xml		easyepg_backup/xml_ztt_de.xml
else
	echo "Skipping backup: Zattoo DE - XML file not found"
fi

# ZATTOO CH

if [ -e xml/zattoo_ch.xml ]
then
	echo "Backing up XML: Zattoo CH"
	cp xml/zattoo_ch.xml		easyepg_backup/xml_ztt_ch.xml
else
	echo "Skipping backup: Zattoo CH - XML file not found"
fi

# SWISSCOM CH

if [ -e xml/swisscom_ch.xml ]
then
	echo "Backing up XML: Swisscom CH"
	cp xml/swisscom_ch.xml		easyepg_backup/xml_swc_ch.xml
else
	echo "Skipping backup: Swisscom CH - XML file not found"
fi

# TVPLAYER UK

if [ -e xml/tvp_uk.xml ]
then
	echo "Backing up XML: tvPlayer UK"
	cp xml/tvp_uk.xml		easyepg_backup/xml_tvp_uk.xml
else
	echo "Skipping backup: tvPlayer UK - XML file not found"
fi

# MAGENTA TV DE

if [ -e xml/magentatv_de.xml ]
then
	echo "Backing up XML: Magenta TV DE"
	cp xml/magentatv_de.xml		easyepg_backup/xml_tkm_de.xml
else
	echo "Skipping backup: Magenta TV DE - XML file not found"
fi

# RADIOTIMES UK

if [ -e xml/radiotimes_uk.xml ]
then
	echo "Backing up XML: RadioTimes UK"
	cp xml/radiotimes_uk.xml	easyepg_backup/xml_rdt_uk.xml
else
	echo "Skipping backup: RadioTimes UK - XML file not found"
fi

# WAIPU.TV DE

if [ -e xml/waipu_de.xml ]
then
	echo "Backing up XML: waipu.tv DE"
	cp xml/waipu_de.xml		easyepg_backup/xml_wpu_de.xml
else
	echo "Skipping backup: waipu.tv DE - XML file not found"
fi

# TV-SPIELFILM DE

if [ -e xml/tv-spielfilm_de.xml ]
then
	echo "Backing up XML: TV-Spielfilm DE"
	cp xml/tv-spielfilm_de.xml		easyepg_backup/xml_tvs_de.xml
else
	echo "Skipping backup: TV-Spielfilm DE - XML file not found"
fi

# VODAFONE DE

if [ -e xml/vodafone_de.xml ]
then
	echo "Backing up XML: Vodafone DE"
	cp xml/vodafone_de.xml		easyepg_backup/xml_vdf_de.xml
else
	echo "Skipping backup: Vodafone DE - XML file not found"
fi

# TVTV US

if [ -e xml/tvtv_us.xml ]
then
	echo "Backing up XML: TVTV US"
	cp xml/tvtv_us.xml		easyepg_backup/xml_tvtv_us.xml
else
	echo "Skipping backup: TVTV USA - XML file not found"
fi

# TVTV CA

if [ -e xml/tvtv_ca.xml ]
then
	echo "Backing up XML: TVTV CANADA"
	cp xml/tvtv_ca.xml		easyepg_backup/xml_tvtv_ca.xml
else
	echo "Skipping backup: TVTV CANADA - XML file not found"
fi

# EXTERNAL 1

if [ -e xml/external_oa.xml ]
then
	echo "Backing up XML: External 1"
	cp xml/external_oa.xml		easyepg_backup/xml_ext_oa.xml
else
	echo "Skipping backup: External 1 - XML file not found"
fi

# EXTERNAL 2

if [ -e xml/external_ob.xml ]
then
	echo "Backing up XML: External 2"
	cp xml/external_ob.xml		easyepg_backup/xml_ext_ob.xml
else
	echo "Skipping backup: External 2 - XML file not found"
fi

# EXTERNAL 3

if [ -e xml/external_oc.xml ]
then
	echo "Backing up XML: External 3"
	cp xml/external_oc.xml		easyepg_backup/xml_ext_oc.xml
else
	echo "Skipping backup: External 3 - XML file not found"
fi


#
# BACKUP SETUP FILES FOR COMBINED XML
#

printf "\nBacking up combined XML setups...\n\n"

# CREATING LIST

ls combine > /tmp/combine_list 2> /dev/null

if [ ! -s /tmp/combine_list ]
then
	echo "Skipping backup: No combined XML setups found"
fi

while [ -s /tmp/combine_list ]
do
	folder=$(sed -n "1p" /tmp/combine_list)
	echo "Backing up files for $folder..."
	
	cp combine/$folder/settings.json			easyepg_backup/combine_$folder-settings.json	 2> /dev/null
	cp combine/$folder/pre_setup.sh				easyepg_backup/combine_$folder-pre_setup.sh		 2> /dev/null
	cp combine/$folder/setup.sh					easyepg_backup/combine_$folder-setup.sh			 2> /dev/null
	cp xml/$folder.xml							easyepg_backup/combine_$folder.xml				 2> /dev/null
	
	if [ -e combine/$folder/run.pl ]
	then
		printf "\nCAUTION: IMDB Mapper will NOT be saved - please re-enable the mapper in settings after restoring $folder!\n"
	fi
	
	if [ -e combine/$folder/ratingmapper.pl ]
	then
		printf "\nCAUTION: Ratingmapper will NOT be saved - please re-enable the mapper in settings after restoring $folder!\n"
	fi
	
	cp combine/$folder/hzn_de_channels.json		easyepg_backup/combine_$folder-hzn_de_channels.json 2> /dev/null
	cp combine/$folder/hzn_at_channels.json		easyepg_backup/combine_$folder-hzn_at_channels.json 2> /dev/null
	cp combine/$folder/hzn_ch_channels.json		easyepg_backup/combine_$folder-hzn_ch_channels.json 2> /dev/null
	cp combine/$folder/hzn_nl_channels.json		easyepg_backup/combine_$folder-hzn_nl_channels.json 2> /dev/null
	cp combine/$folder/hzn_pl_channels.json		easyepg_backup/combine_$folder-hzn_pl_channels.json 2> /dev/null
	cp combine/$folder/hzn_ie_channels.json		easyepg_backup/combine_$folder-hzn_ie_channels.json 2> /dev/null
	cp combine/$folder/hzn_sk_channels.json		easyepg_backup/combine_$folder-hzn_sk_channels.json 2> /dev/null
	cp combine/$folder/hzn_cz_channels.json		easyepg_backup/combine_$folder-hzn_cz_channels.json 2> /dev/null
	cp combine/$folder/hzn_hu_channels.json		easyepg_backup/combine_$folder-hzn_hu_channels.json 2> /dev/null
	cp combine/$folder/hzn_ro_channels.json		easyepg_backup/combine_$folder-hzn_ro_channels.json 2> /dev/null
	cp combine/$folder/ztt_de_channels.json		easyepg_backup/combine_$folder-ztt_de_channels.json 2> /dev/null
	cp combine/$folder/ztt_ch_channels.json		easyepg_backup/combine_$folder-ztt_ch_channels.json 2> /dev/null
	cp combine/$folder/swc_ch_channels.json		easyepg_backup/combine_$folder-swc_ch_channels.json 2> /dev/null
	cp combine/$folder/tvp_uk_channels.json		easyepg_backup/combine_$folder-tvp_uk_channels.json 2> /dev/null
	cp combine/$folder/tkm_de_channels.json		easyepg_backup/combine_$folder-tkm_de_channels.json 2> /dev/null
	cp combine/$folder/rdt_uk_channels.json		easyepg_backup/combine_$folder-rdt_uk_channels.json 2> /dev/null
	cp combine/$folder/wpu_de_channels.json		easyepg_backup/combine_$folder-wpu_de_channels.json 2> /dev/null
	cp combine/$folder/tvs_de_channels.json		easyepg_backup/combine_$folder-tvs_de_channels.json 2> /dev/null
	cp combine/$folder/vdf_de_channels.json		easyepg_backup/combine_$folder-vdf_de_channels.json 2> /dev/null
	cp combine/$folder/tvtv_us_channels.json	easyepg_backup/combine_$folder-tvtv_us_channels.json 2> /dev/null
	cp combine/$folder/tvtv_ca_channels.json	easyepg_backup/combine_$folder-tvtv_ca_channels.json 2> /dev/null
	cp combine/$folder/ext_oa_channels.json		easyepg_backup/combine_$folder-ext_oa_channels.json 2> /dev/null
	cp combine/$folder/ext_ob_channels.json		easyepg_backup/combine_$folder-ext_ob_channels.json 2> /dev/null
	cp combine/$folder/ext_oc_channels.json		easyepg_backup/combine_$folder-ext_oc_channels.json 2> /dev/null
	
	sed -i '1d' /tmp/combine_list
done

rm /tmp/combine_list 2> /dev/null
	

#
# COMPRESS BACKUP FOLDER
#

printf "\nCompressing backup folder...\n\n"

zip easyepg_backup.zip easyepg_backup/*
rm -rf easyepg_backup 2> /dev/null

printf "\nDONE!\n\n"
