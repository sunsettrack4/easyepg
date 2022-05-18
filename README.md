# easyEPG
WebGrab++ alternative :)

## About this project
This tool provides high-quality EPG data from different IPTV/OTT sources.

#### Advantages
* Fast downloads from official TV providers
* Combine multiple sources, create one single XML file
* Import XML files from external web sources and/or re-use XML files created by WebGrab++
* Run additional scripts after final XML file creation
* Update the XML files automatically via crontab

#### Supported TV providers
* Horizon (DE,AT,CH,NL,PL,IE,SK,CZ,HU,RO)
* Zattoo (DE,CH)
* Magenta TV (DE)
* WaipuTV (DE)
* TV-Spielfilm (DE)
* Swisscom (CH)

#### Supported platforms
* any Linux-based OS, e.g. Ubuntu, Debian

## The power of open source
You are welcome to test the script on your machine.
* If any errors occur, please open an issue on the GitHub project page.
* Help me by providing bug fixes etc. via pull requests.

## Disclaimer
All scripts provided by this project are licensed under GPL 3.0.
This includes a limitation of liability. The license also states that it does not provide any warranty.

## Support my work
If you like my script, please [![Paypal Donation Page](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://paypal.me/sunsettrack4) - thank you! :-)

# Installation

## EPG script
Please run the commands below to setup the script. "Sudo" is not required on user "root".

```bash
# Install all recommended applications to setup the epg environment completely:
sudo apt-get install cron dialog curl wget libxml2-utils perl nano perl-doc jq php php-curl git xml-twig-tools unzip liblocal-lib-perl cpanminus build-essential inetutils-ping 

# Install CPAN and the required modules to parse JSON files
sudo cpan App:cpanminus
sudo cpanm install JSON
sudo cpanm install XML::Rules
sudo cpanm install XML::DOM
sudo cpanm install Data::Dumper
sudo cpanm install Time::Piece
sudo cpanm install Time::Seconds
sudo cpanm install DateTime
sudo cpanm install DateTime::Format::DateParse
sudo cpanm install utf8
sudo cpanm install DateTime::Format::Strptime

# Create any directory in your desired location, e.g.:
mkdir ~/easyepg

# Download the .zip file and extract the files into your folder:
wget https://github.com/sunsettrack4/easyepg/archive/refs/heads/master.zip

# Unzip the file:
unzip easyepg-master.zip

# Move all script files to the created folder
mv ~/easyepg-master/* ~/easyepg/

# Set system-wide permissions to the folder and its related files
sudo chmod 0777 ~/easyepg
sudo chmod 0777 ~/easyepg/*

# Run the main script from your script folder to enter the setup screen in terminal
cd ~/easyepg
bash epg.sh
```
.
.
.
## Main Menu
Please hit the CANCEL button to exit the dialog menu of the script.
#### 1) ADD GRABBER INSTANCE
* add an EPG source you want to use for XML file creation
#### 2) OPEN GRABBER SETTINGS
* if any grabbers were added, you can change the related settings there
#### 3) MODIFY XML FILES
* if any XML files were created, you can combine the sources and run additional scripts
#### 4) CONTINUE IN GRABBER MODE
* continue to grab EPG data and to create XML files
#### 5) UPDATE THIS SCRIPT
* update the script environment from public repository
#### 6) ABOUT EASYEPG
.
.
.
## Provider settings
If you choose a provider to grab EPG data, you are able to select the channels you want to retrieve.
Afterwards, the following options are available:
#### 1) MODIFY CHANNEL LIST
* add/remove channel from download list
#### 2) TIME PERIOD
* select the time range (0 = disable, up to 14 days)
#### 3) CONVERT CHANNEL IDs INTO RYTEC FORMAT
* use the TVG-IDs provided by the Rytec project
#### 4) CONVERT CATEGORIES INTO EIT FORMAT
* useful for tvHeadend users
#### 5) USE MULTIPLE CATEGORIES
* show more than one category per broadcast
#### 6) EPISODE FORMAT
* onscreen: use universal text format for episode data
* xmltv_ns: episode data to be parsed by tvHeadend
#### 7) RUN XML SCRIPT
* run the grabber script of the selected provider only
#### 8) DELETE CACHE FILES
* remove the cache database of the selected provider
#### 9) REMOVE GRABBER INSTANCE
.
.
.
## Modify XML files
One of the most important features is the modification of XML files.
This option allows you to combine channels from multiple sources, and to run additional scripts before/after final XML file creation.

IMPORTANT: The grabbers of the providers defined in "GRABBER SETTINGS" must run/update the environment successfully to select new channels!

#### 1) MODIFY CHANNEL LIST
* add/remove channel from XML list
#### 2) USE ADDON SCRIPTS
* add/remove addon scripts provided by official and public repositories
* currently supported: RATING MAPPER and NEW IMDB MAPPER
#### 3) ADD/MODIFY PRE SHELL SCRIPT
* run a shell script before starting the addon scripts
#### 4) ADD/MODIFY POST SHELL SCRIPT
* start a shell script after running the addon scripts
#### 5) CREATE CHANNEL LIST AS TXT FILE
* create a channel list with TVG-IDs of the created XML file
* the file will be stored in "XML" folder
#### 6) TIME PERIOD
* select the time range (0 = disable, up to 14 days)
#### 7) RUN COMBINE SCRIPT
* run the combine script of the selected environment without updating the EPG database
#### 9) REMOVE THIS SETUP
.
.
.
## External provider settings
You are able to import XML files from external sources (any files on your local hard drive, or a public internet source).
Please select the option "EXTERNAL" in menu "ADD GRABBER INSTANCE" to enter the external XML resource.

## Complete the setup
* Please use crontab to update the EPG data and XML files automatically
```bash
# Enter this command to enter the settings of crontab
crontab -e
```
```bash
# Setup to run the script daily at 3 AM
0 3 * * * cd ~/easyepg && bash epg.sh
```
* Please use sudo crontab to update the EPG data in tvHeadend automatically
```bash
# Enter this command to enter the admin settings of crontab ("sudo" not required for user "root")
sudo crontab -e
```
```bash
# Setup to update the EPG twice (recommended to update the EPG schedule times correcty)
0 6 * * * cat /home/<user>/easyepg/xml/<file> | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
5 6 * * * cat /home/<user>/easyepg/xml/<file> | socat - UNIX-CONNECT:/home/hts/.hts/tvheadend/epggrab/xmltv.sock
# enter your PC name instead of "<user>"
# enter the correct file name instead of "<file>"
```
.
.
.
## Further support
Contact me for support via email: sunsettrack4@gmail.com

FAQ section to follow :-)
