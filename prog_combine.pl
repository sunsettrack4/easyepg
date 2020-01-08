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

use strict;
use warnings;

binmode STDOUT, ":utf8";
binmode STDERR, ":utf8";
use utf8;

# READ XML INPUT FILE
my $xml;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "xml/fileNAME" or die;
    $xml = <$fh>;
    close $fh;
}

# READ JSON CONFIG FILE
my $json;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "combine/channelsFILE" or die;
    $json = <$fh>;
    close $fh;
}

# READ SETTINGS JSON FILE
my $settings;
{
    local $/; #Enable 'slurp' mode
    open my $fh, "<", "combine/settingsFILE" or die;
    $settings = <$fh>;
    close $fh;
}

# DEFINE XML/JSON PARSER + TIME VALUES
use XML::Rules;
use JSON;
use Time::Piece;
use Time::Seconds;

# DEFINE XML RULES
my @rules = (
			'actor,director' => 'content array',
			'date,country,value' => 'content',
			'desc,episode-num,sub-title,title' => 'as is',
			'credits,icon,poster,rating,star-rating,tv' => 'no content',
			'category' => 'as array',
			'programme' => 'as array no content'
			);

# CONVERT XML/JSON TO PERL STRUCTURES
my $parser = XML::Rules->new(rules => \@rules );
my $ref = $parser->parse( $xml);
my $init = decode_json($json);
my $setup = decode_json($settings);

# DEFINE VALUES
my $tv = $ref->{tv};
my @programme = @{ $tv->{programme} };

# DEFINE SELECTED CHANNELS
my @configdata = @{ $init->{'channels'} };

# DEFINE SELECTED DAYS
my $days = $setup->{'day'};

# SET DATE VALUES
my $time1   = Time::Piece->new;
my $time2   = $time1 + 86400;
my $time3   = $time1 + 172800;
my $time4   = $time1 + 259200;
my $time5   = $time1 + 345600;
my $time6   = $time1 + 432000;
my $time7   = $time1 + 518400;
my $time8   = $time1 + 604800;
my $time9   = $time1 + 691200;
my $time_10 = $time1 + 777600;
my $time_11 = $time1 + 864000;
my $time_12 = $time1 + 950400;
my $time_13 = $time1 + 1036800;
my $time_14 = $time1 + 1123200;
my $time_15 = $time1 + 1209600;

my $date1   = $time1->strftime('%Y%m%d');
my $date2   = $time2->strftime('%Y%m%d');
my $date3   = $time3->strftime('%Y%m%d');
my $date4   = $time4->strftime('%Y%m%d');
my $date5   = $time5->strftime('%Y%m%d');
my $date6   = $time6->strftime('%Y%m%d');
my $date7   = $time7->strftime('%Y%m%d');
my $date8   = $time8->strftime('%Y%m%d');
my $date9   = $time9->strftime('%Y%m%d');
my $date_10 = $time_10->strftime('%Y%m%d');
my $date_11 = $time_11->strftime('%Y%m%d');
my $date_12 = $time_12->strftime('%Y%m%d');
my $date_13 = $time_13->strftime('%Y%m%d');
my $date_14 = $time_14->strftime('%Y%m%d');
my $date_15 = $time_15->strftime('%Y%m%d');


# ######################
# PRINT PROGRAMME LIST #
# ######################

foreach my $configdata ( @configdata ) {
	foreach my $programme ( @programme ) {
			
		# ###########################
		# DEFINE + PRINT XML VALUES #
		# ###########################
				
		# PROGRAMME STRING
		my $start       = $programme->{start};
		my $stop        = $programme->{stop};
		my $ch          = $programme->{channel};
		
		# CONDITION: PRINT SELECTED CHANNELS ONLY
		if( $ch eq $configdata ) {
			
			#
			# DAY 1
			#
			
			if( $days eq "1" or $days eq "2" or $days eq "3" or $days eq "4" or $days eq "5" or $days eq "6" or $days eq "7" or $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
				
				if( defined $start and $start =~ m/$date1/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 2
			#
			
			if( $days eq "2" or $days eq "3" or $days eq "4" or $days eq "5" or $days eq "6" or $days eq "7" or $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date2/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 3
			#
			
			if( $days eq "3" or $days eq "4" or $days eq "5" or $days eq "6" or $days eq "7" or $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date3/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 4
			#
			
			if( $days eq "4" or $days eq "5" or $days eq "6" or $days eq "7" or $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date4/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 5
			#
			
			if( $days eq "5" or $days eq "6" or $days eq "7" or $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date5/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 6
			#
			
			if( $days eq "6" or $days eq "7" or $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date6/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 7
			#
			
			if( $days eq "7" or $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date7/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 8
			#
			
			if( $days eq "8" or $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date8/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 9
			#
			
			if( $days eq "9" or $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date9/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}	
		
			#
			# DAY 10
			#
			
			if( $days eq "10" or $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date_10/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 11
			#
			
			if( $days eq "11" or $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date_11/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
			
			#
			# DAY 12
			#
			
			if( $days eq "12" or $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date_12/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 13
			#
			
			if( $days eq "13" ) {
			
				if( defined $start and $start =~ m/$date_13/ ) {
				
					# START + STOP + CHANNEL
					print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
					
					# ICON
					my $icon        = $programme->{icon}->{src};
					if( defined $icon ) {
						print "  <icon src=\"" . $icon . "\" />\n";
					}
					
					# TITLE
					my $title       = $programme->{title}->{_content};
					my $title_lang  = $programme->{title}->{lang};
					if( defined $title ) {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
						} else {
							print "  <title>" . $title . "</title>\n";
						}
					} else {
						if( defined $title_lang ) {
							print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
						} else {
							print "  <title>No program information available</title>\n";
						}
					}
					
					# SUB-TITLE
					my $subtitle    = $programme->{'sub-title'}->{_content};
					my $sub_lang    = $programme->{'sub-title'}->{lang};
					if( defined $subtitle ) {
						if( defined $sub_lang ) {
							print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
						} else {
							print "  <sub-title>" . $subtitle . "</sub-title>\n";
						}
					}
					
					# DESC
					my $desc        = $programme->{desc}->{_content};
					my $desc_lang   = $programme->{desc}->{lang};
					if( defined $desc ) {
						if( defined $desc_lang ) {
							print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
						} else {
							print "  <desc>" . $desc . "</desc>\n";
						}
					}
					
					# CREDITS
					my $credits     = $programme->{credits};
					if( defined $credits ) {
						print "  <credits>\n";
						
						# DIRECTOR
						if( exists $credits->{director}) {
							my @director       = @{ $credits->{director} };
							foreach my $director ( @director ) {
								print "    <director>" . $director . "</director>\n";
							}
						}
						
						# ACTOR
						if( exists $credits->{actor}) {
							my @actor       = @{ $credits->{actor} };
							foreach my $actor ( @actor ) {
								print "    <actor>" . $actor . "</actor>\n";
							}
						}
						
						print "  </credits>\n";
					}
					
					# DATE
					my $date        = $programme->{date};
					if( defined $date ) {
						print "  <date>" . $date . "</date>\n";
					}
					
					# COUNTRY
					my $country     = $programme->{country};
					if( defined $country ) {
						print "  <country>" . $country . "</country>\n";
					}
					
					# CATEGORY
					my $category    = $programme->{category};
					if( defined $category ) {
						my @category = @{ $programme->{category} };
						foreach my $category_string ( @category ) {
							my $category_content = $category_string->{_content};
							my $category_lang    = $category_string->{lang};
							if( defined $category_content ) {
								if( defined $category_lang ) {
									print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
								} else {
									print "  <category>" . $category_content . "</category>\n";
								}
							}
						}
					}
					
					# EPISODE
					my $episode     = $programme->{'episode-num'}->{_content};
					my $episystem   = $programme->{'episode-num'}->{system};
					if( defined $episode ) {
						if( defined $episystem ) {
							print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
						}
					}
					
					# AGE RATING
					my $agerating   = $programme->{rating}->{value};
					my $agesystem   = $programme->{rating}->{system};
					if( defined $agerating ) {
						if( defined $agesystem ) {
							print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
						} else {
							print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
						}
					}
					
					# STAR RATING
					my $starrating  = $programme->{'star-rating'}->{value};
					my $starsystem  = $programme->{'star-rating'}->{system};
					if( defined $starrating ) {
						if( defined $starsystem ) {
							print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						} else {
							print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
						}
					}
					
					# END OF PROGRAMME
					print "</programme>\n";
				}
			}
		
			#
			# DAY 14 (ALL DAYS)
			#
			
			if( $days eq "14" ) {
			
				# START + STOP + CHANNEL
				print "<programme start=\"" . $start . "\" stop=\"" . $stop . "\" channel=\"" . $ch . "\">\n";
				
				# ICON
				my $icon        = $programme->{icon}->{src};
				if( defined $icon ) {
					print "  <icon src=\"" . $icon . "\" />\n";
				}
				
				# TITLE
				my $title       = $programme->{title}->{_content};
				my $title_lang  = $programme->{title}->{lang};
				if( defined $title ) {
					if( defined $title_lang ) {
						print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
					} else {
						print "  <title>" . $title . "</title>\n";
					}
				} else {
					if( defined $title_lang ) {
						print "  <title lang=\"" . $title_lang . "\">No program information available</title>\n";
					} else {
						print "  <title>No program information available</title>\n";
					}
				}
				
				# SUB-TITLE
				my $subtitle    = $programme->{'sub-title'}->{_content};
				my $sub_lang    = $programme->{'sub-title'}->{lang};
				if( defined $subtitle ) {
					if( defined $sub_lang ) {
						print "  <sub-title lang=\"" . $sub_lang . "\">" . $subtitle . "</sub-title>\n";
					} else {
						print "  <sub-title>" . $subtitle . "</sub-title>\n";
					}
				}
				
				# DESC
				my $desc        = $programme->{desc}->{_content};
				my $desc_lang   = $programme->{desc}->{lang};
				if( defined $desc ) {
					if( defined $desc_lang ) {
						print "  <desc lang=\"" . $desc_lang . "\">" . $desc . "</desc>\n";
					} else {
						print "  <desc>" . $desc . "</desc>\n";
					}
				}
				
				# CREDITS
				my $credits     = $programme->{credits};
				if( defined $credits ) {
					print "  <credits>\n";
					
					# DIRECTOR
					if( exists $credits->{director}) {
						my @director       = @{ $credits->{director} };
						foreach my $director ( @director ) {
							print "    <director>" . $director . "</director>\n";
						}
					}
					
					# ACTOR
					if( exists $credits->{actor}) {
						my @actor       = @{ $credits->{actor} };
						foreach my $actor ( @actor ) {
							print "    <actor>" . $actor . "</actor>\n";
						}
					}
					
					print "  </credits>\n";
				}
				
				# DATE
				my $date        = $programme->{date};
				if( defined $date ) {
					print "  <date>" . $date . "</date>\n";
				}
				
				# COUNTRY
				my $country     = $programme->{country};
				if( defined $country ) {
					print "  <country>" . $country . "</country>\n";
				}
				
				# CATEGORY
				my $category    = $programme->{category};
				if( defined $category ) {
					my @category = @{ $programme->{category} };
					foreach my $category_string ( @category ) {
						my $category_content = $category_string->{_content};
						my $category_lang    = $category_string->{lang};
						if( defined $category_content ) {
							if( defined $category_lang ) {
								print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
							} else {
								print "  <category>" . $category_content . "</category>\n";
							}
						}
					}
				}
				
				# EPISODE
				my $episode     = $programme->{'episode-num'}->{_content};
				my $episystem   = $programme->{'episode-num'}->{system};
				if( defined $episode ) {
					if( defined $episystem ) {
						print "  <episode-num system=\"" . $episystem . "\">" . $episode . "</episode-num>\n";
					}
				}
				
				# AGE RATING
				my $agerating   = $programme->{rating}->{value};
				my $agesystem   = $programme->{rating}->{system};
				if( defined $agerating ) {
					if( defined $agesystem ) {
						print "  <rating system=\"" . $agesystem . "\">\n    <value>" . $agerating . "</value>\n  </rating>\n";
					} else {
						print "  <rating>\n    <value>" . $agerating . "</value>\n  </rating>\n";
					}
				}
				
				# STAR RATING
				my $starrating  = $programme->{'star-rating'}->{value};
				my $starsystem  = $programme->{'star-rating'}->{system};
				if( defined $starrating ) {
					if( defined $starsystem ) {
						print "  <star-rating system=\"" . $starsystem . "\">\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
					} else {
						print "  <star-rating>\n    <value>" . $starrating . "</value>\n  </star-rating>\n";
					}
				}
				
				# END OF PROGRAMME
				print "</programme>\n";
			}
		
		}
	}
}
