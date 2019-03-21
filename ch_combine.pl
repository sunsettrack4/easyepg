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
use XML::Bare;
use JSON;

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

# DEFINE PARSER
my $parser = new XML::Bare( text => $xml );

# CONVERT XML/JSON TO PERL STRUCTURES
my $root = $parser->parse();
my $init = decode_json($json);

# DEFINE VALUES
my $tv        = $root->{tv};
my @channel   = @{ $tv->{channel} };
my @programme = @{ $tv->{programme} };

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
		my $channel_id = $channel->{id}->{value};
		my $ch_lang    = $channel->{'display-name'}->{lang}->{value};
		my $ch_name    = $channel->{'display-name'}->{value};
		
		# ##################
		# PRINT XML VALUES #
		# ##################
		
		if( $channel_id eq $configdata ) {
		
			# CHANNEL ID + NAME
			print "<channel id=\"" . $channel_id . "\">\n";
			print "  <display-name lang=\"" . $ch_lang . "\">" . $ch_name . "<\/display-name>\n<\/channel>\n";
		}
	}
}
