#!/usr/bin/perl

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

# ##################################
# TVTV JSON > XML CONVERTER        #
# ##################################

# CHANNELS

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
use utf8;
 
use JSON;

# READ JSON INPUT FILE: CHLIST
my $json;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "chlist" or die;
    $json = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: TVTV HARDCODED CHLIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tvtv_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: CHANNEL CONFIG
my $chlist_config;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "channels.json" or die;
    $chlist_config = <$fh>;
    close $fh;
}

# READ INIT FILE
my $init;
{
	local $/; #Enable 'slurp' mode
    open my $fh, '<', "init.json" or die;
    $init = <$fh>;
    close $fh;
}

# READ SETTINGS FILE
my $settings;
{
	local $/; #Enable 'slurp' mode
    open my $fh, '<', "settings.json" or die;
    $settings = <$fh>;
    close $fh;
}

# CONVERT JSON TO PERL STRUCTURES
my $data        = decode_json($json);
my $chdata      = decode_json($chlist);
my $configdata  = decode_json($chlist_config);
my $initdata    = decode_json($init);
my $setupdata   = decode_json($settings);

# DEFINE COUNTRY VERSION
my $countryVER =  $initdata->{'country'};

my @stations = @{ $data->{'stations'} };
foreach my $stations ( @stations ) {
		
	# ####################
    # DEFINE JSON VALUES #
    # ####################
        
    # DEFINE CHANNEL ID + NAME
	my $cname   = $stations->{'name'};
	$cname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
	
	# DEFINE CHANNEL LOGO
	my $logo	= $stations->{'logoFilename'};
        
    # DEFINE LANGUAGE VERSION
    # my $languageVER =  $initdata->{'language'};
    my $languageVER = $stations->{'Languages'}[0];
        
    # DEFINE RYTEC CHANNEL ID (language)
	my $rytec = $chdata->{'channels'}{$countryVER};
	
	# DEFINE SELECTED CHANNELS
	my @configdata = @{ $configdata->{'channels'} };
		
	# DEFINE SETTINGS
    my $setup_general  = $setupdata->{'settings'};
    my $setup_cid      = $setup_general->{'cid'};
        
    # DEFINE SETTINGS VALUES
    my $enabled  = "enabled";
    my $disabled = "disabled";
        
        
    # ##################
	# PRINT XML OUTPUT #
	# ##################
        
	# CHANNEL ID (condition) (settings)
	foreach my $selected_channel ( @configdata ) {
		if( $cname eq $selected_channel ) { 
			if( $setup_cid eq $enabled ) {
				if( defined $rytec->{$cname} ) {
					print "<channel id=\"" . $rytec->{$cname} . "\">";
				} else {
					print "<channel id=\"" . $cname . "\">";
					print STDERR "[ CHLIST WARNING ] Rytec ID not matched for: " . $cname . "\n";
				}
			} else {
				print "<channel id=\"" . $cname . "\">";
			}
			
			# CHANNEL NAME (language)
			print "<display-name lang=\"de\">" . $cname . "</display-name>";
			
			# CHANNEL LOGO
			if( $logo ne "" ) {
				print "<icon src=\"https://cdn.tvpassport.com/image/station/100x100/$logo\" /></channel>\n";
			} else {
				print "</channel>\n";
			}
		}
	}
}
