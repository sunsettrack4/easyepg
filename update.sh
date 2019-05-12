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
# UPDATE SCRIPT  #
# ################

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
sed 's/XX/AT/g;s/YYY/deu/g' easyepg/hzn/url_printer.pl > hzn/at/url_printer.pl 2> /dev/null
sed 's/XX/CH/g;s/YYY/deu/g' easyepg/hzn/url_printer.pl > hzn/ch/url_printer.pl 2> /dev/null
sed 's/XX/NL/g;s/YYY/nld/g' easyepg/hzn/url_printer.pl > hzn/nl/url_printer.pl 2> /dev/null
sed 's/XX/PL/g;s/YYY/pol/g' easyepg/hzn/url_printer.pl > hzn/pl/url_printer.pl 2> /dev/null
sed 's/XX/IE/g;s/YYY/eng/g' easyepg/hzn/url_printer.pl > hzn/ie/url_printer.pl 2> /dev/null
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

sed 's/\[XX\]/[DE]/g' easyepg/ztt/settings.sh > ztt/de/settings.sh 2> /dev/null
sed 's/\[XX\]/[CH]/g' easyepg/ztt/settings.sh > ztt/ch/settings.sh 2> /dev/null


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


# EXTERNAL
echo "Updating External..."

mkdir ext 2> /dev/null

echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/ext.sh 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/settings.sh 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/epg_ext.pl 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/ch_ext.pl 2> /dev/null
echo "ext/ ext/oa/ ext/ob/ ext/oc/" | xargs -n 1 cp -v easyepg/ext/compare_menu.pl 2> /dev/null


# DONE
echo "UPDATE FINISHED!"
 
