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

# #################################
# RADIOTIMES CHANNEL LIST CREATOR #
# #################################

# CREATE JSON FILE FOR COMPARISM

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
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

print "{ \"newname2id\": {\n";

my @newchannels_name2id_main = @{ $newdata->{'MainChannels'} };
foreach my $mainchannels_new ( @newchannels_name2id_main ) {
		
	#
	# MAIN: DEFINE JSON VALUES
	#
        
	# DEFINE NEW CHANNEL NAME
	my $newcname   = $mainchannels_new->{'Name'};
	$newcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		
	# DEFINE NEW CHANNEL ID
	my $newcid     = $mainchannels_new->{'Id'};
	
	# DEFINE REGION
	my $newregion  = $mainchannels_new->{'Region'};
	$newregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		
	# PRINT NEW CHANNEL NAMES
	if( $newregion ne "" ) {
		print "\"$newcname ($newregion)\": \"$newcid\",\n";
	} else {
		print "\"$newcname\": \"$newcid\",\n";
	}
}

my @newchannels_name2id_sub = @{ $newdata->{'OtherChannels'} };
foreach my $subchannels_new ( @newchannels_name2id_sub ) {
		
	#
	# SUB: DEFINE JSON VALUES
	#
        
	# DEFINE NEW CHANNEL NAME
	my $newcname   = $subchannels_new->{'Name'};
	$newcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		
	# DEFINE NEW CHANNEL ID
	my $newcid     = $subchannels_new->{'Id'};
	
	# DEFINE REGION
	my $newregion  = $subchannels_new->{'Region'};
	$newregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		
	# PRINT NEW CHANNEL NAMES
	if( $newregion ne "" ) {
		print "\"$newcname ($newregion)\": \"$newcid\",\n";
	} else {
		print "\"$newcname\": \"$newcid\",\n";
	}
}

# TOOL: ID ==> NAME

print "\"DUMMY\": \"DUMMY\" },\n\"newid2name\": {\n";

my @newchannels_id2name_main = @{ $newdata->{'MainChannels'} };
foreach my $mainchannels_new ( @newchannels_id2name_main ) {
		
	#
	# MAIN: DEFINE JSON VALUES
	#
        
	# DEFINE NEW CHANNEL NAME
	my $newcname   = $mainchannels_new->{'Name'};
	$newcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
	
	# DEFINE NEW CHANNEL ID
	my $newcid     = $mainchannels_new->{'Id'};
	
	# DEFINE NEW CHANNEL ID
	my $newregion  = $mainchannels_new->{'Region'};
	$newregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
	
	# PRINT NEW CHANNEL NAMES
	if( $newregion ne "" ) {
		print "\"$newcid\": \"$newcname ($newregion)\",\n";
	} else {
		print "\"$newcid\": \"$newcname\",\n";
	}
}

my @newchannels_id2name_sub = @{ $newdata->{'OtherChannels'} };
foreach my $subchannels_new ( @newchannels_id2name_sub ) {
		
	#
	# SUB: DEFINE JSON VALUES
	#
        
	# DEFINE NEW CHANNEL NAME
	my $newcname   = $subchannels_new->{'Name'};
	$newcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
	
	# DEFINE NEW CHANNEL ID
	my $newcid     = $subchannels_new->{'Id'};
	
	# DEFINE NEW CHANNEL ID
	my $newregion  = $subchannels_new->{'Region'};
	$newregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
	
	# PRINT NEW CHANNEL NAMES
	if( $newregion ne "" ) {
		print "\"$newcid\": \"$newcname ($newregion)\",\n";
	} else {
		print "\"$newcid\": \"$newcname\",\n";
	}
}
				
# ##################
# OLD CHANNEL LIST #
# ##################

# TOOL: NAME ==> ID

print "\"DUMMY\": \"DUMMY\" },\n\"oldname2id\": {\n";
						
my @oldchannels_name2id_main = @{ $olddata->{'MainChannels'} };
foreach my $mainchannels_old ( @oldchannels_name2id_main ) {
						
	#
	# MAIN: DEFINE JSON VALUES
	#
								
	# DEFINE OLD CHANNEL NAME
	my $oldcname   = $mainchannels_old->{'Name'};
	$oldcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		
	# DEFINE OLD CHANNEL ID
	my $oldcid     = $mainchannels_old->{'Id'};
	
	# DEFINE REGION
	my $oldregion  = $mainchannels_old->{'Region'};
	$oldregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
							
	# PRINT OLD CHANNEL NAMES
	if( $oldregion ne "" ) {
		print "\"$oldcname ($oldregion)\": \"$oldcid\",\n";
	} else {
		print "\"$oldcname\": \"$oldcid\",\n";
	}
}

my @oldchannels_name2id_sub = @{ $olddata->{'OtherChannels'} };
foreach my $subchannels_old ( @oldchannels_name2id_sub ) {
						
	#
	# SUB: DEFINE JSON VALUES
	#
								
	# DEFINE OLD CHANNEL NAME
	my $oldcname   = $subchannels_old->{'Name'};
	$oldcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
		
	# DEFINE OLD CHANNEL ID
	my $oldcid     = $subchannels_old->{'Id'};
	
	# DEFINE REGION
	my $oldregion  = $subchannels_old->{'Region'};
	$oldregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
							
	# PRINT OLD CHANNEL NAMES
	if( $oldregion ne "" ) {
		print "\"$oldcname ($oldregion)\": \"$oldcid\",\n";
	} else {
		print "\"$oldcname\": \"$oldcid\",\n";
	}
}

# TOOL: ID ==> NAME

print "\"DUMMY\": \"DUMMY\" },\n\"oldid2name\": {\n";
						
my @oldchannels_id2name_main = @{ $olddata->{'MainChannels'} };
foreach my $mainchannels_old ( @oldchannels_id2name_main ) {

	#
	# MAIN: DEFINE JSON VALUES
	#
								
	# DEFINE OLD CHANNEL NAME
	my $oldcname   = $mainchannels_old->{'Name'};
	$oldcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
	
	# DEFINE OLD CHANNEL ID
	my $oldcid     = $mainchannels_old->{'Id'};
	
	# DEFINE OLD REGION
	my $oldregion  = $mainchannels_old->{'Region'};
	$oldregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
						
	# PRINT OLD CHANNEL NAMES
	if( $oldregion ne "" ) {
		print "\"$oldcid\": \"$oldcname ($oldregion)\",\n";
	} else {
		print "\"$oldcid\": \"$oldcname\",\n";
	}
}

my @oldchannels_id2name_sub = @{ $olddata->{'OtherChannels'} };
foreach my $subchannels_old ( @oldchannels_id2name_sub ) {

	#
	# SUB: DEFINE JSON VALUES
	#
								
	# DEFINE OLD CHANNEL NAME
	my $oldcname   = $subchannels_old->{'Name'};
	$oldcname =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
	
	# DEFINE OLD CHANNEL ID
	my $oldcid     = $subchannels_old->{'Id'};
	
	# DEFINE OLD REGION
	my $oldregion  = $subchannels_old->{'Region'};
	$oldregion =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
						
	# PRINT OLD CHANNEL NAMES
	if( $oldregion ne "" ) {
		print "\"$oldcid\": \"$oldcname ($oldregion)\",\n";
	} else {
		print "\"$oldcid\": \"$oldcname\",\n";
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
