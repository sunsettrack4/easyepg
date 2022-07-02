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

# ###############################
# SWISSCOM JSON > XML CONVERTER #
# ###############################

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

# READ JSON INPUT FILE: SWISSCOM NUMERIC CHANNEL IDs
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
        
        
        # ########################
        # DEFINE PROGRAM STRINGS #
        # ########################
        
        my $channelnodes = $item->{'Nodes'};
        my @channelitems = @{ $channelnodes->{'Items'} };
        
        foreach my $channelitems ( @channelitems ) {
			my $channelcontents = $channelitems->{'Content'};
			
			my $broadcastnodes = $channelcontents->{'Nodes'};
			my @broadcastitems = @{ $broadcastnodes->{'Items'} };
			
			foreach my $broadcastitems ( @broadcastitems ) {
				
				# DEFINE CHANNEL ID
				my $cid          = $broadcastitems->{'Channel'};
				
				my @availability = @{ $broadcastitems->{'Availabilities'} };
			
				foreach my $availability ( @availability ) {
					
					# DEFINE ROUTES
					my $contents     = $broadcastitems->{'Content'};
					my $contentnodes = $contents->{'Nodes'};
					my $contentdesc  = $contents->{'Description'};
					my @relations    = @{ $broadcastitems->{'Relations'} };
					
					# DEFINE TIMES
					my $start = $availability->{'AvailabilityStart'};
					my $stop  = $availability->{'AvailabilityEnd'};
					
					# CONVERT FROM TIMESTAMP TO XMLTV DATE FORMAT
					$start =~ s/[-:TZ]//g;
					$stop  =~ s/[-:TZ]//g;
					
					# DEFINE PROGRAM STRINGS
					my $title     = $contentdesc->{'Title'};
					my $subtitle  = $contentdesc->{'Subtitle'};
					my $desc      = $contentdesc->{'Summary'};
					my $date      = $contentdesc->{'ReleaseDate'};
					my $country   = $contentdesc->{'Country'};
					my $series    = $contents->{'Series'};
					my $seasonno  = $series->{'Season'};
					my $episodeno = $series->{'Episode'};
					my $age       = $contentdesc->{'AgeRestrictionRating'};
					my $star      = $contentdesc->{'Rating'};
					
					# DEFINE LANGUAGE VERSION
					my $languageVER = $contentdesc->{'Language'};
					
					# DEFINE IMAGE PARAMETERS
					my $imagetype    = "Image";
					my $image_location;
					
					
					# ##################
					# PRINT XML OUTPUT #
					# ##################
					
					# PRINT PROGRAMME STRING ONLY IF CERTAIN VALUES ARE DEFINED
					if( defined $title and defined $start and defined $stop and defined $cid ) {
					
						foreach my $selected_channel ( @configdata ) {
							# BEGIN OF PROGRAMME: START / STOP / CHANNEL (condition) (settings)
							if( $cidEXTnew->{$cid} eq $selected_channel ) {
								if( $setup_cid eq $enabled ) {
									if( defined $rytec->{$cidEXTnew->{$cid}} ) {
										print "<programme start=\"$start\" stop=\"$stop\" channel=\"" . $rytec->{$cidEXTnew->{$cid}} . "\">\n";
									} else {
										print "<programme start=\"$start\" stop=\"$stop\" channel=\"" . $cidEXTnew->{$cid} . "\">\n";
										print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXTnew->{$cid} . "\n";
									}
								} else {
									print "<programme start=\"$start\" stop=\"$stop\" channel=\"" . $cidEXTnew->{$cid} . "\">\n";
								}
							} elsif( defined $cidEXTold->{$cid} and not defined $cname_old->{$cidEXTnew->{$cid}} ) {
								if( $cidEXTold->{$cid} eq $selected_channel ) {
									if( $setup_cid eq $enabled ) {
										if( defined $rytec->{$cidEXTold->{$cid}} ) {
											print "<programme start=\"$start\" stop=\"$stop\" channel=\"" . $rytec->{$cidEXTold->{$cid}} . "\">\n";
										} else {
											print "<programme start=\"$start\" stop=\"$stop\" channel=\"" . $cidEXTold->{$cid} . "\">\n";
											print STDERR "[ EPG WARNING ] Rytec ID not matched for: " . $cidEXTold->{$cid} . "\n";
										}
									} else {
										print "<programme start=\"$start\" stop=\"$stop\" channel=\"" . $cidEXTold->{$cid} . "\">\n";
									}
								}
							}
						}
				
						# IMAGE (condition) (loop)
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
									print "  <icon src=\"https://services.sg101.prd.sctv.ch/content/images" . $contentnodes->{'Items'}[$image_location]{'ContentPath'} . "_w1920.webp\" />\n";
								}
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
							print "  <sub-title lang=\"" . $languageVER . "\">" . $subtitle . "</sub-title>\n";
						}
							
						# DESCRIPTION (condition) (language)
						if( defined $desc ) {
							$desc =~ s/\&/\&amp;/g;					# REQUIRED TO READ XML FILE CORRECTLY
							$desc =~ s/<[^>]*>//g;					# REMOVE XML STRINGS WITHIN JSON VALUE
							$desc =~ s/[<>]//g;
							print "  <desc lang=\"" . $languageVER . "\">" . $desc . "</desc>\n";
						}
					
						# CREDITS (condition)
						if ( @relations ) {
							
							while( my( $cast, $cast_id ) = each( @relations ) ) {
								if( $cast_id->{'Role'} eq "Actor" ) {
									print "  <credits>\n";
									
									foreach my $relations ( @relations ) {
										my $role = $relations->{'Role'};
										
										if( defined $role and $role eq "Director" ) {
											my $director  = $relations->{'TargetNode'}{'Content'}{'Description'};
											my $dir_fname = $director->{'FirstName'};
											my $dir_lname = $director->{'LastName'};
											
											if( defined $dir_lname ) {
												$dir_lname =~ s/\&/\&amp;/g;
												if( defined $dir_fname) {
													$dir_fname =~ s/\&/\&amp;/g;
													print "    <director>" . $dir_fname . " " . $dir_lname . "</director>\n";
												} else {
													print "    <director>" . $dir_lname . "</director>\n";
												}
											} elsif( defined $dir_fname ) {
												$dir_fname =~ s/\&/\&amp;/g;
												print "    <director>" . $dir_fname . "</director>\n";
											}
										}
										
										if( defined $role and $role eq "Actor" ) {
											my $actor     = $relations->{'TargetNode'}{'Content'}{'Description'};
											my $act_fname = $actor->{'FirstName'};
											my $act_lname = $actor->{'LastName'};
											
											if( defined $act_lname ) {
												$act_lname =~ s/\&/\&amp;/g;
												if( defined $act_fname) {
													$act_fname =~ s/\&/\&amp;/g;
													print "    <actor>" . $act_fname . " " . $act_lname . "</actor>\n";
												} else {
													print "    <actor>" . $act_lname . "</actor>\n";
												}
											} elsif( defined $act_fname ) {
												$act_fname =~ s/\&/\&amp;/g;
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
										
										if( defined $role and $role eq "Director" ) {
											my $director  = $relations->{'TargetNode'}{'Content'}{'Description'};
											my $dir_fname = $director->{'FirstName'};
											my $dir_lname = $director->{'LastName'};
											
											if( defined $dir_lname ) {
												$dir_lname =~ s/\&/\&amp;/g;
												if( defined $dir_fname) {
													$dir_fname =~ s/\&/\&amp;/g;
													print "    <director>" . $dir_fname . " " . $dir_lname . "</director>\n";
												} else {
													print "    <director>" . $dir_lname . "</director>\n";
												}
											} elsif( defined $dir_fname ) {
												$dir_fname =~ s/\&/\&amp;/g;
												print "    <director>" . $dir_fname . "</director>\n";
											}
										}
										
										if( defined $role and $role eq "Actor" ) {
											my $actor     = $relations->{'TargetNode'}{'Content'}{'Description'};
											my $act_fname = $actor->{'FirstName'};
											my $act_lname = $actor->{'LastName'};
											
											if( defined $act_lname ) {
												$act_lname =~ s/\&/\&amp;/g;
												if( defined $act_fname) {
													$act_fname =~ s/\&/\&amp;/g;
													print "    <actor>" . $act_fname . " " . $act_lname . "</actor>\n";
												} else {
													print "    <actor>" . $act_lname . "</actor>\n";
												}
											} elsif( defined $act_fname ) {
												$act_fname =~ s/\&/\&amp;/g;
												print "    <actor>" . $act_fname . "</actor>\n";
											}
										}
									}
									
									print "  </credits>\n";
									last;
								}
							}
											
							
						}
					
						# DATE (condition)
						if( defined $date ) {
							$date =~ s/-.*//g;
							print "  <date>" . $date . "</date>\n";
						}
									
						# COUNTRY (condition)
						if( defined $country ) {
							print "  <country>" . $country . "</country>\n";
						}
									
						# CATEGORIES (USE ONE CATEGORY ONLY) (condition) (language) (settings)
						if ( @relations ) {
						
							foreach my $relations ( @relations ) {
								my $role = $relations->{'Role'};
								
								if( defined $role and $role eq "Genre" ) {
									if ( defined $eit->{ $relations->{'TargetIdentifier'} } ) {
										print "  <category lang=\"" . $languageVER . "\">" . $eit->{ $relations->{'TargetIdentifier'} } . "</category>\n";
									} else {
										print "  <category lang=\"" . $languageVER . "\">" . $relations->{'TargetIdentifier'} . "</category>\n";
										print STDERR "[ EPG WARNING ] CATEGORY UNAVAILABLE IN EIT LIST: " . $relations->{'TargetIdentifier'} . "\n";
									}
								}
							}
						}
					
						# SEASON/EPISODE (ONSCREEN) (condition) (settings)
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
						
						# SEASON/EPISODE (XMLTV_NS) (condition) (settings)
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
					
						# AGE RATING (condition)
						if( defined $age ) {
							$age =~ s/\+//g;
							print "  <rating>\n    <value>" . $age . "</value>\n  </rating>\n";
						}
					
						# STAR RATING (condition)
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
}
