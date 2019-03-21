#!/usr/bin/perl

#      Copyright (C) 2019 Jan-Luca Neumann
#      https://github.com/sunsettrack4/easyepg/hzn
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

# DEFINE XML PARSER
use XML::Rules;
use JSON;

# DEFINE XML RULES
my @rules = (
			'actor,director' => 'content array',
			'date,value' => 'content',
			'desc,display-name,episode-num,sub-title,title' => 'as is',
			'credits,icon,poster,rating,star-rating,tv' => 'no content',
			'category' => 'as array',
			'programme' => 'as array no content'
			);

# CONVERT XML/JSON TO PERL STRUCTURES
my $parser = XML::Rules->new(rules => \@rules );
my $ref = $parser->parse( $xml);
my $init = decode_json($json);

# DEFINE VALUES
my $tv = $ref->{tv};
my @programme = @{ $tv->{programme} };

# DEFINE SELECTED CHANNELS
my @configdata = @{ $init->{'channels'} };


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
			if( defined $title_lang ) {
				print "  <title lang=\"" . $title_lang . "\">" . $title . "</title>\n";
			} else {
				print "  <title>" . $title . "</title>\n";
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
			
			# CATEGORY
			my $category    = $programme->{category};
			if( defined $category ) {
				my @category = @{ $programme->{category} };
				foreach my $category_string ( @category ) {
					my $category_content = $category_string->{_content};
					my $category_lang    = $category_string->{lang};
					if( defined $category_lang ) {
						print "  <category lang=\"" . $category_lang . "\">" . $category_content . "</category>\n";
					} else {
						print "  <category>" . $category_content . "</category>\n";
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
