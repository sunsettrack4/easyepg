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

# ##############################
# HORIZON JSON > XML CONVERTER #
# ##############################

# CHANNELS

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
use utf8;
 
use JSON;

# READ JSON INPUT FILE: HZN HARDCODED CHLIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "hzn_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: CHANNEL CONFIG
my $chlist_config;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/compare.json" or die;
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
my $chdata      = decode_json($chlist);
my $configdata  = decode_json($chlist_config);
my $initdata    = decode_json($init);
my $setupdata   = decode_json($settings);

# DEFINE COUNTRY VERSION
my $countryVER =  $initdata->{'country'};

		
# ####################
# DEFINE JSON VALUES #
# ####################
        
# DEFINE LANGUAGE VERSION
my $languageVER =  $initdata->{'language'};
        
# DEFINE RYTEC CHANNEL ID (language)
my $rytec = $chdata->{'channels'}{$countryVER};
		
# DEFINE SELECTED CHANNELS
my @configdata = @{ $configdata->{'config'} };
		
# DEFINE COMPARE DATA
my $new_name2id = $configdata->{'newname2id'};
my $new_id2name = $configdata->{'newid2name'};
my $old_name2id = $configdata->{'oldname2id'};
my $old_id2name = $configdata->{'oldid2name'};
my $new_name2logo = $configdata->{'newname2logo'};
my $old_name2logo = $configdata->{'oldname2logo'};
		
# DEFINE SETTINGS
my $setup_general  = $setupdata->{'settings'};
my $setup_cid      = $setup_general->{'cid'};
        
# DEFINE SETTINGS VALUES
my $enabled  = "enabled";
my $disabled = "disabled";
        
        
# ##################
# PRINT XML OUTPUT #
# ##################
        
foreach my $selected_channel ( @configdata ) {
			
	my $new_id    = $new_name2id->{$selected_channel};
	my $old_id    = $old_name2id->{$selected_channel};

	#
	# CONDITION: OLD CHANNEL NAME CAN BE FOUND IN NEW CHANNEL LIST
	#
	
	if( defined $new_id and $selected_channel ne "DUMMY" ) { 
				
		# CHANNEL ID (condition) (settings)
		if( $setup_cid eq $enabled ) {
			if( defined $rytec->{$selected_channel} ) {
				print "<channel id=\"" . $rytec->{$selected_channel} . "\">";
			} else {
				print "<channel id=\"" . $selected_channel . "\">";
				print STDERR "[ CHLIST WARNING ] Rytec ID not matched for: " . $selected_channel . "\n";
			}
		} else {
			print "<channel id=\"" . $selected_channel . "\">";
		}
		
		# CHANNEL NAME + LOGO (language) (loop)
		my $new_logo = $new_name2logo->{$selected_channel};
		if( defined $new_logo ) {
			print "<display-name lang=\"$languageVER\">" . $selected_channel . "</display-name>";
			print "<icon src=\"$new_logo\" /></channel>\n";
		} else {
			print "<display-name lang=\"$languageVER\">" . $selected_channel . "</display-name></channel>\n";	
		}	
	
			
	#
	# CONDITION: OLD CHANNEL ID CAN BE FOUND IN NEW CHANNEL LIST
	#
			
	} elsif( defined $old_id and not defined $new_id and $selected_channel ne "DUMMY" ) {
		
		if( defined $new_id2name->{$old_id} ) {
		
			my $cname_new = $new_id2name->{$old_id};
			my $cname_old = $old_id2name->{$old_id};
			
			if( defined $cname_new and not defined $old_name2id->{$cname_new} ) {
						
				# CHANNEL ID (condition) (settings)
				if( $setup_cid eq $enabled ) {
					if( defined $rytec->{$cname_old} ) {
						print "<channel id=\"" . $rytec->{$cname_old} . "\">";
					} else {
						print "<channel id=\"" . $cname_old . "\">";
						print STDERR "[ CHLIST WARNING ] Rytec ID not matched for: " . $cname_old . "\n";
					}
				} else {
					print "<channel id=\"" . $cname_old . "\">";
				}
				
				# CHANNEL NAME + LOGO (language) (loop)
				my $old_logo = $old_name2logo->{$cname_old};
				if( defined $old_logo ) {
					print "<display-name lang=\"$languageVER\">" . $cname_old . "</display-name>";
					print "<icon src=\"$old_logo\" /></channel>\n";
				} else {
					print "<display-name lang=\"$languageVER\">" . $cname_old . "</display-name></channel>\n";	
				}	
			}
		}		
	}
}
