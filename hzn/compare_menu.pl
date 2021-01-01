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
# HORIZON CHANNEL LIST CREATOR #
# ##############################

# COMPARE STRINGS, CREATE MENU LIST

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
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
	
	# DEFINE IDs
	my $new_id = $new_name2id->{$configname};
	my $old_id = $old_name2id->{$configname};
			
	# FIND CHANNEL NAME IN NEW CHANNEL LIST
	if( defined $new_id ) {
		
		if( $new_id ne $old_id) {
			print STDERR "[ CHLIST WARNING ] CHANNEL \"$configname\" received new channel ID!\n";
		}
		
		print "$configname\n";
		
	# IF CHANNEL NAME WAS NOT FOUND IN NEW CHANNEL LIST: TRY TO FIND OLD ID IN NEW CHANNEL LIST
	} elsif( defined $old_id ) {
		
		if( defined $new_id2name->{$old_id} ) {
			my $renamed_channel = $new_id2name->{$old_id};
			
			if( defined $old_name2id->{$renamed_channel} ) {
				print STDERR "[ CHLIST WARNING ] Renamed CHANNEL \"$renamed_channel\" (formerly known as \"$configname\") already exists in original channel list!\n";
			} elsif( not defined $old_name2id->{$renamed_channel} ) {
				print STDERR "[ CHLIST WARNING ] CHANNEL \"$configname\" received new channel name \"$renamed_channel\"!\n";
			
				print "$renamed_channel\n";
			}
			
		# IF OLD ID WAS NOT FOUND IN NEW CHANNEL LIST
		} else {
			print STDERR "[ CHLIST WARNING ] CHANNEL \"$configname\" not found in new channel list!\n";
		}
	
	# IF CHANNEL WAS NOT FOUND IN ANY CHANNEL LIST
	} else {
		print STDERR "[ CHLIST WARNING ] CHANNEL \"$configname\" not found in channel list!\n";
	}
}
