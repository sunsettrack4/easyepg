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
# TVTV CHANNEL LIST CREATOR #
# ###############################

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
use utf8;
 
use JSON;

# READ JSON INPUT FILE: MANIFEST
my $manifests;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/epg_workfile" or die;
    $manifests = <$fh>;
    close $fh;
}

# CONVERT JSON TO PERL STRUCTURES
my $manifestsdata    = decode_json($manifests);

#
# DEFINE JSON VALUES
#
my @attributes = @{ $manifestsdata->{'attributes'} };

# DEFINE manifests STRINGS
foreach my $attributes ( @attributes ) {
    
    my @listings = @{ $attributes->{'listings'} };
    foreach my $listings ( @listings ) {
		
		# ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE TIMES AND CHANNEL ID
        my $showID    = $listings->{'showID'};
		
		print $showID. "\n";
	}
}	