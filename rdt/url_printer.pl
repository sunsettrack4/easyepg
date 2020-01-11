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
# HORIZON MANIFEST URL PRINTER #
# ##############################

use strict;
use warnings;

binmode STDOUT, ":utf8";
use utf8;

use JSON;
use Time::Piece;
use Time::Seconds;

# READ CHANNEL FILE
my $channels;
{
	local $/; #Enable 'slurp' mode
	open my $fh, '<', "/tmp/compare.json" or die;
	$channels = <$fh>;
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
my $channels_data  = decode_json($channels);
my $settings_data  = decode_json($settings);

# SET DAY SETTING
my $day_setting  = $settings_data->{'settings'}{'day'};

# SET DATE VALUES
my $time1   = Time::Piece->new;

my $date1   = $time1->strftime('%d-%m-%Y');

# DEFINE COMPARE DATA
my $new_name2id = $channels_data->{'newname2id'};
my $new_id2name = $channels_data->{'newid2name'};
my $old_name2id = $channels_data->{'oldname2id'};
my $old_id2name = $channels_data->{'oldid2name'};
my @configname  = @{ $channels_data->{'config'} };


#
# DOWNLOAD CHANNEL MANIFESTS
#

foreach my $configname ( @configname ) {
	
	# XXFINE IDs
	my $new_id = $new_name2id->{$configname};
			
	# IF MATCH NOT FOUND: FIND CHANNEL NAME IN NEW CHANNEL LIST
	if( defined $new_id ) {
			
		# DAY 1
		if( $day_setting == 1 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=24&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-2
		} elsif( $day_setting == 2 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=48&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-3
		} elsif( $day_setting == 3 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=72&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-4
		} elsif( $day_setting == 4 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=96&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-5
		} elsif( $day_setting == 5 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=120&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-6
		} elsif( $day_setting == 6 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=144&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-7
		} elsif( $day_setting == 7 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=168&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-8
		} elsif( $day_setting == 8 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=192&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-9
		} elsif( $day_setting == 9 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=216&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-10
		} elsif( $day_setting == 10 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=240&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-11
		} elsif( $day_setting == 11 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=264&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-12
		} elsif( $day_setting == 12 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=288&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-13
		} elsif( $day_setting == 13 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=312&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-14
		} elsif( $day_setting == 7 ) {
			print "curl -s 'https://immediate-prod.apigee.net/broadcast/v1/schedule?startdate=" . $date1 . "&hours=336&totalwidthunits=898&channels=" . $new_id . "' | grep \"$new_id\" > mani/$new_id\n";
		}
	
	} else {
		print STDERR "[ CHLIST WARNING ] CHANNEL \"$configname\" not found in channel list!\n";
	}
}
