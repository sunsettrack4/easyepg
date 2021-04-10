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

# CREATE JSON FILE FOR COMPARISM

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
use utf8;
 
use JSON;

# READ JSON INPUT FILE: NEW CHLIST
my $chlist_new;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/chlist" or die;
    $chlist_new = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: OLD CHLIST
my $chlist_old;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "chlist_old" or die;
    $chlist_old = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: CHANNEL CONFIG
my $chlist_config;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "channels.json" or die;
    $chlist_config = <$fh>;
    close $fh;
}

# CONVERT JSON TO PERL STRUCTURES
my $newdata      = decode_json($chlist_new);
my $olddata      = decode_json($chlist_old);
my $configdata   = decode_json($chlist_config);


# ##################
# NEW CHANNEL LIST #
# ##################

# TOOL: NAME ==> ID

# CREATE REPORT FILE TO CHECK DUPLICATES 
open my $fh, ">", "/tmp/report.txt";
print $fh "{\"channels\":[]}";
close $fh;

print "{ \"newname2id\": {\n";

my @newchannels_name2id = @{ $newdata->{'channels'} };
foreach my $newchannels ( @newchannels_name2id ) {
	my @newschedule = @{ $newchannels->{'stationSchedules'} };
	
	foreach my $newschedule ( @newschedule ) {
		my $newitem = $newschedule->{'station'};
		
		#
		# DEFINE JSON VALUES
		#
        
		# DEFINE NEW CHANNEL NAME
		my $newcname   = $newitem->{'title'};
		$newcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		$newcname =~ s///g;		# REMOVE "SELECTED AREA"
		$newcname =~ s///g;
		$newcname =~ s/\ \ /\ /g;

		# DEFINE NEW CHANNEL ID
		my $newcid     = $newitem->{'id'};
		
		
		# ########################################
		# UPDATE REPORT FILE TO CHECK DUPLICATES #
		# ########################################
		
		do {
			open my $input_h, "<:encoding(UTF-8)", "/tmp/report.txt";
			open my $output_h, ">:encoding(UTF-8)", "/tmp/report_temp.txt";
			while(my $string = <$input_h>) {
				$string =~ s/]/"$newcname"]/g;
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
			if( $_ eq $newcname ) {
				if( $count{$_} == 1 ) {
					print "  \"" . $newcname . "\":\"" . $newcid. "\",\n";
				} elsif( $count{$_} == 2 ) {
					print "  \"" . $newcname . " (2)\":\"" . $newcid. "\",\n";
				} elsif( $count{$_} == 3 ) {
					print "  \"" . $newcname . " (3)\":\"" . $newcid. "\",\n";
				}
			}
		}
	}
}

# TOOL: ID ==> NAME

# CREATE REPORT FILE TO CHECK DUPLICATES (2)
open my $fh2, ">", "/tmp/report.txt";
print $fh2 "{\"channels\":[]}";
close $fh2;

print "\"DUMMY\": \"DUMMY\" },\n\"newid2name\": {\n";

my @newchannels_id2name = @{ $newdata->{'channels'} };
foreach my $newchannels ( @newchannels_id2name ) {
	my @newschedule = @{ $newchannels->{'stationSchedules'} };
	
	foreach my $newschedule ( @newschedule ) {
		my $newitem = $newschedule->{'station'};
		
		#
		# DEFINE JSON VALUES
		#
        
		# DEFINE NEW CHANNEL NAME
		my $newcname   = $newitem->{'title'};
		$newcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		$newcname =~ s///g;		# REMOVE "SELECTED AREA"
		$newcname =~ s///g;
		$newcname =~ s/\ \ /\ /g;
		
		# DEFINE NEW CHANNEL ID
		my $newcid     = $newitem->{'id'};
		
		
		# ########################################
		# UPDATE REPORT FILE TO CHECK DUPLICATES #
		# ########################################
		
		do {
			open my $input_h, "<:encoding(UTF-8)", "/tmp/report.txt";
			open my $output_h, ">:encoding(UTF-8)", "/tmp/report_temp.txt";
			while(my $string = <$input_h>) {
				$string =~ s/]/"$newcname"]/g;
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
			if( $_ eq $newcname ) {
				if( $count{$_} == 1 ) {
					print "  \"" . $newcid . "\":\"" . $newcname . "\",\n";
				} elsif( $count{$_} == 2 ) {
					print "  \"" . $newcid . "\":\"" . $newcname . " (2)\",\n";
				} elsif( $count{$_} == 3 ) {
					print "  \"" . $newcid . "\":\"" . $newcname . " (3)\",\n";
				}
			}
		}
	}
}

				
# ##################
# OLD CHANNEL LIST #
# ##################

# TOOL: NAME ==> ID

# CREATE REPORT FILE TO CHECK DUPLICATES (3)
open my $fh3, ">", "/tmp/report.txt";
print $fh3 "{\"channels\":[]}";
close $fh3;

print "\"DUMMY\": \"DUMMY\" },\n\"oldname2id\": {\n";
						
my @oldchannels_name2id = @{ $olddata->{'channels'} };
foreach my $oldchannels ( @oldchannels_name2id ) {
	my @oldschedule = @{ $oldchannels->{'stationSchedules'} };

	foreach my $oldschedule ( @oldschedule ) {
		my $olditem     = $oldschedule->{'station'};
						
		#
		# DEFINE JSON VALUES
		#
								
		# DEFINE OLD CHANNEL NAME
		my $oldcname   = $olditem->{'title'};
		$oldcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		$oldcname =~ s///g;		# REMOVE "SELECTED AREA"
		$oldcname =~ s///g;
		$oldcname =~ s/\ \ /\ /g;

		# DEFINE OLD CHANNEL ID
		my $oldcid     = $olditem->{'id'};
		
		
		# ########################################
		# UPDATE REPORT FILE TO CHECK DUPLICATES #
		# ########################################
		
		do {
			open my $input_h, "<:encoding(UTF-8)", "/tmp/report.txt";
			open my $output_h, ">:encoding(UTF-8)", "/tmp/report_temp.txt";
			while(my $string = <$input_h>) {
				$string =~ s/]/"$oldcname"]/g;
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
			if( $_ eq $oldcname ) {
				if( $count{$_} == 1 ) {
					print "  \"" . $oldcname . "\":\"" . $oldcid . "\",\n";
				} elsif( $count{$_} == 2 ) {
					print "  \"" . $oldcname . " (2)\":\"" . $oldcid . "\",\n";
				} elsif( $count{$_} == 3 ) {
					print "  \"" . $oldcname . " (3)\":\"" . $oldcid . "\",\n";
				}
			}
		}
	}
}

# TOOL: ID ==> NAME

# CREATE REPORT FILE TO CHECK DUPLICATES (4)
open my $fh4, ">", "/tmp/report.txt";
print $fh4 "{\"channels\":[]}";
close $fh4;

print "\"DUMMY\": \"DUMMY\" },\n\"oldid2name\": {\n";
						
my @oldchannels_id2name = @{ $olddata->{'channels'} };
foreach my $oldchannels ( @oldchannels_id2name ) {
	my @oldschedule = @{ $oldchannels->{'stationSchedules'} };

	foreach my $oldschedule ( @oldschedule ) {
		my $olditem     = $oldschedule->{'station'};
						
		#
		# DEFINE JSON VALUES
		#
								
		# DEFINE OLD CHANNEL NAME
		my $oldcname   = $olditem->{'title'};
		$oldcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		$oldcname =~ s///g;		# REMOVE "SELECTED AREA"
		$oldcname =~ s///g;
		$oldcname =~ s/\ \ /\ /g;

		# DEFINE OLD CHANNEL ID
		my $oldcid     = $olditem->{'id'};
		
		
		# ########################################
		# UPDATE REPORT FILE TO CHECK DUPLICATES #
		# ########################################
		
		do {
			open my $input_h, "<:encoding(UTF-8)", "/tmp/report.txt";
			open my $output_h, ">:encoding(UTF-8)", "/tmp/report_temp.txt";
			while(my $string = <$input_h>) {
				$string =~ s/]/"$oldcname"]/g;
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
			if( $_ eq $oldcname ) {
				if( $count{$_} == 1 ) {
					print "  \"" . $oldcid . "\":\"" . $oldcname . "\",\n";
				} elsif( $count{$_} == 2 ) {
					print "  \"" . $oldcid . "\":\"" . $oldcname . " (2)\",\n";
				} elsif( $count{$_} == 3 ) {
					print "  \"" . $oldcid . "\":\"" . $oldcname . " (3)\",\n";
				}
			}
		}
	}
}	


# ###############
# CHANNEL LOGOS #
# ###############

# TOOL: NEW NAME ==> LOGO

# CREATE REPORT FILE TO CHECK DUPLICATES (5)
open my $fh5, ">", "/tmp/report.txt";
print $fh5 "{\"channels\":[]}";
close $fh5;

print "\"DUMMY\": \"DUMMY\" },\n\"newname2logo\": {\n";

my @newchannels_name2logo = @{ $newdata->{'channels'} };
foreach my $newchannels ( @newchannels_name2logo ) {
	my @newschedule = @{ $newchannels->{'stationSchedules'} };
	
	foreach my $newschedule ( @newschedule ) {
		my $newitem = $newschedule->{'station'};
		
		
		#
		# DEFINE JSON VALUES
		#
        
		# DEFINE NEW CHANNEL NAME
		my $newcname   = $newitem->{'title'};
		$newcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		$newcname =~ s///g;		# REMOVE "SELECTED AREA"
		$newcname =~ s///g;
		$newcname =~ s/\ \ /\ /g;
		
		# DEFINE LOGO
		my @logo	= @{ $newitem->{'images'} };
		my $image_location;
		
		
		# ########################################
		# UPDATE REPORT FILE TO CHECK DUPLICATES #
		# ########################################
		
		do {
			open my $input_h, "<:encoding(UTF-8)", "/tmp/report.txt";
			open my $output_h, ">:encoding(UTF-8)", "/tmp/report_temp.txt";
			while(my $string = <$input_h>) {
				$string =~ s/]/"$newcname"]/g;
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
			if( $_ eq $newcname ) {
				if( $count{$_} == 1 ) {
					print "  \"" . $newcname . "\":\"";
				} elsif( $count{$_} == 2 ) {
					print "  \"" . $newcname . " (2)\":\"";
				} elsif( $count{$_} == 3 ) {
					print "  \"" . $newcname . " (3)\":\"";
				} elsif( $count{$_} == 4 ) {
					print "  \"" . $newcname . " (4)\":\"";
				}
			}
		}
		
		# CHANNEL NAME + LOGO (language) (loop)
		if( @logo ) {
			while( my( $image_id, $image ) = each( @logo ) ) {
				if( $image->{'assetType'} eq "station-logo-large" ) {
					$image_location = $image_id;
					last;
				}
			}
			if( defined $image_location ) {
				my $logo_def 	= $newitem->{'images'}[$image_location]{'url'};
				$logo_def		=~ s/\?w.*//g;
				print $logo_def . "\",\n";
			} else {
				print "\",\n";
			}	
		} else {
			print "\",\n";
		}     
	}
}


# TOOL: OLD NAME ==> LOGO

# CREATE REPORT FILE TO CHECK DUPLICATES (6)
open my $fh6, ">", "/tmp/report.txt";
print $fh6 "{\"channels\":[]}";
close $fh6;

print "\"DUMMY\": \"DUMMY\" },\n\"oldname2logo\": {\n";

my @oldchannels_name2logo = @{ $olddata->{'channels'} };
foreach my $oldchannels ( @oldchannels_name2logo ) {
	my @oldschedule = @{ $oldchannels->{'stationSchedules'} };
	
	foreach my $oldschedule ( @oldschedule ) {
		my $olditem = $oldschedule->{'station'};
		
		
		#
		# DEFINE JSON VALUES
		#
        
		# DEFINE NEW CHANNEL NAME
		my $oldcname   = $olditem->{'title'};
		$oldcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		$oldcname =~ s///g;		# REMOVE "SELECTED AREA"
		$oldcname =~ s///g;
		$oldcname =~ s/\ \ /\ /g;
		
		# DEFINE LOGO
		my @logo	= @{ $olditem->{'images'} };
		my $image_location;
		
		
		# ########################################
		# UPDATE REPORT FILE TO CHECK DUPLICATES #
		# ########################################
		
		do {
			open my $input_h, "<:encoding(UTF-8)", "/tmp/report.txt";
			open my $output_h, ">:encoding(UTF-8)", "/tmp/report_temp.txt";
			while(my $string = <$input_h>) {
				$string =~ s/]/"$oldcname"]/g;
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
			if( $_ eq $oldcname ) {
				if( $count{$_} == 1 ) {
					print "  \"" . $oldcname . "\":\"";
				} elsif( $count{$_} == 2 ) {
					print "  \"" . $oldcname . " (2)\":\"";
				} elsif( $count{$_} == 3 ) {
					print "  \"" . $oldcname . " (3)\":\"";
				} elsif( $count{$_} == 4 ) {
					print "  \"" . $oldcname . " (4)\":\"";
				}
			}
		}
		
		# CHANNEL NAME + LOGO (language) (loop)
		if( @logo ) {
			while( my( $image_id, $image ) = each( @logo ) ) {
				if( $image->{'assetType'} eq "station-logo-large" ) {
					$image_location = $image_id;
					last;
				}
			}
			if( defined $image_location ) {
				my $logo_def 	= $olditem->{'images'}[$image_location]{'url'};
				$logo_def		=~ s/\?w.*//g;
				print $logo_def . "\",\n";
			} else {
				print "\",\n";
			}	
		} else {
			print "\",\n";
		}
	}
}
							
# #######################
# CHANNEL CONFIGURATION #
# #######################

print "\"DUMMY\": \"DUMMY\" },\n\"config\": [\n";	
												
my @configdata = @{ $configdata->{'channels'} };
		
foreach my $configname ( @configdata ) {
	print "\"$configname\",\n";
}

print "\"DUMMY\"]\n}";
