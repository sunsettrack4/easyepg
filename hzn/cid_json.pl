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
# HORIZON CHANNEL ID CREATOR   #
# ##############################

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

# CREATE REPORT FILE TO CHECK DUPLICATES
open my $fh, ">", "/tmp/report.txt";
print $fh "{\"channels\":[]}";
close $fh;

print "{ \"cid\":\n  {\n";

my @channels = @{ $data->{'channels'} };
foreach my $channels ( @channels ) {
	my @schedule = @{ $channels->{'stationSchedules'} };
	
	foreach my $schedule ( @schedule ) {
		my $item = $schedule->{'station'};
		
		# ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE CHANNEL NAME
		my $cname   = $item->{'title'};
		$cname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		$cname =~ s///g;		 # REMOVE "SELECTED AREA"
		$cname =~ s///g;
		$cname =~ s/\ \ /\ /g;
		
		# DEFINE CHANNEL ID
		my $cid     = $item->{'id'};
		
		# ########################################
		# UPDATE REPORT FILE TO CHECK DUPLICATES #
		# ########################################
		
		do {
			open my $input_h, "<:encoding(UTF-8)", "/tmp/report.txt";
			open my $output_h, ">:encoding(UTF-8)", "/tmp/report_temp.txt";
			while(my $string = <$input_h>) {
				$string =~ s/]/"$cname"]/g;
				$string =~ s/""/","/g;
				print $output_h "$string";
			}
		};

		unlink "/tmp/report.txt" while -f "/tmp/report.txt";
		rename "/tmp/report_temp.txt" => "/tmp/report.txt";
		
		my $report;
		{
			local $/; #Enable 'slurp' mode
			open my $fh, "<", "/tmp/report.txt";
			$report = <$fh>;
			close $fh;
		}
		
		my $reportdata = decode_json($report);
		
		my @report = @{ $reportdata->{'channels'} };
		
		my %count;		
		$count{$_}++ for (sort @report);
		
		
		# ###################
		# PRINT JSON OUTPUT #
		# ###################
				
		for( keys %count) {
			if( $_ eq $cname ) {
				if( $count{$_} == 1 ) {
					print "  \"" . $cid . "\":\"" . $cname . "\",\n";
				} elsif( $count{$_} == 2 ) {
					print "  \"" . $cid . "\":\"" . $cname . " (2)\",\n";
				} elsif( $count{$_} == 3 ) {
					print "  \"" . $cid . "\":\"" . $cname . " (3)\",\n";
				}
			}
		}
	}
}

print "  \"000000000000\":\"DUMMY\"\n  }\n}";
