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
# TVSPIELFILM CHANNEL ID CREATOR   #
# ##################################

# CHANNEL IDs

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
use utf8;
 
use JSON;

# READ JSON INPUT FILE: CHLIST
my $json;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/chlist" or die;
    $json = <$fh>;
    close $fh;
}

# CONVERT JSON TO PERL STRUCTURES
my $data   = decode_json($json);

print "{ \"cid\":\n  {\n";

my @items = @{ $data->{'items'} };
foreach my $items ( @items ) {
		
	# ####################
    # DEFINE JSON VALUES #
    # ####################
        
    # DEFINE CHANNEL NAME
	my $cname   = $items->{'name'};
	$cname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		
	# DEFINE CHANNEL ID
	my $cid     = $items->{'id'};

    # ###################
	# PRINT JSON OUTPUT #
	# ###################
        
	# CHANNEL ID (condition)
	print "  \"$cid\":\"$cname\",\n";
}

print "  \"000000000000\":\"DUMMY\"\n  }\n}";
