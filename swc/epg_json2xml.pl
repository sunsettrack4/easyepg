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

# ###############################
# SWISSCOM JSON > XML CONVERTER #
# ###############################

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

# READ JSON INPUT FILE: SWISSCOM NUMERIC CHANNEL IDs
my $chidlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "swc_cid.json" or die;
    $chidlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: RYTEC ID LIST
my $chlist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "swc_channels.json" or die;
    $chlist = <$fh>;
    close $fh;
}

# READ JSON INPUT FILE: EIT CATEGORY LIST
my $genrelist;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "swc_genres.json" or die;
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
# my $languageVER =  $initdata->{'language'};		# LANGUAGE IS BASED ON PROVIDED EPG DATA

print "\n<!-- EPG DATA - SOURCE: SWISSCOM $countryVER -->\n\n";
 
foreach my $attributes ( $data->{attributes} ) {
    
    foreach my $item ( @$attributes ) {
		
		
		# #######################
		# DEFINE GENERAL VALUES #
		# #######################
		
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
        
        
        # #############################################
        # DEFINE PROGRAMME STRINGS + PRINT XML OUTPUT #
        # #############################################
        
        #
        # START + END + CHANNEL
        #
        
        my $channelnodes = $item->{'Nodes'};
        my @channelitems = @{ $channelnodes->{'Items'} };
        
        foreach my $channelitems ( @channelitems ) {
			my $channelcontents = $channelitems->{'Content'};
			
			my $broadcastnodes = $channelcontents->{'Nodes'};
			my @broadcastitems = @{ $broadcastnodes->{'Items'} };
			
			foreach my $broadcastitems ( @broadcastitems ) {
				my $cid          = $broadcastitems->{'Channel'};
				my @availability = @{ $broadcastitems->{'Availabilities'} };
			
				foreach my $availability ( @availability ) {
					my $start = $availability->{'AvailabilityStart'};
					my $stop  = $availability->{'AvailabilityEnd'};
					
					$start =~ s/[-:TZ]//g;
					$stop  =~ s/[-:TZ]//g;
					
					if( defined $cidEXT->{$cid} ) {
						if( $setup_cid eq $enabled ) {
							if( defined $rytec->{$cidEXT->{$cid}} ) {
								print "<programme start=\"" . $start . " +0000\" stop=\"" . $stop . " +0000\" channel=\"" . $rytec->{$cidEXT->{$cid}} . "\">\n";
							} else {
								print "<programme start=\"$start +0000\" stop=\"$stop +0000\" channel=\"" . $cidEXT->{$cid} . "\">\n";
								print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXT->{$cid} . "\n";
							}
						} else {
							print "<programme start=\"$start +0000\" stop=\"$stop +0000\" channel=\"" . $cidEXT->{$cid} . "\">\n";
						}
					} else {
						print "<programme start=\"$start +0000\" stop=\"$stop +0000\" channel=\"$cid\">\n";
						print STDERR "[ EPG WARNING ] Channel ID unknown: " . $cid . "\n";
					}
			
			
					#
					# IMAGE
					#
				
					my $contents     = $broadcastitems->{'Content'};
					my $contentnodes = $contents->{'Nodes'};
					
					# DEFINE IMAGE PARAMETERS
					my $imagetype    = "Image";
					my $image_location;
					
					if( defined $contentnodes ) {
						my @contentitems = @{ $contentnodes->{'Items'} };
						
						if ( @contentitems ) {
							while( my( $image_id, $image ) = each( @contentitems ) ) {		# SEARCH FOR IMAGE
								if( $image->{'Kind'} eq $imagetype ) {
									$image_location = $image_id;
									last;
								}
							}
							if( defined $image_location) {
								print "  <icon src=\"https://services.sg1.etvp01.sctv.ch/content/images" . $contentnodes->{'Items'}[$image_location]{'ContentPath'} . "_w1920.webp\" />\n";
							}
						}	
					}
			
			
					#
					# TITLE
					#
				
					my $contentdesc  = $contents->{'Description'};
					
					my $title       = $contentdesc->{'Title'};
					my $languageVER = $contentdesc->{'Language'};
					
					$title =~ s/\&/\&amp;/g;
					print "  <title lang=\"" . $languageVER . "\">" . $title . "</title>\n";
				
				
					#
					# SUB-TITLE
					#

					my $subtitle = $contentdesc->{'Subtitle'};
					
					if( defined $subtitle ) {
						$subtitle =~ s/\&/\&amp;/g;
						print "  <sub-title lang=\"" . $languageVER . "\">" . $subtitle . "</sub-title>\n";
					}
				
				
					#
					# DESCRIPTION
					#
					
					my $desc = $contentdesc->{'Summary'};
					
					if( defined $desc ) {
						$desc =~ s/\&/\&amp;/g;
						print "  <desc lang=\"" . $languageVER . "\">" . $desc . "</desc>\n";
					}
				
				
					#
					# CREDITS
					#

					my @relations    = @{ $broadcastitems->{'Relations'} };
					
					if ( @relations ) {
						
						while( my( $cast, $cast_id ) = each( @relations ) ) {
							if( $cast_id->{'Role'} eq "Actor" ) {
								print "  <credits>\n";
								
								foreach my $relations ( @relations ) {
									my $role = $relations->{'Role'};
									
									if( $role eq "Director" ) {
										my $director  = $relations->{'TargetNode'}{'Content'}{'Description'};
										my $dir_fname = $director->{'FirstName'};
										my $dir_lname = $director->{'LastName'};
										
										if( defined $dir_lname ) {
											if( defined $dir_fname) {
												print "    <director>" . $dir_fname . " " . $dir_lname . "</director>\n";
											} else {
												print "    <director>" . $dir_lname . "</director>\n";
											}
										} elsif( defined $dir_fname ) {
											print "    <director>" . $dir_fname . "</director>\n";
										}
									}
									
									if( $role eq "Actor" ) {
										my $actor     = $relations->{'TargetNode'}{'Content'}{'Description'};
										my $act_fname = $actor->{'FirstName'};
										my $act_lname = $actor->{'LastName'};
										
										if( defined $act_lname ) {
											if( defined $act_fname) {
												print "    <actor>" . $act_fname . " " . $act_lname . "</actor>\n";
											} else {
												print "    <actor>" . $act_lname . "</actor>\n";
											}
										} elsif( defined $act_fname ) {
											print "    <actor>" . $act_fname . "</actor>\n";
										}
									}
								}
								
								print "  </credits>\n";
								last;
							} elsif( $cast_id->{'Role'} eq "Director" ) {
								print "  <credits>\n";
								
								foreach my $relations ( @relations ) {
									my $role = $relations->{'Role'};
									
									if( $role eq "Director" ) {
										my $director  = $relations->{'TargetNode'}{'Content'}{'Description'};
										my $dir_fname = $director->{'FirstName'};
										my $dir_lname = $director->{'LastName'};
										
										if( defined $dir_lname ) {
											if( defined $dir_fname) {
												print "    <director>" . $dir_fname . " " . $dir_lname . "</director>\n";
											} else {
												print "    <director>" . $dir_lname . "</director>\n";
											}
										} elsif( defined $dir_fname ) {
											print "    <director>" . $dir_fname . "</director>\n";
										}
									}
									
									if( $role eq "Actor" ) {
										my $actor     = $relations->{'TargetNode'}{'Content'}{'Description'};
										my $act_fname = $actor->{'FirstName'};
										my $act_lname = $actor->{'LastName'};
										
										if( defined $act_lname ) {
											if( defined $act_fname) {
												print "    <actor>" . $act_fname . " " . $act_lname . "</actor>\n";
											} else {
												print "    <actor>" . $act_lname . "</actor>\n";
											}
										} elsif( defined $act_fname ) {
											print "    <actor>" . $act_fname . "</actor>\n";
										}
									}
								}
								
								print "  </credits>\n";
								last;
							}
						}
										
						
					}
				
				
					#
					# DATE
					#
					
					my $date = $contentdesc->{'ReleaseDate'};
					
					if( defined $date ) {
						$date =~ s/-.*//g;
						print "  <date>" . $date . "</date>\n";
					}
				
				
					#
					# COUNTRY
					#
					
					my $country = $contentdesc->{'Country'};
					
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
				
				
					#
					# CATEGORY
					#
					
					if ( @relations ) {
						
						# DEFINE CATEGORY PARAMETERS
						my $genretype    = "Genre";
						my $genre_location;
					
						while( my( $genre_id, $genre ) = each( @relations ) ) {		# SEARCH FOR CATEGORY
							if( $genre->{'Kind'} eq $genretype ) {
								$genre_location = $genre_id;
								last;
							}
						}
						if( defined $genre_location) {
							if ( $setup_genre eq $enabled ) {
								if ( defined $eit->{ $broadcastitems->{'Relations'}[$genre_location]{'TargetIdentifier'} } ) {
									print "  <category lang=\"" . $languageVER . "\">" . $eit->{ $broadcastitems->{'Relations'}[$genre_location]{'TargetIdentifier'} } . "</category>\n";
								} else {
									print "  <category lang=\"" . $languageVER . "\">" . $broadcastitems->{'Relations'}[$genre_location]{'TargetIdentifier'} . "</category>\n";
									print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . "$broadcastitems->{'Relations'}[$genre_location]{'TargetIdentifier'}" . "\n";
								}
							}
						}
					}
				
				
					#
					# SEASON + EPISODE
					#
				
					my $series       = $contents->{'Series'};
					
					my $seasonno     = $series->{'Season'};
					my $episodeno    = $series->{'Episode'};
					
					# ONSCREEN
					if( $setup_episode eq $onscreen ) {
						if( defined $seasonno ) {
							if( defined $episodeno ) {
								print "  <episode-num system=\"onscreen\">" . "S" . $seasonno . " E" . $episodeno . "</episode-num>\n";
							} else {
								print "  <episode-num system=\"onscreen\">" . "S" . $seasonno . "</episode-num>\n";
							}
						} elsif( defined $episodeno ) {
							print "  <episode-num system=\"onscreen\">" . "E" . $episodeno . "</episode-num>\n";
						}
					
					# XMLTV_NS
					} elsif( $setup_episode eq $xmltv_ns ) {
						if( defined $seasonno ) {
							my $XMLseason  = $seasonno - 1;
							if( defined $episodeno ) {
								my $XMLepisode  = $episodeno - 1;
								print "  <episode-num system=\"xmltv_ns\">" . $XMLseason . " . " . $XMLepisode . " . </episode-num>\n";
							} else {
								print "  <episode-num system=\"xmltv_ns\">" . $XMLseason . " . 0 . </episode-num>\n";
							}
						} elsif( defined $episodeno ) {
							my $XMLepisode  = $episodeno - 1;
							print "  <episode-num system=\"xmltv_ns\">0 . " . $XMLepisode . " . </episode-num>\n";
						}
					}
				
				
					#
					# AGE RATING
					#
					
					my $age = $contentdesc->{'AgeRestrictionRating'};
					
					if( defined $age ) {
						$age =~ s/\+//g;
						print "  <rating>\n    <value>" . $age . "</value>\n  </rating>\n";
					}
				
				
					#
					# STAR RATING
					#
					
					my $star        = $contentdesc->{'Rating'};
					
					if( defined $star ) {
						my $star_rating = $star/10;
						print "  <star-rating>\n    <value>" . $star_rating . "/10</value>\n  </star-rating>\n";
					}
				}
			
			print "</programme>\n";
			
		}
		}
	}
}
