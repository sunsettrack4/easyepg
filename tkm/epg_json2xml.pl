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
# MAGENTA TV JSON > XML CONVERTER #
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
    open my $fh, "<", "tkm_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tkm_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tkm_genres.json" or die;
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

print "\n<!-- EPG DATA - SOURCE: TELEKOM MAGENTA TV $countryVER -->\n\n";

my @attributes = @{ $data->{'attributes'} };
foreach my $attributes ( @attributes ) {
    
    my @playlist = @{ $attributes->{'playbilllist'} };
    foreach my $item ( @playlist ) {
		
		# ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE TIMES AND CHANNEL ID
        my $start = $item->{'starttime'};
        my $end   = $item->{'endtime'};
        my $cid   = $item->{'channelid'};
        
        # CONVERT FROM TIMESTAMP TO XMLTV DATE FORMAT
		$start =~ s/[-: ]//g;
		$end   =~ s/[-: ]//g;
		$start =~ s/UTC.*//g;
		$end =~ s/UTC.*//g;

		# DEFINE PROGRAM STRINGS
		my $title     = $item->{'name'};
		my $subtitle  = $item->{'subName'}; 
		my $cast      = $item->{'cast'};
		my $actor     = $cast->{'actor'};
		my $director  = $cast->{'director'};
		my $producer  = $cast->{'producer'};
		my $desc      = $item->{'introduce'};
		my $date      = $item->{'producedate'};
		my $country   = $item->{'country'};
		my $genre1    = $item->{'genres'}[0];
		my $genre2    = $item->{'genres'}[1];
		my $genre3    = $item->{'genres'}[2];
		my $age       = $item->{'ratingid'};
		my $series    = $item->{'seasonNum'};
		my $episode   = $item->{'subNum'};
		
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
						print "<programme start=\"$start +0000\" stop=\"$end +0000\" channel=\"" . $rytec->{$cidEXT->{$cid}} . "\">\n";
					} else {
						print "<programme start=\"$start +0000\" stop=\"$end +0000\" channel=\"" . $cidEXT->{$cid} . "\">\n";
						print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXT->{$cid} . "\n";
					}
				} else {
					print "<programme start=\"$start +0000\" stop=\"$end +0000\" channel=\"" . $cidEXT->{$cid} . "\">\n";
				}
			} else {
				print "<programme start=\"$start +0000\" stop=\"$end +0000\" channel=\"$cid\">\n";
				print STDERR "[ EPG WARNING ] Channel ID unknown: " . $cid . "\n";
			}
			
			# IMAGE (condition) (loop)
			if( exists $item->{'pictures'} ) {
				my @image     = @{ $item->{'pictures'} };
			
				if ( @image ) {
					while( my( $image_id, $image ) = each( @image ) ) {		# SEARCH FOR IMAGE WITH THE HIGHEST RESOLUTION
						my @res = @{ $image->{'resolution'} };
						my $img = $image->{'href'};
						foreach my $res ( @res ) {
							if( $res eq '1920' ) {			# FULL HD 16:9
								$img_loc = $image_id;
								last;
							} elsif( $res eq '1440' ) {		# FULL HD 4:3
								$img_loc = $image_id;
								last;
							} elsif( $res eq '1280' ) {		# HD 16:9
								$img_loc = $image_id;
								last;
							} elsif( $res eq '1280' ) {		# HD 16:9
								$img_loc = $image_id;
								last;
							} elsif( $res eq '960' ) {		# SD 16:9
								$img_loc = $image_id;
								last;
							} elsif( $res eq '720' ) {		# SD 4:3
								$img_loc = $image_id;
								last;
							} elsif( $res eq '480' ) {		# LOW SD 16:9
								$img_loc = $image_id;
								last;
							} elsif( $res eq '360' ) {		# LOW SD 4:3
								$img_loc = $image_id;
								last;
							} elsif( $res eq '180' ) {		# JUST... WHY?!
								$img_loc = $image_id;
								last;
							}
						}
					}
					if( defined $img_loc ) {
						print "  <icon src=\"" . $item->{'pictures'}[$img_loc]{'href'} . "\" />\n";
					}
				}
			}
			
			# TITLE (language)
			$title =~ s/\&/\&amp;/g;
			print "  <title lang=\"" . $languageVER . "\">" . $title . "</title>\n";
			
			# SUBTITLE (condition) (language)
			if( defined $subtitle ) {
				$subtitle =~ s/\&/\&amp;/g;
				print "  <sub-title lang=\"$languageVER\">$subtitle</sub-title>\n";
			}
			
			# DESCRIPTION (condition) (language)
			if( defined $desc ) {
				$desc =~ s/\&/\&amp;/g;					# REQUIRED TO READ XML FILE CORRECTLY
				$desc =~ s/<[^>]*>//g;					# REMOVE XML STRINGS WITHIN JSON VALUE
				$desc =~ s/\n/\\n/g;	
				$desc =~ s/\\nDarsteller:.*//g;			# REMOVE ACTORS FROM DESCRIPTION
				$desc =~ s/\\nRegie:.*//g;				# REMOVE DIRECTORS FROM DESCRIPTION
				$desc =~ s/\\nProduzent:.*//g;			# REMOVE PRODUCERS FROM DESCRIPTION
				$desc =~ s/\\nAltersfreigabe:.*//g;		# REMOVE AGE RATING FROM DESCRIPTION
				$desc =~ s/\\n/\n/g;
				$desc =~ s/.* \d\d\d\d\n//g;			# REMOVE CATEGORY / COUNTRY / YEAR FROM DESCRIPTION
				
				print "  <desc lang=\"$languageVER\">$desc</desc>\n";
			}
			
			# CREDITS (condition)
			if( defined $director ) {
				print "  <credits>\n";
				$director =~ s/,/<\/director>\n    <director>/g;
				$director =~ s/\&/\&amp;/g;
				print "    <director>" . $director . "</director>\n";
				
				if( defined $actor ) {
					$actor =~ s/,/<\/actor>\n    <actor>/g;
					$actor =~ s/\&/\&amp;/g;
					print "    <actor>" . $actor . "</actor>\n";
				}
				
				if( defined $producer ) {
					$producer =~ s/,/<\/producer>\n    <producer>/g;
					$producer =~ s/\&/\&amp;/g;
					print "    <producer>" . $producer . "</producer>\n";
				}
				
				print "  </credits>\n";
			} elsif( defined $actor ) {
				print "  <credits>\n";
				$actor =~ s/,/<\/actor>\n    <actor>/g;
				$actor =~ s/\&/\&amp;/g;
				print "    <actor>" . $actor . "</actor>\n";
				
				if( defined $producer ) {
					$producer =~ s/,/<\/producer>\n    <producer>/g;
					$producer =~ s/\&/\&amp;/g;
					print "    <producer>" . $producer . "</producer>\n";
				}
				
				print "  </credits>\n";
			} elsif( defined $producer ) {
				print "  <credits>\n";
				$producer =~ s/,/<\/producer>\n    <producer>/g;
				$producer =~ s/\&/\&amp;/g;
				print "    <producer>" . $producer . "</producer>\n";
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
			if( $setup_category eq $disabled ) {
				if ( defined $genre1 ) {
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre1 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre1 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre1</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre1" . "\n";;
						}
					}
				}
			}
			
			# CATEGORIES (PRINT ALL CATEGORIES) (condition) (language) (settings)
			if( $setup_category eq $enabled ) {
				if ( defined $genre1 ) {
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre1 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre1 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre1</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre1" . "\n";;
						}
					}
				}
				if ( defined $genre2 ) {
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre2 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre2 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre2</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre2" . "\n";;
						}
					}
				}
				if ( defined $genre3 ) {
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre3 } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre3 } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre3</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre3" . "\n";;
						}
					}
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
