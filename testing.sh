#!/bin/bash

# #########################
# USE TESTING BRANCH      #
# #########################

# GIT CLONE

git clone https://github.com/sunsettrack4/easyepg --branch TESTING

# MAIN
echo "Updating main..."

cp easyepg/epg.sh epg.sh 2> /dev/null
cp easyepg/ch_combine.pl ch_combine.pl 2> /dev/null
cp easyepg/combine.sh combine.sh 2> /dev/null
cp easyepg/prog_combine.pl prog_combine.pl 2> /dev/null
cp easyepg/LICENSE LICENSE 2> /dev/null
cp easyepg/update.sh update.sh 2> /dev/null


# HORIZON
echo "Updating Horizon..."

mkdir hzn 2> /dev/null

echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/hzn.sh 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/ch_json2xml.pl 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/cid_json.pl 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/epg_json2xml.pl 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/settings.sh 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/chlist_printer.pl 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/compare_menu.pl.sh 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/hzn.sh 2> /dev/null
echo "hzn/ hzn/de/ hzn/at/ hzn/ch/ hzn/nl/ hzn/pl/ hzn/ie/ hzn/sk/ hzn/cz/ hzn/hu/ hzn/ro/" | xargs -n 1 cp -v easyepg/hzn/hzn.sh 2> /dev/null

sed 's/XX/DE/g;s/YYY/deu/g' easyepg/hzn/url_printer.pl > hzn/de/url_printer.pl 2> /dev/null
sed 's/XX/AT/g;s/YYY/deu/g;s/legacy-dynamic.oesp.horizon.tv/prod.oesp.magentatv.at/g' easyepg/hzn/url_printer.pl > hzn/at/url_printer.pl 2> /dev/null
sed 's/XX/CH/g;s/YYY/deu/g;s/legacy-dynamic.oesp.horizon.tv/obo-prod.oesp.upctv.ch/g' easyepg/hzn/url_printer.pl > hzn/ch/url_printer.pl 2> /dev/null
sed 's/XX/NL/g;s/YYY/nld/g;s/legacy-dynamic.oesp.horizon.tv/obo-prod.oesp.ziggogo.tv/g' easyepg/hzn/url_printer.pl > hzn/nl/url_printer.pl 2> /dev/null
sed 's/XX/PL/g;s/YYY/pol/g;s/legacy-dynamic.oesp.horizon.tv/prod.oesp.upctv.pl/g' easyepg/hzn/url_printer.pl > hzn/pl/url_printer.pl 2> /dev/null
sed 's/XX/IE/g;s/YYY/eng/g;s/legacy-dynamic.oesp.horizon.tv/prod.oesp.virginmediatv.ie/g' easyepg/hzn/url_printer.pl > hzn/ie/url_printer.pl 2> /dev/null
sed 's/XX/SK/g;s/YYY/slk/g' easyepg/hzn/url_printer.pl > hzn/sk/url_printer.pl 2> /dev/null
sed 's/XX/CZ/g;s/YYY/ces/g' easyepg/hzn/url_printer.pl > hzn/cz/url_printer.pl 2> /dev/null
sed 's/XX/HU/g;s/YYY/hun/g' easyepg/hzn/url_printer.pl > hzn/hu/url_printer.pl 2> /dev/null
sed 's/XX/RO/g;s/YYY/ron/g' easyepg/hzn/url_printer.pl > hzn/ro/url_printer.pl 2> /dev/null


# ZATTOO
echo "Updating Zattoo..."

mkdir ztt 2> /dev/null

echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/ztt.sh 2> /dev/null
echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/compare_crid.pl 2> /dev/null
echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/save_page.js 2> /dev/null
echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/epg_json2xml.pl 2> /dev/null
echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/ch_json2xml.pl 2> /dev/null
echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/cid_json.pl 2> /dev/null
echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/chlist_printer.pl 2> /dev/null
echo "ztt/ ztt/de/ ztt/ch/" | xargs -n 1 cp -v easyepg/ztt/compare_menu.pl 2> /dev/null

sed 's/\[XX\]/[DE]/g;s/XXXX/DE/g' easyepg/ztt/settings.sh > ztt/de/settings.sh 2> /dev/null
sed 's/\[XX\]/[CH]/g;s/XXXX/CH/g' easyepg/ztt/settings.sh > ztt/ch/settings.sh 2> /dev/null


# SWISSCOM
echo "Updating Swisscom..."

mkdir swc 2> /dev/null

echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/swc.sh 2> /dev/null
echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/settings.sh 2> /dev/null
echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/epg_json2xml.pl 2> /dev/null
echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/ch_json2xml.pl 2> /dev/null
echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/cid_json.pl 2> /dev/null
echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/chlist_printer.pl 2> /dev/null
echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/compare_menu.pl 2> /dev/null
echo "swc/ swc/ch/" | xargs -n 1 cp -v easyepg/swc/url_printer.pl 2> /dev/null


# TVPLAYER
echo "Updating tvPlayer..."

mkdir tvp 2> /dev/null

echo "tvp/ tvp/uk/" | xargs -n 1 cp -v easyepg/tvp/tvp.sh 2> /dev/null
echo "tvp/ tvp/uk/" | xargs -n 1 cp -v easyepg/tvp/settings.sh 2> /dev/null
echo "tvp/ tvp/uk/" | xargs -n 1 cp -v easyepg/tvp/epg_json2xml.pl 2> /dev/null
echo "tvp/ tvp/uk/" | xargs -n 1 cp -v easyepg/tvp/ch_json2xml.pl 2> /dev/null
echo "tvp/ tvp/uk/" | xargs -n 1 cp -v easyepg/tvp/cid_json.pl 2> /dev/null
echo "tvp/ tvp/uk/" | xargs -n 1 cp -v easyepg/tvp/chlist_printer.pl 2> /dev/null
echo "tvp/ tvp/uk/" | xargs -n 1 cp -v easyepg/tvp/compare_menu.pl 2> /dev/null


# TELEKOM
echo "Updating Telekom..."

mkdir tkm 2> /dev/null

echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/tkm.sh 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/settings.sh 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/epg_json2xml.pl 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/ch_json2xml.pl 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/cid_json.pl 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/chlist_printer.pl 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/compare_menu.pl 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/url_printer.pl 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/proxy.sh 2> /dev/null
echo "tkm/ tkm/de/" | xargs -n 1 cp -v easyepg/tkm/web_magentatv_de.php 2> /dev/null

# RADIOTIMES
echo "Updating RadioTimes..."

mkdir rdt 2> /dev/null

echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/rdt.sh 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/settings.sh 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/epg_json2xml.pl 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/ch_json2xml.pl 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/cid_json.pl 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/chlist_printer.pl 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/compare_menu.pl 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/compare_crid.pl 2> /dev/null
echo "rdt/ rdt/uk/" | xargs -n 1 cp -v easyepg/rdt/url_printer.pl 2> /dev/null


# WAIPU.TV
echo "Updating waipu.tv..."

mkdir wpu 2> /dev/null

echo "wpu/ wpu/de/" | xargs -n 1 cp -v easyepg/wpu/wpu.sh 2> /dev/null
echo "wpu/ wpu/de/" | xargs -n 1 cp -v easyepg/wpu/settings.sh 2> /dev/null
echo "wpu/ wpu/de/" | xargs -n 1 cp -v easyepg/wpu/epg_json2xml.pl 2> /dev/null
echo "wpu/ wpu/de/" | xargs -n 1 cp -v easyepg/wpu/ch_json2xml.pl 2> /dev/null
echo "wpu/ wpu/de/" | xargs -n 1 cp -v easyepg/wpu/cid_json.pl 2> /dev/null
echo "wpu/ wpu/de/" | xargs -n 1 cp -v easyepg/wpu/chlist_printer.pl 2> /dev/null
echo "wpu/ wpu/de/" | xargs -n 1 cp -v easyepg/wpu/compare_menu.pl 2> /dev/null

# TV-Spielfilm
echo "Updating TV-Spielfilm..."

mkdir tvs 2> /dev/null

echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/tvs.sh 2> /dev/null
echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/settings.sh 2> /dev/null
echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/epg_json2xml.pl 2> /dev/null
echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/ch_json2xml.pl 2> /dev/null
echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/cid_json.pl 2> /dev/null
echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/chlist_printer.pl 2> /dev/null
echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/compare_menu.pl 2> /dev/null
echo "tvs/ tvs/de/" | xargs -n 1 cp -v easyepg/tvs/url_printer.pl 2> /dev/null

# VODAFONE
echo "Updating VODAFONE..."

mkdir vdf 2> /dev/null

echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/vdf.sh 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/settings.sh 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/epg_json2xml.pl 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/ch_json2xml.pl 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/compare_crid.pl 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/cid_json.pl 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/chlist_printer.pl 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/compare_menu.pl 2> /dev/null
echo "vdf/ vdf/de/" | xargs -n 1 cp -v easyepg/vdf/url_printer.pl 2> /dev/null

# EXTERNAL
echo "Updating External..."

mkdir ext 2> /dev/null

echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/ext.sh 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/settings.sh 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/epg_ext.pl 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/ch_ext.pl 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/compare_menu.pl 2> /dev/null

echo "CLEAN"
rm -rf easyepg/

# DONE
echo "UPDATE FINISHED! --> Branch TESTING"
