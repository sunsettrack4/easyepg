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

# ###############################
# SWISSCOM CHANNEL LIST CREATOR #
# ###############################

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
use utf8;
 
use JSON;

# READ JSON INPUT FILE: MANIFEST
my $programme;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/workfile" or die;
    $programme = <$fh>;
    close $fh;
}


# CONVERT JSON TO PERL STRUCTURES
my $programmedata    = decode_json($programme);

#
# DEFINE JSON VALUES
#

# DEFINE PROGRAMME STRINGS
my @attributes = @{ $programmedata->{'attributes'} };

foreach my $attributes ( @attributes ) {
	my $channelnodes = $attributes->{'Nodes'};
	
	my @channelitems = @{ $channelnodes->{'Items'} };
	
	foreach my $channelitems ( @channelitems ) {
		my $channelcontents = $channelitems->{'Content'};
		my $broadcastnodes = $channelcontents->{'Nodes'};
		
		my @broadcastitems = @{ $broadcastnodes->{'Items'} };
		
		foreach my $broadcastitems ( @broadcastitems ) {
			my $crid = $broadcastitems->{'Identifier'};
			
			print $crid . "\n";
		}
	}
}
