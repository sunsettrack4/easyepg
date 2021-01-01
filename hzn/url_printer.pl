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
binmode STDERR, ":utf8";
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
my $time0   = Time::Piece->new;
my $time1   = $time0 - 3600;
my $time2   = $time1 + 86400;
my $time3   = $time1 + 172800;
my $time4   = $time1 + 259200;
my $time5   = $time1 + 345600;
my $time6   = $time1 + 432000;
my $time7   = $time1 + 518400;
my $time8   = $time1 + 604800;

my $date1   = $time1->strftime('%s') . "000";
my $date2   = $time2->strftime('%s') . "000";
my $date3   = $time3->strftime('%s') . "000";
my $date4   = $time4->strftime('%s') . "000";
my $date5   = $time5->strftime('%s') . "000";
my $date6   = $time6->strftime('%s') . "000";
my $date7   = $time7->strftime('%s') . "000";
my $date8   = $time8->strftime('%s') . "000";

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
	
	# DEFINE IDs
	my $new_id = $new_name2id->{$configname};
	my $old_id = $old_name2id->{$configname};
			
	# FIND CHANNEL NAME IN NEW CHANNEL LIST
	if( defined $new_id ) {
		
		if( $new_id ne $old_id) {
			print STDERR "[ CHLIST WARNING ] CHANNEL \"$configname\" received new channel ID!\n";
		}
			
		# DAY 1
		if( $day_setting == 1 ) {
			print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $new_id . "&byStartTime=" . $date1 . "~" . $date2 . "&sort=startTime&range=1-10000' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-2
		} elsif( $day_setting == 2 ) {
			print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $new_id . "&byStartTime=" . $date1 . "~" . $date3 . "&sort=startTime&range=1-10000' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-3
		} elsif( $day_setting == 3 ) {
			print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $new_id . "&byStartTime=" . $date1 . "~" . $date4 . "&sort=startTime&range=1-10000' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-4
		} elsif( $day_setting == 4 ) {
			print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $new_id . "&byStartTime=" . $date1 . "~" . $date5 . "&sort=startTime&range=1-10000' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-5
		} elsif( $day_setting == 5 ) {
			print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $new_id . "&byStartTime=" . $date1 . "~" . $date6 . "&sort=startTime&range=1-10000' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-6
		} elsif( $day_setting == 6 ) {
			print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $new_id . "&byStartTime=" . $date1 . "~" . $date7 . "&sort=startTime&range=1-10000' | grep \"$new_id\" > mani/$new_id\n";
		# DAYS 1-7
		} elsif( $day_setting == 7 ) {
			print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $new_id . "&byStartTime=" . $date1 . "~" . $date8 . "&sort=startTime&range=1-10000' | grep \"$new_id\" > mani/$new_id\n";
		}
		
	# IF CHANNEL NAME WAS NOT FOUND IN NEW CHANNEL LIST: TRY TO FIND OLD ID IN NEW CHANNEL LIST
	} elsif( defined $old_id ) {
		
		if( defined $new_id2name->{$old_id} ) {
			my $renamed_channel = $new_id2name->{$old_id};
			
			if( defined $old_name2id->{$renamed_channel} ) {
				print STDERR "[ CHLIST WARNING ] Renamed CHANNEL \"$renamed_channel\" (formerly known as \"$configname\") already exists in original channel list!\n";
			} elsif( not defined $old_name2id->{$renamed_channel} ) {
				print STDERR "[ CHLIST WARNING ] CHANNEL \"$configname\" received new channel name \"$renamed_channel\"!\n";
			
				my $renew_id = $new_name2id->{$renamed_channel};
				
				# DAY 1
				if( $day_setting == 1 ) {
					print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $renew_id . "&byStartTime=" . $date1 . "~" . $date2 . "&sort=startTime&range=1-10000' | grep \"$renew_id\" > mani/$renew_id\n";
				# DAYS 1-2
				} elsif( $day_setting == 2 ) {
					print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $renew_id . "&byStartTime=" . $date1 . "~" . $date3 . "&sort=startTime&range=1-10000' | grep \"$renew_id\" > mani/$renew_id\n";
				# DAYS 1-3
				} elsif( $day_setting == 3 ) {
					print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $renew_id . "&byStartTime=" . $date1 . "~" . $date4 . "&sort=startTime&range=1-10000' | grep \"$renew_id\" > mani/$renew_id\n";
				# DAYS 1-4
				} elsif( $day_setting == 4 ) {
					print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $renew_id . "&byStartTime=" . $date1 . "~" . $date5 . "&sort=startTime&range=1-10000' | grep \"$renew_id\" > mani/$renew_id\n";
				# DAYS 1-5
				} elsif( $day_setting == 5 ) {
					print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $renew_id . "&byStartTime=" . $date1 . "~" . $date6 . "&sort=startTime&range=1-10000' | grep \"$renew_id\" > mani/$renew_id\n";
				# DAYS 1-6
				} elsif( $day_setting == 6 ) {
					print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $renew_id . "&byStartTime=" . $date1 . "~" . $date7 . "&sort=startTime&range=1-10000' | grep \"$renew_id\" > mani/$renew_id\n";
				# DAYS 1-7
				} elsif( $day_setting == 7 ) {
					print "curl -s 'https://web-api-pepper.horizon.tv/oesp/v2/XX/YYY/web/listings?byStationId=" . $renew_id . "&byStartTime=" . $date1 . "~" . $date8 . "&sort=startTime&range=1-10000' | grep \"$renew_id\" > mani/$renew_id\n";
				}
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
