#!/usr/bin/perl

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

# ##############################
# HORIZON JSON > XML CONVERTER #
# ##############################

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

# READ JSON INPUT FILE: HZN HARDCODED CHLIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "hzn_channels.json" or die;
    $chlist = <$fh>;
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

# CONVERT JSON TO PERL STRUCTURES
my $data   = decode_json($json);
my $chdata = decode_json($chlist);
my $initdata = decode_json($init);

print "\n<!-- CHANNEL LIST - SOURCE: HORIZON -->\n\n";

my @channels = @{ $data->{'channels'} };
foreach my $channels ( @channels ) {
	my @schedule = @{ $channels->{'stationSchedules'} };
	
	foreach my $schedule ( @schedule ) {
		my $item = $schedule->{'station'};
		
		# ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE CHANNEL ID + NAME
		my $cname   = $item->{'title'};
		$cname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
        
        # DEFINE COUNTRY VERSION
        my $countryVER =  $initdata->{'country'};
        
        # DEFINE LANGUAGE VERSION
        my $languageVER =  $initdata->{'language'};
        
        # DEFINE RYTEC CHANNEL ID (language)
		my $rytec = $chdata->{'channels'}{$countryVER};
        
        # ##################
		# PRINT XML OUTPUT #
		# ##################
        
		# CHANNEL ID (condition)
		if( defined $rytec->{$cname} ) {
			print "<channel id=\"" . $rytec->{$cname} . "\">\n";
		} else {
			print "<channel id=\"" . $cname . "\">\n";
			print STDERR "[ CHLIST WARNING ] Channel ID unknown: " . $cname . "\n";
		}
        
		# CHANNEL NAME (language)
		print "  <display-name lang=\"$languageVER\">" . $cname . "</display-name>\n</channel>\n";
	}
}
