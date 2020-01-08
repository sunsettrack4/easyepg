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

# DEFINE XML/JSON PARSER
use XML::Rules;
use JSON;

# DEFINE XML RULES
my @rules = (
			'display-name' => 'as is',
			'icon' => 'as is',
			'channel' => 'as array no content'
			);

# CONVERT XML/JSON TO PERL STRUCTURES
my $parser = XML::Rules->new(rules => \@rules );
my $ref = $parser->parse( $xml);
my $init = decode_json($json);

# DEFINE VALUES
my $tv        = $ref->{tv};
my @channel   = @{ $tv->{channel} };

# DEFINE SELECTED CHANNELS
my @configdata = @{ $init->{'channels'} };


# ####################
# PRINT CHANNEL LIST #
# ####################

foreach my $configdata ( @configdata ) {
	foreach my $channel ( @channel ) {
		
		# ###################
		# DEFINE XML VALUES #
		# ###################
		
		# DEFINE CHANNEL STRINGS
		my $channel_id = $channel->{id};
		my $ch_logo    = $channel->{'icon'}->{'src'};
		my $ch_lang    = $channel->{'display-name'}->{lang};
		my $ch_name    = $channel->{'display-name'}->{_content};
		
		# ##################
		# PRINT XML VALUES #
		# ##################
		
		if( $channel_id eq $configdata ) {
		
			# CHANNEL ID + NAME + LOGO (condition)
			print "<channel id=\"" . $channel_id . "\">\n";
			print "  <display-name lang=\"" . $ch_lang . "\">" . $ch_name . "<\/display-name>\n";
			
			if( defined $ch_logo ) {
				print "  <icon src=\"$ch_logo\" />\n</channel>\n";
			} else {
				print "</channel>\n";
			}
		}
	}
}
