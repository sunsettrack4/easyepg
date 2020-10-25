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

# ###################################
# TV-SPIELFILM JSON > XML CONVERTER #
# ###################################

# EPG

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
use utf8;
 
use JSON;
use LWP::Simple;
use HTML::TreeBuilder;
use Data::Dumper;
use Time::Piece;
use DateTime;
use DateTime::Format::DateParse;
 
# READ JSON INPUT FILE: EPG WORKFILE
my $json;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/epg_workfile" or die;
    $json = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: MAGENTA NUMERIC CHANNEL IDs
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tvs_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tvs_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tvs_genres.json" or die;
    $genrelist = <$fh>;
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

# READ SETTINGS FILE
my $settings;
{
	local $/; #Enable 'slurp' mode
    open my $fh, '<', "settings.json" or die;
    $settings = <$fh>;
    close $fh;
}
 
# CONVERT JSON TO PERL STRUCTURES
my $data      = decode_json($json);
my $chdata    = decode_json($chlist);
my $chiddata  = decode_json($chidlist);
my $genredata = decode_json($genrelist);
my $initdata  = decode_json($init);
my $setupdata = decode_json($settings);

# DEFINE COUNTRY VERSION
my $countryVER =  $initdata->{'country'};
        
# DEFINE LANGUAGE VERSION
my $languageVER =  $initdata->{'language'};

print "\n<!-- EPG DATA - SOURCE: TV SPIELFILM $countryVER -->\n\n";

my @attributes = @{ $data->{'attributes'} };
foreach my $attributes ( @attributes ) {
    
    my @broadcast = @{ $attributes->{'Broadcastitems'} };
    foreach my $broadcast ( @broadcast ) {
		
		# ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE TIMES AND CHANNEL ID
        my $start = $broadcast->{'timestart'};
        my $end   = $broadcast->{'timeend'};
        my $cid   = $broadcast->{'broadcasterId'};
		$cid =~ s/\&/\&amp;/g;

		$start = localtime($start)->strftime('%F %T');
		$end = localtime($end)->strftime('%F %T');

		# DEFINE START TIME
		$start    =~ s/Z//g;
		$start    =~ s/ /T/g;
		my $startGER  = DateTime::Format::DateParse->parse_datetime($start, 'Europe/Berlin');
		$startGER->set_time_zone('UTC');
		my $s_YMD = $startGER->ymd;
		$s_YMD    =~ s/-//g;
		my $s_HMS = $startGER->hms;
		$s_HMS    =~ s/://g;
		my $startUTC = $s_YMD . $s_HMS;
		
		# DEFINE END TIME
		$end      =~ s/Z//g;
		$end      =~ s/ /T/g;
		my $endGER = DateTime::Format::DateParse->parse_datetime($end, 'Europe/Berlin');
		$endGER->set_time_zone('UTC');
		my $e_YMD = $endGER->ymd;
		$e_YMD    =~ s/-//g;
		my $e_HMS = $endGER->hms;
		$e_HMS    =~ s/://g;
		my $endUTC = $e_YMD . $e_HMS;
		
		# CONVERT TO XMLTV DATE FORMAT
		my $startTIME = $startUTC . ' +0000';
		my $endTIME   = $endUTC . ' +0000';

		# DEFINE PROGRAM STRINGS
		my $title     = $broadcast->{'title'};
		my $subtitle  = $broadcast->{'episodeTitle'}; 
		my $director  = $broadcast->{'director'};
		my $desc      = $broadcast->{'text'};
		my $date      = $broadcast->{'year'};
		my $country   = $broadcast->{'country'};
		my $genre     = $broadcast->{'genre'};
		my $age       = $broadcast->{'fsk'};
		my $series    = $broadcast->{'seasonNumber'};
		my $episode   = $broadcast->{'episodeNumber'};
		
		# DEFINE RYTEC CHANNEL ID (language)
		my $rytec = $chdata->{'channels'}{$countryVER};
        
        # DEFINE CHANNEL ID
        my $cidEXT = $chiddata->{'cid'};
        
        # DEFINE EIT GENRES (language)
        my $eit = $genredata->{'categories'}{$countryVER};
        
        # DEFINE SETTINGS
        my $setup_general  = $setupdata->{'settings'};
        my $setup_cid      = $setup_general->{'cid'};
        my $setup_genre    = $setup_general->{'genre'};
        my $setup_category = $setup_general->{'category'};
        my $setup_episode  = $setup_general->{'episode'};  
        
        # DEFINE SETTINGS VALUES
        my $enabled  = "enabled";
        my $disabled = "disabled";
        my $xmltv_ns = "xmltv_ns";
        my $onscreen = "onscreen";
        
        # PRE-DEFINE IMAGE LOCATION
        my $img_loc;
        
        
        # ##################
		# PRINT XML OUTPUT #
		# ##################
		
		# PRINT PROGRAMME STRING ONLY IF CERTAIN VALUES ARE DEFINED
		if( defined $title and defined $start and defined $end and defined $cid ) {
		
			# BEGIN OF PROGRAMME: START / STOP / CHANNEL (condition) (settings)
			if( defined $cidEXT->{$cid} ) {
				if( $setup_cid eq $enabled ) {
					if( defined $rytec->{$cidEXT->{$cid}} ) {
						print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $rytec->{$cidEXT->{$cid}} . "\">\n";
					} else {
						print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $cidEXT->{$cid} . "\">\n";
						print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXT->{$cid} . "\n";
					}
				} else {
					print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $cidEXT->{$cid} . "\">\n";
				}
			} else {
				print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"$cid\">\n";
				print STDERR "[ EPG WARNING ] Channel ID unknown: " . $cid . "\n";
			}
			
			# IMAGE (condition)
			if( defined $broadcast->{'images'}[0]{'size4'} ) {
				print "  <icon src=\"" . $broadcast->{'images'}[0]{'size4'} . "\" />\n";
			}
			
			# TITLE (language)
			$title =~ s/\&/\&amp;/g;
                        $title =~ s/<3/love/g;
                        $title =~ s/<[^>]*>//g;
			print "  <title lang=\"" . $languageVER . "\">" . $title . "</title>\n";
			
			# SUBTITLE (condition) (language)
			if( defined $subtitle ) {
				$subtitle =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY	
				$subtitle =~ s/<[^>]*>//g;  # REMOVE XML STRINGS WITHIN JSON VALUE
				print "  <sub-title lang=\"$languageVER\">$subtitle</sub-title>\n";
			}
			
			# DESCRIPTION (condition) (language)
			if( defined $desc ) {
				$desc =~ s/<[^>]*>//g;					# REMOVE XML STRINGS WITHIN JSON VALUE
				$desc =~ s/\&/\&amp;/g;					# REQUIRED TO READ XML FILE CORRECTLY				
				print "  <desc lang=\"$languageVER\">$desc</desc>\n";
			}
			
 			#CREDITS (condition)
			if( defined $director ) {
				$director =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY	
				$director =~ s/[<>]//g;
				print "  <credits>\n";
				print "    <director>" . $director . "</director>\n";
					if( exists $broadcast->{'actors'} ) {
						my @actors      = @{ $broadcast->{'actors'} };
						if ( @actors ) {
							foreach my $actors ( @actors ) {
								for my $role ( keys %$actors ) {
									my $PRINTcast = $actors->{$role};
									$PRINTcast =~ s/\&/\&amp;/g;
									$PRINTcast =~ s/[<>]//g;
									print "    <actor>" . $PRINTcast . "</actor>\n";
									}
								}
						}
					}
			print "  </credits>\n";
			}
			
			# DATE (condition)
			if( defined $date ) {
				print "  <date>$date</date>\n";
			}
			
			# COUNTRY (condition)
			if( defined $country ) {
				print "  <country>" . uc($country) . "</country>\n";
			}
			
			# CATEGORIES (USE ONE CATEGORY ONLY) (condition) (language) (settings)
			if ( defined $genre ) {
				$genre =~ s/\&/\&amp;/g;
				if ( $setup_genre eq $enabled ) {
					if ( defined $eit->{ $genre } ) {
						print "  <category lang=\"$languageVER\">" . $eit->{ $genre } . "</category>\n";
					} else {
						print "  <category lang=\"$languageVER\">$genre</category>\n";
						print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST " . "$genre" . "\n";;
					}
				}elsif ( $setup_genre eq $disabled ) {
					print "  <category lang=\"$languageVER\">$genre</category>\n";
				}
			}


			# SEASON/EPISODE REQUIED TO READ XML CORRECTLY
			if( defined $series ) {
				$series =~ s/^[ \t]*//g;
				$series =~ s/\/.*//g;
				$series =~ s/\(.*//g;
				$series =~ s/a.*//g;
				$series =~ s/b.*//g;
				$series =~ s/\+.*//g;
				$series =~ s/\;.*//g;
				$series =~ s/\!.*//g;
				$series =~ s/\-.*//g;
				$series =~ s/,.*//g;
				$series =~ s/[^0-9#\.\-_]//g;
				if ( $series eq '') {
					undef $series;
				}	
			}
			if( defined $episode ) {
				$episode =~ s/^[ \t]*//g;
				$episode =~ s/\/.*//g;
				$episode =~ s/\(.*//g;
				$episode =~ s/a.*//g;
				$episode =~ s/b.*//g;
				$episode =~ s/\+.*//g;
				$episode =~ s/\;.*//g;
				$episode =~ s/\!.*//g;
				$episode =~ s/\-.*//g;
				$episode =~ s/,.*//g;
				$episode =~ s/[^0-9#\.\-_]//g;
				if ( $episode eq '') {
					undef $episode;
				}	
			}
			
			# SEASON/EPISODE (XMLTV_NS) (condition) (settings)
			if( $setup_episode eq $xmltv_ns ) {
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
			}
			
			# SEASON/EPISODE (ONSCREEN) (condition) (settings)
			if( $setup_episode eq $onscreen ) {
				if( defined $series ) {
					if( defined $episode ) {
						print "  <episode-num system=\"onscreen\">S$series E$episode</episode-num>\n";
					} else {
						print "  <episode-num system=\"onscreen\">S$series</episode-num>\n";
					}
				} elsif( defined $episode ) {
					print "  <episode-num system=\"onscreen\">E$episode</episode-num>\n";
				}
			}
			
			# AGE RATING (condition)
			if( defined $age) {
				if( $age ne '-1' ) {
					print "  <rating>\n    <value>$age</value>\n  </rating>\n";
				}
			}
			
			# END OF PROGRAMME
			print "</programme>\n";
		}
	}
}
