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
# TVTV JSON > XML CONVERTER       #
# #################################

# EPG

use strict;
use warnings;

binmode STDOUT, ":utf8";

use utf8;
use JSON;
use Data::Dumper;
use Time::Piece;
use DateTime::Format::Strptime;

# READ JSON INPUT FILE: EPG WORKFILE
my $json;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/epg_workfile" or die;
    $json = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: TVTV NUMERIC CHANNEL IDs
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tvtv_XXX_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tvtv_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "tvtv_genres.json" or die;
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

print "\n<!-- EPG DATA - SOURCE: TVTV YYY $countryVER -->\n\n";

my @attributes = @{ $data->{'attributes'} };
foreach my $attributes ( @attributes ) {
    
    my @listings = @{ $attributes->{'listings'} };
    foreach my $listings ( @listings ) {
		
		# ####################
        # DEFINE JSON VALUES #
        # ####################

        # DEFINE TIMES AND CHANNEL ID
        my $start = $listings->{'listDateTime'};
        my $duration   = $listings->{'duration'};
		my $durations   = $listings->{'duration'};
        my $cid   = $attributes->{'channel'}{'channelNumber'};
		$cid =~ s/\&/\&amp;/g;
        
        # CONVERT FROM TIMESTAMP TO XMLTV DATE FORMAT
		$start =~ s/://g;
		$start =~ s/-//g;
		$start =~ s/ //g;
	
		# CONVERT PROGRAMM DURATION IN SEC
		$duration = $duration * 60;
		
		# CONVERT STARTTIME IN EPOCH SEC
		my $parser = DateTime::Format::Strptime->new( pattern => '%Y%m%d%H%M%S' );
		my $dt = $parser->parse_datetime( $start );
		my $end = $dt->epoch;

		# CALCULATE DURATION TO STARTTIME TO GET STOPTIME
		$end = $end + $duration;		
		
		$end = gmtime($end)->strftime('%F %T');
		$end   =~ s/://g;
		$end   =~ s/-//g;
		$end   =~ s/ //g;
		
		# DEFINE PROGRAM STRINGS
		my $title     = $listings->{'showName'};
		my $subtitle  = $listings->{'episodeTitle'}; 
		my $director  = $listings->{'director'};
		my $desc      = $listings->{'description'};
		my $date      = $listings->{'year'};
		my $country   = $listings->{'country'};
		my $genre     = $listings->{'showType'};
		my $age       = $listings->{'rating'};
		my $star       = $listings->{'starRating'};
		
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
			
			# IMAGE (condition)
			if( defined $listings->{'artwork'}{'moviePoster'} ) {
				my $image = $listings->{'artwork'}{'moviePoster'} ;
				$image =~ s/^/https:\/\/www.tvtv.us\/tvm\/i\/image\/show\/960x1440\//g; 
				print "  <icon src=\"" . $image . "\" />\n";
			}else{
				if( defined $listings->{'showPicture'} ) {
				my $image = $listings->{'showPicture'} ;
				$image =~ s/^/https:\/\/www.tvtv.us\/tvm\/i\/image\/show\/960x1440\//g; 
				print "  <icon src=\"" . $image . "\" />\n";
				}	
			} 
			
			# TITLE (language)
			if ( $subtitle eq ''){
				undef $subtitle;
			} 
			if ( $title eq 'Movie') {
				if( defined $subtitle ) {
					$subtitle =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
					$title = $subtitle
				}		
			} 
			$title =~ s/\&/\&amp;/g;
			print "  <title lang=\"" . $languageVER . "\">" . $title . "</title>\n";
			
			# SUBTITLE (condition) (language)
			if( defined $subtitle ) {
				if ( $title eq $subtitle){
					undef $subtitle;
				} 
			}
				
			if( defined $subtitle ) {
				$subtitle =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY	
				print "  <sub-title lang=\"$languageVER\">$subtitle</sub-title>\n";
			}
			
			# DESCRIPTION (condition) (language)
			if( defined $desc ) {
				$desc =~ s/<[^>]*>//g;					# REMOVE XML STRINGS WITHIN JSON VALUE
				$desc =~ s/\&/\&amp;/g;					# REQUIRED TO READ XML FILE CORRECTLY				
				print "  <desc lang=\"$languageVER\">$desc</desc>\n";
			}
			
 			#CREDITS (condition)
			if ( $director eq ''){
				undef $director;
			} 
			if( defined $director ) {
				$director =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY	
				print "  <credits>\n";
				print "    <director>" . $director . "</director>\n";
				if( exists $listings->{'cast'} ) {
					my $cast =  $listings->{'cast'} ;
					$cast =~ s/\&/\&amp;/g;
					foreach my $actors ( split /,\s*/, $cast ){
						print "    <actor>" . $actors . "</actor>\n";
					}
				}
				print "  </credits>\n";
			} else{
				my $cast = $listings->{'cast'} ;
					if ($cast eq ''){
						undef $cast;
					}
				if( defined $cast ) {
					$cast =~ s/\&/\&amp;/g;
					print "  <credits>\n";
					foreach my $actors ( split /,\s*/, $cast ){
						print "    <actor>" . $actors . "</actor>\n";
					}
					print "  </credits>\n";		
				}				  
			} 
			


			# DATE (condition)
			if( $date eq '' ) {
				undef $date;
			}
			if( defined $date ) {
				print "  <date>$date</date>\n";
			}
			
			# COUNTRY (condition)
			if( defined $country ) {
				print "  <country>" . uc($country) . "</country>\n";
			}
			
			# CATEGORIES (USE ONE CATEGORY ONLY) (condition) (language) (settings)
			if ( defined $genre ) {
				$genre =~ s/\&/\&amp;/g; # REQUIRED TO READ XML FILE CORRECTLY
				$genre =~ s/Movies, //g;
				$genre =~ s/, / \/ /g;
				if ( $setup_genre eq $enabled ) {
					if ( defined $eit->{ $genre } ) {
						print "  <category lang=\"$languageVER\">" . $eit->{ $genre } . "</category>\n";
					} else {
						print "  <category lang=\"$languageVER\">$genre</category>\n";
						print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre" . "\n";;
					}
				}elsif ( $setup_genre eq $disabled ) {
					print "  <category lang=\"$languageVER\">$genre</category>\n";
				}
			}


		
			
			# SEASON/EPISODE (XMLTV_NS) (condition) (settings)
			my $showID    = $listings->{'showID'};
			my $cridFile = "cache/$showID";
			if( -e $cridFile ) {
				my $crid;
				{
	   			local $/; #Enable 'slurp' mode
    			open my $fh, "<", "cache/$showID" or die;
    			$crid = <$fh>;
    			close $fh;
				}
				my $cridDATA = decode_json ($crid);

				my $series     = $cridDATA->{'seasons'}[0]{'seasonNumber'};
				my $episode     = $cridDATA->{'episodes'}[0]{'seasonSeqNo'};
				
				if( defined $series ) {			
					if ( $series lt '1' || $series eq '' ) {
						undef $series;
					}
				}	

				if( defined $episode ) {
					if ( $episode lt '1'|| $episode eq '' ) {
						undef $episode;
					}
				}

				# USE SEASON / EPISODE PROVIDEY BY MANIFILES, ONLY IF EXIST, ELSE USE CRID INFORMATION
				my $maniseason = $listings->{'episodeNumber'};
					if( defined $maniseason ) {
						if ( $maniseason =~ m/-/ ) {
							undef $episode;
							undef $series;
							$episode = $maniseason;
							$episode =~ s/.*\-//g;
							$episode =~ s/[^0-9#\.\-_]//g;  
							$series = $maniseason;
							$series =~ s/\-.*//g;
							$series =~ s/[^0-9#\.\-_]//g;
							if ($series eq '' ) {
								undef $series;
							}
							if ( $episode eq '' ) {
								undef $episode;
							}	
						}
					}					

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
			}	

			# AGE RATING (condition)
			if ( $age eq '' ) {
				undef $age;
				}
			if( defined $age) {
				$age =~ s/TV14/16/g ;
				$age =~ s/TVG/6/g ;
				$age =~ s/TVMA/18/g ;
				$age =~ s/TVPG/6/g ;
				$age =~ s/TVY7/12/g ;
				$age =~ s/TVY/6/g ;
				$age =~ s/TV6/6/g ;
				if( $age ne '-1' ) {
					print "  <rating>\n    <value>$age</value>\n  </rating>\n";
				}
			}
			
			# STAR RATING (condition)
			if ( $star eq '' ) {
				undef $star;
			}
			if( defined $star) {
				if( $star gt '0' ) {
					$star = $star *2;
					$star =~ s/$/\/10/g;
					print "  <star-rating>\n    <value>$star</value>\n  </star-rating>\n";
				}
			}

			# END OF PROGRAMME
			print "</programme>\n";
		}
	}
}