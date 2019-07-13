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
# RADIOTIMES JSON > XML CONVERTER #
# #################################

# EPG

use strict;
use warnings;
 
binmode STDOUT, ":utf8";
use utf8;
 
use JSON;
use LWP::Simple;
use HTML::TreeBuilder;
use Data::Dumper;
use Time::Piece;
use DateTime;
use DateTime::Format::DateParse;

# READ JSON INPUT FILE: EPG MANIFEST WORKFILE
my $json_mani;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "/tmp/epg_workfile" or die;
    $json_mani = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RADIOTIMES NUMERIC CHANNEL IDs
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "rdt_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "rdt_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "rdt_genres.json" or die;
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
my $manidata  = decode_json($json_mani);
my $chdata    = decode_json($chlist);
my $chiddata  = decode_json($chidlist);
my $genredata = decode_json($genrelist);
my $initdata  = decode_json($init);
my $setupdata = decode_json($settings);

# DEFINE COUNTRY VERSION
my $countryVER =  $initdata->{'country'};
        
# DEFINE LANGUAGE VERSION
my $languageVER =  $initdata->{'language'};

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

print "\n<!-- EPG DATA - SOURCE: RADIOTIMES $countryVER -->\n\n";

my @maniattributes = @{ $manidata->{'attributes'} };

foreach my $maniattributes ( @maniattributes ) {
	my @channels = @{ $maniattributes->{'Channels'} };
	
	foreach my $channels ( @channels ) {
		my $cid   = $channels->{'Id'};
		my @manilistings = @{ $channels->{'TvListings'} };
		
		foreach my $manilistings ( @manilistings ) {
	
			# DEFINE START TIME
			my $start = $manilistings->{'StartTimeMF'};
			$start    =~ s/Z//g;
			$start    =~ s/ /T/g;
			my $startUK  = DateTime::Format::DateParse->parse_datetime($start, 'Europe/London');
			$startUK->set_time_zone('UTC');
			my $s_YMD = $startUK->ymd;
			$s_YMD    =~ s/-//g;
			my $s_HMS = $startUK->hms;
			$s_HMS    =~ s/://g;
			my $startUTC = $s_YMD . $s_HMS;
			
			# DEFINE END TIME
			my $end   = $manilistings->{'EndTimeMF'};
			$end      =~ s/Z//g;
			$end      =~ s/ /T/g;
			my $endUK = DateTime::Format::DateParse->parse_datetime($end, 'Europe/London');
			$endUK->set_time_zone('UTC');
			my $e_YMD = $endUK->ymd;
			$e_YMD    =~ s/-//g;
			my $e_HMS = $endUK->hms;
			$e_HMS    =~ s/://g;
			my $endUTC = $e_YMD . $e_HMS;
							
			# CONVERT TO XMLTV DATE FORMAT
			my $startTIME = $startUTC . ' +0000';
			my $endTIME   = $endUTC . ' +0000';
					
			# DEFINE IMAGE
			my $image = $manilistings->{'Image'};
						
			# DEFINE TITLE
			my $title = $manilistings->{'Title'};
			
			# DEFINE DESCRIPTION
			my $desc  = $manilistings->{'Description'};
						
			# DEFINE GENRE
			my $genre = $manilistings->{'Genre'};
					
			# DEFINE MANIFEST PROGRAMME ID + TYPE
			my $manipid = $manilistings->{'EpisodeId'};
			my $spec    = $manilistings->{'Specialisation'};
			
			# ##################
			# PRINT XML OUTPUT #
			# ##################
			
			# PRINT PROGRAMME STRING ONLY IF CERTAIN VALUES ARE DEFINED
			if( defined $title and defined $start and defined $end and defined $cid and defined $spec) {
			
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
				
				# ###############
				# EPG ROUTINE 1 #
				# ###############
				
				#
				# EPG DETAILS FILE
				#
				
				my $json_epg;
				
				if(open(my $tvm, "cache/new/$manipid" . "_TV")) {
					local $/;
					$json_epg = <$tvm>;
					close $tvm;
				} elsif(open(my $mvm, "cache/new/$manipid" . "_MV")) {
					local $/;
					$json_epg = <$mvm>;
					close $mvm;
				}
					
				if( defined $json_epg ) {
				
					my $epg_attributes = eval { decode_json($json_epg) };
							
					if( defined $epg_attributes ) {
						
						# IMAGE (condition)
						my $adv_image = $epg_attributes->{'image'};
						if( defined $adv_image ) {
							$adv_image    =~ s/\&.*//g;
							print "  <icon src=\"" . $adv_image . "\" />\n";
						} elsif( defined $image ) {
							$image    =~ s/\&.*//g;
							print "  <icon src=\"" . $image . "\" />\n";
						}
						
						# TITLE (condition)
						my $display_title = $epg_attributes->{'display_title'}->{'title'};
						my $medium_title  = $epg_attributes->{'title'};
						if( defined $display_title ) {
							$display_title =~ s/\&/\&amp;/g;
							$display_title =~ s/<[^>]*>//g;
							$display_title =~ s/[<>]//g;
							print "  <title lang=\"" . $languageVER . "\">" . $display_title . "</title>\n";
						} elsif( defined $medium_title ) {
							$medium_title =~ s/\&/\&amp;/g;
							$medium_title =~ s/<[^>]*>//g;
							$medium_title =~ s/[<>]//g;
							print "  <title lang=\"" . $languageVER . "\">" . $medium_title . "</title>\n";
						} else {
							$title =~ s/\&#39;/'/g;
							$title =~ s/\&/\&amp;/g;
							$title =~ s/<[^>]*>//g;
							$title =~ s/[<>]//g;
							print "  <title lang=\"" . $languageVER . "\">" . $title . "</title>\n";
						}
							
						# SUB-TITLE (condition)
						my $subtitle = $epg_attributes->{'display_title'}->{'subtitle'};
						if( defined $subtitle ) {
							$subtitle =~ s/\&/\&amp;/g;
							$subtitle =~ s/<[^>]*>//g;
							$subtitle =~ s/[<>]//g;
							print "  <sub-title lang=\"" . $languageVER . "\">" . $subtitle . "</sub-title>\n";
						}
						
						# DESCRIPTION (condition)
						my $long_desc   = $epg_attributes->{'long_description'};
						my $medium_desc = $epg_attributes->{'description'};
						if( defined $long_desc ) {
							$long_desc =~ s/\&/\&amp;/g;
							$long_desc =~ s/<[^>]*>//g;
							$long_desc =~ s/[<>]//g;
							print "  <desc lang=\"" . $languageVER . "\">" . $long_desc . "</desc>\n";
						} elsif( defined $medium_desc ) {
							$medium_desc =~ s/\&/\&amp;/g;
							$medium_desc =~ s/<[^>]*>//g;
							$medium_desc =~ s/[<>]//g;
							print "  <desc lang=\"" . $languageVER . "\">" . $medium_desc . "</desc>\n";
						} elsif( defined $desc ) {
							$desc =~ s/\&#39;/'/g;
							$desc =~ s/\&/\&amp;/g;
							$desc =~ s/<[^>]*>//g;
							$desc =~ s/[<>]//g;
							print "  <desc lang=\"" . $languageVER . "\">" . $desc . "</desc>\n";
						}
							
						# CREDITS (condition)
						if(exists $epg_attributes->{'imco_cast'} ) {
							my @cast     = @{ $epg_attributes->{'imco_cast'} };
							if( @cast ) {
								print "  <credits>\n";
									
								foreach my $cast ( @cast ) {
									my $name = $cast->{'name'};
									my $role = $cast->{'role'};
									my $type = $cast->{'type'};
									$name =~ s/\&/\&amp;/g;
									
									if( $type eq "crew" ) {
										if( $role eq "Director" ) {
											print "    <director>" . $name . "</director>\n";
										} elsif( ($role =~ /^(Producer)$/) ) {
											print "    <producer>" . $name . "</producer>\n";
										}
									}
											
									if( $type eq "cast" ) {
										if( $role eq "Presenter" ) {
											print "    <presenter>" . $name . "</presenter>\n";
										} elsif($role =~ /^(Host|Contributor|Team Captain|Panellist)$/) {
											print "    <contributor>" . $name . "</contributor>\n"; 		# PLACE HOLDER
										} else {
											print "    <actor>" . $name . "</actor>\n";
										}
									}
								}
								print "  </credits>\n";
							}
						}
									
						# DATE (condition)
						my $date     = $epg_attributes->{'year'};
						if( defined $date )	{
							print "  <date>" . $date . "</date>\n";
						}
									
						# COUNTRY (condition)
						my $country_1  = $epg_attributes->{'countries_of_origin'}[0];
						my $country_2  = $epg_attributes->{'countries_of_origin'}[1];
						my $country_3  = $epg_attributes->{'countries_of_origin'}[2];
									
						if( defined $country_3 ) {
							print "  <country>" . $country_3 . ", " . $country_2 . ", " . $country_1 . "</country>\n";
						} elsif( defined $country_2 ) {
							print "  <country>" . $country_2 . ", " . $country_1 . "</country>\n";
						} elsif( defined $country_1 ) {
							print "  <country>" . $country_1 . "</country>\n";
						}
					}
				
				#
				# EPG MANIFEST FILE (IF DETAILS FILE COULD NOT BE FOUND)
				#
				
				} else {
					
					# IMAGE (condition)
					if( defined $image ) {
						$image    =~ s/\&.*//g;
						print "  <icon src=\"" . $image . "\" />\n";
					}
					
					# TITLE
					$title =~ s/\&#39;/'/g;
					$title =~ s/\&/\&amp;/g;
					$title =~ s/<[^>]*>//g;
					$title =~ s/[<>]//g;
					print "  <title lang=\"" . $languageVER . "\">" . $title . "</title>\n"; 
					
					# DESC (condition)
					if( defined $desc ) {
						$desc =~ s/\&#39;/'/g;
						$desc =~ s/\&/\&amp;/g;
						$desc =~ s/<[^>]*>//g;
						$desc =~ s/[<>]//g;
						print "  <desc lang=\"" . $languageVER . "\">" . $desc . "</desc>\n";
					}
				}
				
				# CATEGORIES (USE ONE CATEGORY ONLY) (condition) (language) (settings)
				if ( defined $genre and $genre ne "" ) {
					if ( $setup_genre eq $enabled ) {
						if ( defined $eit->{ $genre } ) {
							print "  <category lang=\"$languageVER\">" . $eit->{ $genre } . "</category>\n";
						} else {
							print "  <category lang=\"$languageVER\">$genre</category>\n";
							print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$genre" . "\n";;
						}
					} else {
						print "  <category lang=\"$languageVER\">$genre</category>\n";
					}
				}
				
				# ###############
				# EPG ROUTINE 2 #
				# ###############
				
				#
				# EPG DETAILS FILE
				#
				
				if( defined $json_epg ) {
				
					my $epg_attributes = eval { decode_json($json_epg) };
					
					if( defined $epg_attributes ) {
						
						my $epgpid   = $epg_attributes->{'id'};
							
						if( defined $epgpid ) {
							if( $epgpid eq $manipid ) {
								
								# SEASON/EPISODE (XMLTV_NS) (condition) (settings)
								my $series   = $epg_attributes->{'series_number'};
								my $episode  = $epg_attributes->{'episode_number'};
								
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
								my @age      = @{ $epg_attributes->{'certificates'} };
								my $age2     = $epg_attributes->{'restrictions'}[0]{'minimumAGE'};
								my $var_loc;
								
								if( @age ) {
									while( my( $value_id, $value ) = each( @age ) ) {
										my $class = $value->{'classification'};
										if( $class eq "U" ) {			# UNIVERSAL
											$var_loc = $value_id;
											last;
										} elsif( $class eq "PG" ) {		# PG
											$var_loc = $value_id;
											last;
										} elsif( $class eq "12A" ) {	# AGE: 12 A
											$var_loc = $value_id;
											last;
										} elsif( $class eq "12" ) {		# AGE: 12
											$var_loc = $value_id;
											last;
										} elsif( $class eq "15" ) {		# AGE: 16
											$var_loc = $value_id;
											last;
										} elsif( $class eq "18" ) {		# AGE: 18
											$var_loc = $value_id;
											last;
										}
									}
									
									if( defined $var_loc ) {
										print "  <rating system=\"BBFC\">\n    <value>" . $epg_attributes->{'certificates'}[$var_loc]{'classification'} . "</value>\n  </rating>\n";
									} elsif( defined $age2 ) {
										print "  <rating system=\"BBFC\">\n    <value>" . $age2 . "</value>\n  </rating>\n";
									}
								}
								
								# STAR RATING (condition)
								my $star     = $epg_attributes->{'imco_reviews'}[0]{'rating'};
								if( defined $star ) {
									print "  <star-rating>\n    <value>" . $star*2 . "/10</value>\n</star-rating>\n";
								}
							}
						}
					}
				
				#
				# EPG MANIFEST FILE (IF DETAILS FILE COULD NOT BE FOUND)
				#
				
				} else {
					
					# SEASON/EPISODE (XMLTV_NS) (condition) (settings)
					my $episode = $manilistings->{'EpisodePositionInSeries'};
					
					if( $setup_episode eq $xmltv_ns ) {
					
						if( defined $episode ) {
							$episode =~ s/\/.*//g;
							my $XMLepisode = $episode - 1;
							print "  <episode-num system=\"xmltv_ns\"> . $XMLepisode . </episode-num>\n";
						}
					}
								
					# SEASON/EPISODE (ONSCREEN) (condition) (settings)
					if( $setup_episode eq $onscreen ) {
						if( defined $episode ) {
							$episode =~ s/\/.*//g;
							print "  <episode-num system=\"onscreen\">E$episode</episode-num>\n";
						}
					}
					
					# STAR RATING (condition)
					my $star = $manilistings->{'FilmStarRating'};
					if( defined $star ) {
						print "  <star-rating>\n    <value>" . $star*2 . "/10</value>\n</star-rating>\n";
					}
								
				}
				
			print "</programme>\n";
			
			}
		}
	}
}
