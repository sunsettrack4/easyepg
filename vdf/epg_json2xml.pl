#!/usr/bin/perl

#      Copyright (C) 2019 Jan-Luca Neumann
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
# VODAFONE JSON > XML CONVERTER #
# #################################

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
    open my $fh, "<", "/tmp/epg_workfile" or die;
    $json = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: MAGENTA NUMERIC CHANNEL IDs
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "vdf_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "vdf_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "vdf_genres.json" or die;
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

print "\n<!-- EPG DATA - SOURCE: VODAFONE $countryVER -->\n\n";

my @attributes = @{ $data->{'attributes'} };
foreach my $attributes ( @attributes ) {
    
    
    
		
		# ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE TIMES AND CHANNEL ID
        my $start = $attributes->{'start_date_time'};
        my $end   = $attributes->{'end_date_time'};
        my $cid   = $attributes->{'channelId'};
        
        # CONVERT FROM TIMESTAMP TO XMLTV DATE FORMAT
		my $secend = '00';
		$start =~ s/T//g;
		$start =~ s/-//g;
		$start =~ s/://g;

		$end   =~ s/T//g;
		$end   =~ s/-//g;
		$end   =~ s/://g;

		# DEFINE PROGRAM STRINGS
		my $title     = $attributes->{'title'};
		my $subtitle  = $attributes->{'text_short_text'}; 
		my $desc      = $attributes->{'text_text'};
		my $date      = $attributes->{'production_year'};
		my $country   = $attributes->{'country'};
#		my $genre1    = $attributes->{'category'}[0]{'text'};
		my $genre2    = $attributes->{'category'}[1]{'text'};
#		my $genre3    = $attributes->{'category'}[2]{'text'};
		my $series    = $attributes->{'relay'};
		my $episode   = $attributes->{'series_number'};
		
		# DEFINE CAST
		my $actor1     = $attributes->{'person_actor'}[0]{'name'};
		my $actor2     = $attributes->{'person_actor'}[1]{'name'};
		my $actor3     = $attributes->{'person_actor'}[2]{'name'};
		my $actor4     = $attributes->{'person_actor'}[3]{'name'};
		my $actor5     = $attributes->{'person_actor'}[4]{'name'};
		my $actor6     = $attributes->{'person_actor'}[5]{'name'};
		my $actor7     = $attributes->{'person_actor'}[6]{'name'};
		my $director  = $attributes->{'person_director'}[0]{'name'};
		my $producer1  = $attributes->{'person_producer'}[0]{'name'};
		my $producer2  = $attributes->{'person_producer'}[1]{'name'};

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
						print "<programme start=\"$start$secend +0000\" stop=\"$end$secend +0000\" channel=\"" . $rytec->{$cidEXT->{$cid}} . "\">\n";
					} else {
						print "<programme start=\"$start$secend +0000\" stop=\"$end$secend +0000\" channel=\"" . $cidEXT->{$cid} . "\">\n";
						print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXT->{$cid} . "\n";
					}
				} else {
					print "<programme start=\"$start$secend +0000\" stop=\"$end$secend +0000\" channel=\"" . $cidEXT->{$cid} . "\">\n";
				}
			} else {
				print "<programme start=\"$start$secend +0000\" stop=\"$end$secend +0000\" channel=\"$cid\">\n";
				print STDERR "[ EPG WARNING ] Channel ID unknown: " . $cid . "\n";
			}
			
			# IMAGE (condition)
			if( exists $attributes->{'allImages'} ) {
				my $img5 = $attributes->{'allImages'}[5]{'image_source_url'};
					if( defined $img5 ) {
						$img5 =~ s/\#.*//g; 
						print "  <icon src=\"" . $img5 . "\" />\n";
						}	
			}
			
			# TITLE (language)
			$title =~ s/\&/\&amp;/g;
			$title =~ s/<[^>]*>//g;
			$title =~ s/[<>]//g;
			print "  <title lang=\"" . $languageVER . "\">" . $title . "</title>\n";
			
			# SUBTITLE (condition) (language)
			if( defined $subtitle ) {
				$subtitle =~ s/\&/\&amp;/g;
				$subtitle =~ s/<[^>]*>//g;
				$subtitle =~ s/[<>]//g;
				print "  <sub-title lang=\"$languageVER\">$subtitle</sub-title>\n";
			}
			
			# DESCRIPTION (condition) (language)
			if( defined $desc ) {
				$desc =~ s/\&/\&amp;/g;					# REQUIRED TO READ XML FILE CORRECTLY
				$desc =~ s/<[^>]*>//g;					# REMOVE XML STRINGS WITHIN JSON VALUE
				$desc =~ s/[<>]//g;
				$desc =~ s/\n/\\n/g;	
				$desc =~ s/\\n/\n/g;
				
				print "  <desc lang=\"$languageVER\">$desc</desc>\n";
			}
			
			# CREDITS (condition)		
			if( defined $director ) {
				print "  <credits>\n";
				$director =~ s/,/<\/director>\n    <director>/g;
				$director =~ s/\&/\&amp;/g;
				print "    <director>" . $director . "</director>\n";
				
				if( defined $actor1 ) {
					$actor1 =~ s/,/<\/actor>\n    <actor>/g;
					$actor1 =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor1 . "</actor>\n";
				}

					if( defined $actor2 ) {
					$actor2 =~ s/,/<\/actor>\n    <actor>/g;
					$actor2 =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor2 . "</actor>\n";
				}

					if( defined $actor3 ) {
					$actor3 =~ s/,/<\/actor>\n    <actor>/g;
					$actor3 =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor3 . "</actor>\n";
				}

					if( defined $actor4 ) {
					$actor4 =~ s/,/<\/actor>\n    <actor>/g;
					$actor4 =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor4 . "</actor>\n";
				}

					if( defined $actor5 ) {
					$actor5 =~ s/,/<\/actor>\n    <actor>/g;
					$actor5 =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor5 . "</actor>\n";
				}

					if( defined $actor6 ) {
					$actor6 =~ s/,/<\/actor>\n    <actor>/g;
					$actor6 =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor6 . "</actor>\n";
				}

					if( defined $actor7 ) {
					$actor7 =~ s/,/<\/actor>\n    <actor>/g;
					$actor7 =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor7 . "</actor>\n";
				}
				
				if( defined $producer1 ) {
					$producer1 =~ s/,/<\/producer>\n    <producer>/g;
					$producer1 =~ s/\&/\&amp;/g;
					print "    <producer>" . $producer1 . "</producer>\n";
				}

					if( defined $producer2 ) {
					$producer2 =~ s/,/<\/producer>\n    <producer>/g;
					$producer2 =~ s/\&/\&amp;/g;
					print "    <producer>" . $producer2 . "</producer>\n";
				}
				
				print "  </credits>\n";
			} elsif( defined $actor1 ) {
				print "  <credits>\n";
				$actor1 =~ s/,/<\/actor>\n    <actor>/g;
				$actor1 =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor1 . "</actor>\n";
				
				if( defined $actor2 ) {
				$actor2 =~ s/,/<\/actor>\n    <actor>/g;
				$actor2 =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor2 . "</actor>\n";
				}

				if( defined $actor3 ) {
				$actor3 =~ s/,/<\/actor>\n    <actor>/g;
				$actor3 =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor3 . "</actor>\n";
				}

				if( defined $actor4 ) {
				$actor4 =~ s/,/<\/actor>\n    <actor>/g;
				$actor4 =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor4 . "</actor>\n";
				}

				if( defined $actor5 ) {
				$actor5 =~ s/,/<\/actor>\n    <actor>/g;
				$actor5 =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor5 . "</actor>\n";
				}

				if( defined $actor6 ) {
				$actor6 =~ s/,/<\/actor>\n    <actor>/g;
				$actor6 =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor6 . "</actor>\n";
				}

				if( defined $actor7 ) {
				$actor7 =~ s/,/<\/actor>\n    <actor>/g;
				$actor7 =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor7 . "</actor>\n";
				}

				if( defined $producer1 ) {
					$producer1 =~ s/,/<\/producer>\n    <producer>/g;
					$producer1 =~ s/\&/\&amp;/g;
					print "    <producer>" . $producer1 . "</producer>\n";
				}

				if( defined $producer2 ) {
					$producer2 =~ s/,/<\/producer>\n    <producer>/g;
					$producer2 =~ s/\&/\&amp;/g;
					print "    <producer>" . $producer2 . "</producer>\n";
				}
				
				print "  </credits>\n";
			} elsif( defined $producer1 ) {
				print "  <credits>\n";
				$producer1 =~ s/,/<\/producer>\n    <producer>/g;
				$producer1 =~ s/\&/\&amp;/g;
				print "    <producer>" . $producer1 . "</producer>\n";

				if( defined $producer2 ) {
					$producer2 =~ s/,/<\/producer>\n    <producer>/g;
					$producer2 =~ s/\&/\&amp;/g;
					print "    <producer>" . $producer2 . "</producer>\n";
				}

				print "  </credits>\n";
			}
			
			# DATE (condition)
			if( defined $date ) {
				$date =~ s/-.*//g;
				print "  <date>$date</date>\n";
			}
			
			# COUNTRY (condition)
			if( defined $country ) {
				print "  <country>" . uc($country) . "</country>\n";
			}
			
			# CATEGORIES (USE ONE CATEGORY ONLY) (condition) (language) (settings)
#			if( $setup_category eq $disabled ) {
				if ( defined $genre2 ) {
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre2 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre2 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre2</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre2" . "\n";;
						}
					}elsif ( $setup_genre eq $disabled ) {
					print "  <category lang=\"$languageVER\">$genre2</category>\n";
					}
				}
#			}
			
#			# CATEGORIES (PRINT ALL CATEGORIES) (condition) (language) (settings)
#			if( $setup_category eq $enabled ) {
#				if ( defined $genre1 ) {
#					if ( $setup_genre eq $enabled ) {
#						if ( defined $eit->{ $genre1 } ) {
#							print "  <category lang=\"$languageVER\">" . $eit->{ $genre1 } . "</category>\n";
#						} else {
#							print "  <category lang=\"$languageVER\">$genre1</category>\n";
#							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre1" . "\n";;
#						}
#					}
#				}
#				if ( defined $genre2 ) {
#					if ( $setup_genre eq $enabled ) {
#						if ( defined $eit->{ $genre2 } ) {
#							print "  <category lang=\"$languageVER\">" . $eit->{ $genre2 } . "</category>\n";
#						} else {
#							print "  <category lang=\"$languageVER\">$genre2</category>\n";
#							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre2" . "\n";;
#						}
#					}
#				}
#				if ( defined $genre3 ) {
#					if ( $setup_genre eq $enabled ) {
#						if ( defined $eit->{ $genre3 } ) {
#							print "  <category lang=\"$languageVER\">" . $eit->{ $genre3 } . "</category>\n";
#						} else {
#							print "  <category lang=\"$languageVER\">$genre3</category>\n";
#							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre3" . "\n";;
#						}
#					}
#				}
#			}
			
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
			
			# END OF PROGRAMME
			print "</programme>\n";
		}
	
}