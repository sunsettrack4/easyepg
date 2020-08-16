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
# ZATTOO JSON > XML CONVERTER  #
# ##############################

# EPG

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
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

# READ JSON INPUT FILE: ZATTOO NUMERIC CHANNEL IDs
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "ztt_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "ztt_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "ztt_genres.json" or die;
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

print "\n<!-- EPG DATA - SOURCE: ZATTOO $countryVER -->\n\n";
 
foreach my $attributes ( $data->{attributes} ) {
    
    foreach my $item ( @$attributes ) {
        
        # ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE TIMES AND CHANNEL ID
        my $start = $item->{'s'};
        my $end   = $item->{'e'};
        my $cid   = $item->{'cid'};
        
        # CONVERT FROM MICROSOFT TIMESTAMP TO XMLTV DATE FORMAT
		my $startTIME = gmtime($start)->strftime('%Y%m%d%H%M%S') . ' +0000';
		my $endTIME   = gmtime($end)->strftime('%Y%m%d%H%M%S') . ' +0000';
		
		# DEFINE PROGRAM STRINGS
		my $program   = $item;
		my $image     = $program->{'i_t'};
		my $title     = $program->{'t'};
		my $subtitle  = $program->{'et'}; 
		my $desc      = $program->{'d'};
		my $credits   = $program->{'cr'};
		my @actor     = @{ $credits->{'actor'} };
		my @director  = @{ $credits->{'director'} };
		my $date      = $program->{'year'};
		my $country   = $program->{'country'};
		my $genre1    = $program->{'g'}[0];
		my $genre2    = $program->{'g'}[1];
		my $genre3    = $program->{'g'}[2];
		my $category  = $program->{'c'}[0];
		my $age       = $program->{'yp_r'};
		my $series    = $program->{'s_no'};
		my $episode   = $program->{'e_no'};
        
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
			if( defined $image ) {
				print "  <icon src=\"" . "https://images.zattic.com/cms/" . $image . "/original.jpg" . "\" />\n";
			}
			
			# TITLE (language)
			$title =~ s/\&/\&amp;/g;
			$title =~ s/<[^>]*>//g;
			$title =~ s/[<>]//g;
			print "  <title lang=\"$languageVER\">$title</title>\n";
			
			# SUBTITLE (condition) (language)
			if( defined $subtitle ) {
				$subtitle =~ s/\&/\&amp;/g;
				$subtitle =~ s/<[^>]*>//g;
				$subtitle =~ s/[<>]//g;
				print "  <sub-title lang=\"$languageVER\">$subtitle</sub-title>\n";
			}
			
			# DESCRIPTION (condition) (language)
			if( defined $desc and $desc ne "" ) {
				$desc =~ s/\&/\&amp;/g;					# REQUIRED TO READ XML FILE CORRECTLY
				$desc =~ s/<[^>]*>//g;					# REMOVE XML STRINGS WITHIN JSON VALUE
				$desc =~ s/[<>]//g;
				print "  <desc lang=\"$languageVER\">$desc</desc>\n";
			}
			
			# CREDITS (condition)
			if ( @director ) {
				print "  <credits>\n";
				foreach my $PRINTdirector ( @director ) {
					$PRINTdirector =~ s/\&/\&amp;/g;
					print "    <director>" . $PRINTdirector . "</director>\n";
				}
				if ( @actor ) {
					foreach my $PRINTactor ( @actor ) {
						$PRINTactor =~ s/\&/\&amp;/g;
						print "    <actor>" . $PRINTactor . "</actor>\n";
					}
				}
				print "  </credits>\n";
			} elsif ( @actor ) {
				print "  <credits>\n";
				foreach my $PRINTactor ( @actor ) {
					$PRINTactor =~ s/\&/\&amp;/g;
					print "    <actor>" . $PRINTactor . "</actor>\n";
				}
				print "  </credits>\n";
			}
			
			# DATE (condition)
			if( defined $date ) {
				print "  <date>$date</date>\n";
			}
			
			# COUNTRY (condition)
			if( defined $country and $country ne "" ) {
				print "  <country>" . $country . "</country>\n";
			}
			
			# CATEGORIES (USE SINGLE CATEGORY) (condition) (language) (settings)
			if( $setup_category eq $disabled ) {
				if ( defined $genre1 ) {
					$genre1 =~ s/\&/\&amp;/g;
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre1 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre1 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre1</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre1" . "\n";;
						}
					} else {
						print "  <category lang=\"$languageVER\">$genre1</category>\n";
					}
				} elsif ( defined $category ) {
					$category =~ s/\&/\&amp;/g;
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $category } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $category } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$category</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$category" . "\n";;
						}
					}
				}
			}
			
			# CATEGORIES (PRINT ALL CATEGORIES) (condition) (language) (settings)
			if( $setup_category eq $enabled ) {
				if ( defined $genre1 ) {
					$genre1 =~ s/\&/\&amp;/g;
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre1 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre1 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre1</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre1" . "\n";;
						}
					} else {
						print "  <category lang=\"$languageVER\">$genre1</category>\n";
					}
				} elsif ( defined $category ) {
					$category =~ s/\&/\&amp;/g;
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $category } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $category } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$category</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$category" . "\n";;
						}
					} else {
						print "  <category lang=\"$languageVER\">$category</category>\n";
					}
				}
				if ( defined $genre2 ) {
					$genre2 =~ s/\&/\&amp;/g;
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre2 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre2 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre2</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre2" . "\n";;
						}
					} else {
						print "  <category lang=\"$languageVER\">$genre2</category>\n";
					}
				}
				if ( defined $genre3 ) {
					$genre3 =~ s/\&/\&amp;/g;
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre3 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre3 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre3</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre3" . "\n";;
						}
					} else {
						print "  <category lang=\"$languageVER\">$genre3</category>\n";
					}
				}
			}
			
			# SEASON/EPISODE (XMLTV_NS) (condition) (settings)
			if( $setup_episode eq $xmltv_ns ) {
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
			}
			
			# SEASON/EPISODE (ONSCREEN) (condition) (settings)
			if( $setup_episode eq $onscreen ) {
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
				$age =~ s/FSK //g;
				print "  <rating>\n    <value>$age</value>\n  </rating>\n";
			}
			
			# END OF PROGRAMME
			print "</programme>\n";
		}
    }
}
