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
# ZATTOO CHANNEL LIST CREATOR  #
# ##############################

# COMPARE STRINGS, CREATE MENU LIST

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
use utf8;
 
use JSON;

# READ JSON INPUT FILE: COMPARISM LIST
my $json;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/compare.json" or die;
    $json = <$fh>;
    close $fh;
}

# CONVERT JSON TO PERL STRUCTURES
my $data      = decode_json($json);


#
# DEFINE JSON VALUES
#

my $new_name2id = $data->{'newname2id'};
my $new_id2name = $data->{'newid2name'};
my $old_name2id = $data->{'oldname2id'};
my $old_id2name = $data->{'oldid2name'};
my @configname  = @{ $data->{'config'} };


#
# COMPARE VALUES + CREATE MENU LIST
#

foreach my $configname ( @configname ) {
	
	my $old_id = $old_name2id->{$configname};
	
	# FIND MATCH - NEW CHANNEL NAME + CONFIG NAME
	if( defined $new_name2id->{$configname} ) {
		print "$configname\n";
		
	# IF MATCH NOT FOUND: FIND MATCH - OLD CHANNEL NAME + CONFIG NAME
	} elsif( defined $old_id ) {
		if( defined $new_id2name->{$old_id} ) {
			print $new_id2name->{$old_id} . "\n";
			print STDERR "[ INFO ] CHANNEL \"$configname\" received new Channel Name!\n";
		}
	} else {
		print STDERR "[ INFO ] CHANNEL $configname not found in channel lists!\n";
	}
}
