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
# HORIZON JSON > XML CONVERTER #
# ##############################

# EPG

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
use utf8;
 
use JSON;
use Data::Dumper;
use Time::Piece;
 
# READ JSON INPUT FILE: EPG WORKFILE
my $json;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "workfile" or die;
    $json = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: HZN HARDCODED CHLIST
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "hzn_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: HZN HARDCODED CHLIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "hzn_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ INIT FILE
my $init;
{
	local $/; #Enable 'slurp' mode
    open my $fh, '<', "init.json" or die;
    $init = <$fh>;
    close $fh;
}
 
# CONVERT JSON TO PERL STRUCTURES
my $data     = decode_json($json);
my $chdata   = decode_json($chlist);
my $chiddata = decode_json($chidlist);
my $initdata = decode_json($init);

print "\n<!-- EPG DATA - SOURCE: HORIZON -->\n\n";
 
foreach my $attributes ( $data->{attributes} ) {
    
    foreach my $item ( @$attributes ) {
        
        # ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE TIMES AND CHANNEL ID
        my $start = $item->{'startTime'};
        my $end   = $item->{'endTime'};
        my $cid   = $item->{'stationId'};
        
        # CONVERT FROM MICROSOFT TIMESTAMP TO XMLTV DATE FORMAT
		my $startTIME = localtime($start/1000)->strftime('%Y%m%d%H%M%S') . ' +0000';
		my $endTIME   = localtime($end/1000)->strftime('%Y%m%d%H%M%S') . ' +0000';
		
		# DEFINE PROGRAM STRINGS
		my $program  = $item->{program};
		my $image    = $program->{'images'}[0]{'url'};
		my $title    = $program->{'title'};
		my $subtitle = $program->{'secondaryTitle'}; 
		my $desc     = $program->{'longDescription'};
		my @cast     = @{ $program->{'cast'} };
		my @director = @{ $program->{'directors'} };
		my $date     = $program->{'year'};
		my $genre1   = $program->{'categories'}[0]{'title'};
		my $genre2   = $program->{'categories'}[1]{'title'};
		my $genre3   = $program->{'categories'}[2]{'title'};
		my $age      = $program->{'parentalRating'};
		my $series   = $program->{'seriesNumber'};
		my $episode  = $program->{'seriesEpisodeNumber'};
		my $star     = $program->{'longDescription'};
		
		# DEFINE COUNTRY VERSION
        my $countryVER =  $initdata->{'country'};
        
        # DEFINE LANGUAGE VERSION
        my $languageVER =  $initdata->{'language'};
        
        # DEFINE RYTEC CHANNEL ID (language)
		my $rytec = $chdata->{'channels'}{$countryVER};
        
        # DEFINE CHANNEL ID
        my $cidEXT = $chiddata->{'cid'};
		
		# ##################
		# PRINT XML OUTPUT #
		# ##################
		
		# BEGIN OF PROGRAMME: START / STOP / CHANNEL (condition)
		if( defined $cidEXT->{$cid} ) {
			if( defined $rytec->{$cidEXT->{$cid}} ) {
				print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $rytec->{$cidEXT->{$cid}} . "\">\n";
			} else {
				print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $cidEXT->{$cid} . "\">\n";
				print STDERR "EPG WARNING: Rytec ID not matched for: " . $cidEXT->{$cid} . "\n";
			}
		} else {
			print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"$cid\">\n";
			print STDERR "EPG WARNING: Channel ID unknown: " . $cid . "\n";
		}
		
		# IMAGE (condition)
		if( defined $image) {
			$image =~ s/\?.*//g;
			print "  <icon src=\"$image\" />\n";
		}
		
		# TITLE (language)
		$title =~ s/\&/\&amp;/g;
		print "  <title lang=\"$languageVER\">$title</title>\n";
		
		# SUBTITLE (condition) (language)
		if( defined $subtitle ) {
			$subtitle =~ s/\&/\&amp;/g;
			print "  <sub-title lang=\"$languageVER\">$title</sub-title>\n";
		}
		
		# DESCRIPTION (condition) (language)
		if( defined $desc ) {
			$desc =~ s/\&/\&amp;/g;				# REQUIRED TO READ XML FILE CORRECTLY
			$desc =~ s/ IMDb Rating:.*\/10.//g;	# REMOVE IMDB STRING FROM DESCRIPTION
			print "  <desc lang=\"$languageVER\">$desc</desc>\n";
		}
		
		# CREDITS (condition)
		if ( @director ) {
			print "  <credits>\n";
			foreach my $PRINTdirector ( @director ) {
				print "    <director>" . $PRINTdirector . "</director>\n";
			}
			if ( @cast ) {
				foreach my $PRINTcast ( @cast ) {
					print "    <actor>" . $PRINTcast . "</actor>\n";
				}
			}
			print "  </credits>\n";
		} elsif ( @cast ) {
			print "  <credits>\n";
			foreach my $PRINTcast ( @cast ) {
				print "    <actor>" . $PRINTcast . "</actor>\n";
			}
			print "  </credits>\n";
		}
		
		# DATE (condition)
		if( defined $date ) {
			print "  <date>$date</date>\n";
		}
		
		# CATEGORIES (USE MOST DETAILLED CATEGORY) (condition) (language)
		# if( defined $genre2 ) {
		# 	print "  <category lang=\"$languageVER\">$genre2</category>\n";
		# } elsif( defined $genre1 ) {
		#	print "  <category lang=\"$languageVER\">$genre1</category>\n";
		# }
		
		# CATEGORIES (PRINT ALL CATEGORIES) (condition) (language)
		if ( defined $genre1) {
			print "  <category lang=\"$languageVER\">$genre1</category>\n";
		}
		if ( defined $genre2) {
			print "  <category lang=\"$languageVER\">$genre2</category>\n";
		}
		if ( defined $genre3) {
			print "  <category lang=\"$languageVER\">$genre3</category>\n";
		}
		
		# SEASON/EPISODE (XMLTV_NS) (condition)
		if( defined $series ) {
			if( $series  =~ m/\d{4}/) {
				undef $series;				# REMOVE USELESS SERIES STRINGS
			}
		}
		if( defined $episode ) {
			if( $episode =~ m/\d{7}/) {
				undef $episode;				# REMOVE USELESS EPISODE STRINGS
			}
		}
		if( defined $series ) {
			my $XMLseries  = $series - 1;
			if( defined $episode ) {
				my $XMLepisode = $episode - 1;
				print "  <episode-num system=\"xmltv_ns\">$XMLseries . $XMLepisode . </episode-num>\n";
			} else {
				print "  <episode-num system=\"xmltv_ns\">$XMLseries . 0 . </episode-num>\n";
			}
		} elsif( defined $episode ) {
			my $XMLepisode = $episode - 1;
			print "  <episode-num system=\"xmltv_ns\">0 . $XMLepisode . </episode-num>\n";
		}
		
		# SEASON/EPISODE (ONSCREEN) (condition)
		# if( defined $series ) {
		#	if( $series  =~ m/\d{4}/) {
		#		undef $series;				# REMOVE USELESS SERIES STRINGS
		#	}
		# }
		# if( defined $episode ) {
		#	if( $episode =~ m/\d{7}/) {
		#		undef $episode;				# REMOVE USELESS EPISODE STRINGS
		#	}
		# }
		# if( defined $series ) {
		#	if( defined $episode ) {
		#		print "  <episode-num system=\"onscreen\">S$series E$episode</episode-num>\n";
		#	} else {
		#		print "  <episode-num system=\"onscreen\">S$series</episode-num>\n";
		#	}
		# } elsif( defined $episode ) {
		#	print "  <episode-num system=\"onscreen\">E$episode</episode-num>\n";
		# }
		
		# AGE RATING (condition)
		if( defined $age) {
			print "  <rating>\n    <value>$age</value>\n  </rating>\n";
		}
		
		# STAR RATING (condition)
		if( defined $star) {
			if ($star =~ m/IMDb Rating:/) {
				$star =~ s/(.*)(IMDb Rating: )(.*)\/10.(.*)/$3\/10/g;
				$star =~ s/(.*) \/10/$1\/10/g;
				print "  <star-rating system=\"IMDb\">\n    <value>" . $star ."</value>\n  </star-rating>\n";
			} else { 
			    if ($star =~ m/IMDb rating:/) {
				$star =~ s/(.*)(IMDb rating: )(.*)\/10.(.*)/$3\/10/g;
				$star =~ s/(.*) \/10/$1\/10/g;
				print "  <star-rating system=\"IMDb\">\n    <value>" . $star ."</value>\n  </star-rating>\n";
				}       
			}
		}
		
		# END OF PROGRAMME
		print "</programme>\n";
    }
}
