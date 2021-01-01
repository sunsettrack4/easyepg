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
# HORIZON JSON > XML CONVERTER #
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
    open my $fh, "<", "/tmp/epg_workfile" or die;
    $json = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: HORIZON NUMERIC CHANNEL IDs
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/compare.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "hzn_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "hzn_genres.json" or die;
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

print "\n<!-- EPG DATA - SOURCE: HORIZON $countryVER -->\n\n";

my @attributes = @{ $data->{'attributes'} };
foreach my $attributes ( @attributes ) {
		
	my @item = @{ $attributes->{'listings'} };
	foreach my $item ( @item ) {
        
        # ####################
        # DEFINE JSON VALUES #
        # ####################
        
        # DEFINE TIMES AND CHANNEL ID
        my $start = $item->{'startTime'};
        my $end   = $item->{'endTime'};
        my $cid   = $item->{'stationId'};
        
        # CONVERT FROM MICROSOFT TIMESTAMP TO XMLTV DATE FORMAT
		my $startTIME = gmtime($start/1000)->strftime('%Y%m%d%H%M%S') . ' +0000';
		my $endTIME   = gmtime($end/1000)->strftime('%Y%m%d%H%M%S') . ' +0000';
		
		# DEFINE PROGRAM STRINGS
		my $program   = $item->{program};
		my $title     = $program->{'title'};
		my $subtitle  = $program->{'secondaryTitle'}; 
		my $desc      = $program->{'longDescription'};
		my $date      = $program->{'year'};
		my $genre1    = $program->{'categories'}[0]{'title'};
		my $genre2    = $program->{'categories'}[1]{'title'};
		my $genre3    = $program->{'categories'}[2]{'title'};
		my $age       = $program->{'parentalRating'};
		my $series    = $program->{'seriesNumber'};
		my $episode   = $program->{'seriesEpisodeNumber'};
		my $star      = $program->{'longDescription'};
		
		# DEFINE IMAGE PARAMETERS
		my $landscape    = "HighResLandscape";
		my $portrait     = "HighResPortrait";
		my $poster       = "tva-boxcover";
		my $landscape_location;
		my $portrait_location;
		my $poster_location;
        
        # DEFINE RYTEC CHANNEL ID (language)
		my $rytec = $chdata->{'channels'}{$countryVER};
        
        # DEFINE CHANNEL ID
        my $cidEXTold  = $chiddata->{'oldid2name'};
        my $cidEXTnew  = $chiddata->{'newid2name'};
        my $cname_old  = $chiddata->{'oldname2id'};
        my @configdata = @{ $chiddata->{'config'} };
        
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
			
			foreach my $selected_channel ( @configdata ) {
				# BEGIN OF PROGRAMME: START / STOP / CHANNEL (condition) (settings)
				if( $cidEXTnew->{$cid} eq $selected_channel ) {
					if( $setup_cid eq $enabled ) {
						if( defined $rytec->{$cidEXTnew->{$cid}} ) {
							print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $rytec->{$cidEXTnew->{$cid}} . "\">\n";
						} else {
							print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $cidEXTnew->{$cid} . "\">\n";
							print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXTnew->{$cid} . "\n";
						}
					} else {
						print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $cidEXTnew->{$cid} . "\">\n";
					}
				} elsif( defined $cidEXTold->{$cid} and not defined $cname_old->{$cidEXTnew->{$cid}} ) {
					if( $cidEXTold->{$cid} eq $selected_channel ) {
						if( $setup_cid eq $enabled ) {
							if( defined $rytec->{$cidEXTold->{$cid}} ) {
								print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $rytec->{$cidEXTold->{$cid}} . "\">\n";
							} else {
								print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $cidEXTold->{$cid} . "\">\n";
								print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXTold->{$cid} . "\n";
							}
						} else {
							print "<programme start=\"$startTIME\" stop=\"$endTIME\" channel=\"" . $cidEXTold->{$cid} . "\">\n";
						}
					}
				}
			}
			
			# IMAGE (condition) (loop)
			if( exists $program->{'images'} ) {
				my @image     = @{ $program->{'images'} };
				
				if( @image ) {
					while( my( $landscape_id, $image ) = each( @image ) ) {		# SEARCH FOR LANDSCAPE IMAGE
						if( $image->{'assetType'} eq $landscape ) {
							$landscape_location = $landscape_id;
							last;
						}
					}
					while( my( $portrait_id, $image ) = each( @image ) ) {		# SEARCH FOR PORTRAIT IMAGE
						if( $image->{'assetType'} eq $portrait ) {
							$portrait_location = $portrait_id;
							last;
						}
					}
					while( my( $poster_id, $image ) = each( @image ) ) {		# SEARCH FOR POSTER IMAGE
						if( $image->{'assetType'} eq $poster ) {
							$poster_location = $poster_id;
							last;
						}
					}
					if( defined $portrait_location) {
						print "  <icon src=\"" . $program->{'images'}[$portrait_location]{'url'} . "\" />\n";
					}  
					   elsif( defined $poster_location) {
						print "  <icon src=\"" . $program->{'images'}[$poster_location]{'url'} . "\" />\n";
					}
					if( defined $landscape_location) {
						print "  <poster src=\"" . $program->{'images'}[$landscape_location]{'url'} . "\" />\n";
					}
				}
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
			if( defined $desc ) {
				$desc =~ s/\&/\&amp;/g;					# REQUIRED TO READ XML FILE CORRECTLY
				$desc =~ s/<[^>]*>//g;					# REMOVE XML STRINGS WITHIN JSON VALUE
				$desc =~ s/[<>]//g;
				$desc =~ s/ IMDb Rating:.*\/10.//g;		# REMOVE IMDB STRING FROM DESCRIPTION
				$desc =~ s/ IMDb rating:.*\/10.//g;     # REMOVE IMDB STRING FROM GERMAN DESCRIPTION
				print "  <desc lang=\"$languageVER\">$desc</desc>\n";
			}
			
			# CREDITS (condition)
			if( exists $program->{'directors'} ) {
				my @director  = @{ $program->{'directors'} };
				
				if ( @director ) {
					print "  <credits>\n";
					foreach my $PRINTdirector ( @director ) {
						$PRINTdirector =~ s/\&/\&amp;/g;
						print "    <director>" . $PRINTdirector . "</director>\n";
					}
					if( exists $program->{'cast'} ) {
						my @cast      = @{ $program->{'cast'} };
						
						if ( @cast ) {
							foreach my $PRINTcast ( @cast ) {
								$PRINTcast =~ s/\&/\&amp;/g;
								print "    <actor>" . $PRINTcast . "</actor>\n";
							}
						}
					}
					print "  </credits>\n";
				}
			} elsif ( exists $program->{'cast'} ) {
				my @cast      = @{ $program->{'cast'} };
				
				if( @cast ) {
					print "  <credits>\n";
					foreach my $PRINTcast ( @cast ) {
						$PRINTcast =~ s/\&/\&amp;/g;
						print "    <actor>" . $PRINTcast . "</actor>\n";
					}
					print "  </credits>\n";
				}
			}
			
			# DATE (condition)
			if( defined $date ) {
				print "  <date>$date</date>\n";
			}
			
			# CATEGORIES (USE MOST DETAILLED CATEGORY) (condition) (language) (settings)
			if( $setup_category eq $disabled ) {
				if ( defined $genre2 ) {
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
				} elsif ( defined $genre1 ) {
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
					} else {
						print "  <category lang=\"$languageVER\">$genre1</category>\n";
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
					} else {
						print "  <category lang=\"$languageVER\">$genre2</category>\n";
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
}
