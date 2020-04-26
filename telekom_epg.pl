#!/usr/bin/perl

#      Copyright (C) 2019-2020 Jan-Luca Neumann
#      https://github.com/sunsettrack4/easyepg/
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

# ################################
# EASYEPG TELEKOM GRABBER MODULE #
# ################################

# PERL MODULES
use strict;
use warnings;

use utf8;
use Encode;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::Escape;
use HTTP::Status;
use HTTP::Request::Params;
use HTTP::Request::Common;
use HTTP::Cookies;
use HTTP::Headers;
use HTML::TreeBuilder;
use UI::Dialog;
use Parallel::ForkManager;
use Time::Piece;
use JSON;
use XML::Writer;
use IO::File;
use POSIX;

# SET VALUES
my $firstlogin;

# BUILD MENU
my $d = new UI::Dialog ( order => [ 'dialog', 'ascii' ] );


#
# ASK USER
#

# Check if user wants to enter the menu. This check will be skipped if user logged in for the first time.

# SET SELECTION VALUE FOR MAIN MENU
my $selection;

if( -e "channels.json" and -e "chconfig.json" ) {
	
	# ASK DATA
	my $answer = ask_data();
	
	if( $answer ne "No answer" ) {
		
		# ANSWER RECEIVED: ENTER MENU
		$selection = "X";
		
	} else {
		
		# NO ANSWER = CONTINUE WITHOUT MENU
		$selection = "7";
		
	}
	
} else {
	
	# FIRST LOGIN = ENTER MENU
	$selection = "X";
	
}

sub ask_data {
	
	#
	# [SUB] ASK USER
	#

	# ENTER SETTINGS AFTER KEYBOARD INPUT OR IN INITIAL SETUP
	
	my $answer;
 
	print "\nPlease hit ENTER button within 5 seconds to open the settings... \n\n";

	eval {
		local $SIG{ALRM} = sub { die "OK!\n" };
		alarm 5;
		$answer = <STDIN>;
		alarm 0;
		chomp $answer;
	};

	if ($@) {
		die $@ if $@ ne "OK!\n";
		$answer = "No answer";
	}

	return $answer;

}


#
# AUTH PROCESS: RETRIEVE COOKIE DATA
#

# Get session cookie required for all upcoming URL requests of this provider.

# USE CREDENTIALS TO LOGIN TO WEBSERVICE, RETURN SESSION DATA
my $session;

# START LOGIN PROCESS, EVALUATE STATUS
eval{
    $session = login_process();
};

# IF LOGIN PROCESS DIED, EXIT SCRIPT
if( not defined $session ) {
	die "[E] Exiting script due to error in login process.\n";
}

# RETRIEVE SESSION CONFIGRUATION FOR UPCOMING PROCESSES
my $j_token = $session->{j_token};
my $c_token = $session->{c_token};
my $csrf_token = $session->{csrf_token};


sub login_process {

	#
	# [SUB] LOGIN PROCESS
	#
	
	# SET VALUES TO BE DEFINED IN OUR LOGIN PROCESS
	my $login_success = "-";
	my $login_token;
	
	# LOGIN TO WEBSERVICE UNTIL RESULT IS SUCCESSFUL
	until( $login_success eq "true" ) {
		
		# LOGIN URL
		my $login_url = "https://web.magentatv.de/EPG/JSON/Login?&T=PC_firefox_72";
		
		my $login_agent    = LWP::UserAgent->new(
			agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0",
		);
		
		# FORM DATA
		my $login_data = '{"userId":"Guest","mac":"00:00:00:00:00:00"}';
		
		# REQUEST
		my $login_request  = HTTP::Request::Common::POST( $login_url, Content => $login_data );
		my $login_response = $login_agent->request($login_request);
		
		if( $login_response->is_error ) {
			die "[E] UNABLE TO LOGIN WEBSERVICE! (no internet connection / service unavailable)\n\nRESPONSE:\n\n" . $login_response->content . "\n";
		}
		
		# GET JSESSION ID FOR THE 1ST TIME
		my $pre_j_token    = $login_response->header('Set-cookie');
		
		if( defined $pre_j_token ) {
			$pre_j_token       =~ s/(.*)(JSESSIONID=)(.*)(; Path=.*)/$3/g;
		} else {
			die "[E] UNABLE TO LOGIN TO WEBSERVICE! (unable to retrieve 1st JSESSION ID)\n";
		}
		
		# SAVE JSESSION ID COOKIE
		my $cookie_jar    = HTTP::Cookies->new;
		$cookie_jar->set_cookie(0,'JSESSIONID',$pre_j_token,'/EPG/','web.magentatv.de',443);
		
		# AUTH URL
		my $auth_url = "https://web.magentatv.de/EPG/JSON/Authenticate?SID=firstup&T=PC_firefox_72";
		
		my $auth_agent    = LWP::UserAgent->new(
			agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0",
		);
		
		# SET COOKIES
		$auth_agent->cookie_jar($cookie_jar);
		
		# FORM DATA
		my $auth_data = '{"terminalid":"00:00:00:00:00:00","mac":"00:00:00:00:00:00","terminaltype":"MACWEBTV","utcEnable":1,"timezone":"UTC","userType":3,"terminalvendor":"Unknown","preSharedKeyID":"PC01P00002","cnonce":"a01e0e9cbb670e8f850b16b69ed8ae3d","areaid":"1","templatename":"default","usergroup":"-1","subnetId":"4901"}';
		
		# REQUEST
		my $auth_request  = HTTP::Request::Common::POST($auth_url, Content => $auth_data );
		my $auth_response = $auth_agent->request($auth_request);

		if( $auth_response->is_error ) {
			die "[E] UNABLE TO GET WEBSERVICE AUTHORIZATION! (service unavailable)\n\nRESPONSE:\n\n" . $auth_response->content . "\n";
		}
		
		# EXTRACT COOKIES: JSESSIONID, CSESSIONID / EXTRACT DATA: CSRFTOKEN
		my @cookies = @{ $cookie_jar->extract_cookies($auth_response)->{_headers}->{"set-cookie"} };
		
		if( @cookies ) {
			
			foreach my $cookie ( @cookies ) {
				
				if( $cookie =~ /(JSESSIONID=)(.*)(; Path=\/EPG\/)/ ) {
					
					$cookie =~ s/(JSESSIONID=)(.*)(; Path=\/EPG\/.*)/$2/g;
					
					if( not defined $2 ) {
						die "[E] UNABLE TO GET WEBSERVICE AUTHORIZATION! (unable to retrieve JSESSIONID)\n";
					}
					
					$j_token = $2;
					
				} elsif( $cookie =~ /(CSESSIONID=)(.*)(; Path=\/EPG\/)/ ) {
					
					$cookie =~ s/(CSESSIONID=)(.*)(; Path=\/EPG\/.*)/$2/g;
					
					if( not defined $2 ) {
						die "[E] UNABLE TO GET WEBSERVICE AUTHORIZATION! (unable to retrieve CSESSIONID)\n";
					}
					
					$c_token = $2;
				}
				
			}
			
		} else {
			
			die "[E] UNABLE TO GET WEBSERVICE AUTHORIZATION! (cookies unavailable)\n";
			
		}
		
		my $auth_file;
		
		eval{
			$auth_file = decode_json( $auth_response->content );
		};
		
		if( not defined $auth_file ) {
			die "[E] Failed to parse JSON file: Auth\n";
		}
		
		if( not defined $auth_file->{csrfToken} ) {
			die "[E] Unable to retrieve csrfToken\n";
		}

		print "[I] LOGIN TO WEBSERVICE OK!\n";
		$login_success = "true";
		$csrf_token = $auth_file->{csrfToken};

	}	
	
	# RETURN UPDATED CREDENTIALS AND SESSION CONFIGURATIONS
	$session = { j_token => $j_token, c_token => $c_token, csrf_token => $csrf_token };
	return $session;
	
}


#
# CHANNEL LIST 
#
	
# Check if channels.json file can be found and parsed. If condition is false, download and parse latest channel list and present a checklist to the user.
# The channel list must be checked for duplicates. If channel name is duplicated, append count number to the name. If channel ID is duplicated, remove the duplicated entry.
# To recognize changed channel names or IDs, a comparism list will be created. Additionally, a set of default EPG settings will be saved into another file.

sub chlist_request {
	
	#
	# [SUB] CHANNEL LIST 
	#
	
	# URL
	my $channel_url = "https://web.magentatv.de/EPG/JSON/AllChannel?SID=first&T=PC_firefox_72";
	
	# CHANNEL M3U REQUEST
	my $channel_agent = LWP::UserAgent->new(
		agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
	);
	
	# FORM DATA				
	my $channel_data = '{"properties":[{"name":"logicalChannel","include":"/channellist/logicalChannel/contentId,/channellist/logicalChannel/type,/channellist/logicalChannel/name,/channellist/logicalChannel/chanNo,/channellist/logicalChannel/pictures/picture/imageType,/channellist/logicalChannel/pictures/picture/href,/channellist/logicalChannel/foreignsn,/channellist/logicalChannel/externalCode,/channellist/logicalChannel/sysChanNo,/channellist/logicalChannel/physicalChannels/physicalChannel/mediaId,/channellist/logicalChannel/physicalChannels/physicalChannel/fileFormat,/channellist/logicalChannel/physicalChannels/physicalChannel/definition"}],"metaDataVer":"Channel/1.1","channelNamespace":"2","filterlist":[{"key":"IsHide","value":"-1"}],"returnSatChannel":0}';
	
	# COOKIES
	my $cookie_jar    = HTTP::Cookies->new({});
	$cookie_jar->set_cookie(0,'JSESSIONID',$j_token,'/EPG','web.magentatv.de',443);
	$cookie_jar->set_cookie(0,'JSESSIONID',$j_token,'/EPG/','web.magentatv.de',443);
	$cookie_jar->set_cookie(0,'CSESSIONID',$c_token,'/EPG/','web.magentatv.de',443);
	$cookie_jar->set_cookie(0,'CSRFSESSION',$csrf_token,'/EPG/','web.magentatv.de',443);
	$channel_agent->cookie_jar($cookie_jar);
	
	# REQUEST, INCLUDING CSRF TOKEN HEADER
	my $channel_request  = HTTP::Request::Common::POST($channel_url, ":X_CSRFToken" => $csrf_token, Content => $channel_data );
	
	my $channel_response = $channel_agent->request($channel_request);
			
	if( $channel_response->is_error ) {
		die "[E] Channel URL: Invalid response\nRESPONSE:\n" . $channel_response->code . "\n" . $channel_response->content . "\n";
	}

	# READ JSON
	my $ch_file;
		
	eval{
		$ch_file    = decode_json($channel_response->content);
	};
						
	if( not defined $ch_file ) {
		die "[E] Failed to parse JSON file: Channel list\n";
	}
	
	my $ch_file_check = $ch_file->{channellist}[0];
	
	if( not defined $ch_file_check->{contentId} or not defined $ch_file_check->{name} ) {
		
		if( defined $ch_file_check->{errorCode} ) {
			die "[E] Failed to load channel list (no authorization)\n";
		} else {
			die "[E] Failed to load channel list (required content missing)\n";
		}
		
	}
	
	return $ch_file;
	
}

# DEFINE SELECTED CHANNELS
my @ch_selection;
my @chm_selection;

if( -e "channels.json" ) {
	
	# READ JSON INPUT FILE: CHANNELS FILE
	my $channelsfile;
	{
		local $/; #Enable 'slurp' mode
		open my $efh, "<", "channels.json" or die "[E] Unable to read file: channels.json. Please check file permissions.\n";
		$channelsfile = <$efh>;
		close $efh;
	}
	
	# PARSE FILE
	my $channelsdata;
	eval{
		$channelsdata = decode_json($channelsfile);
	};
	
	# FILE CANNOT BE PARSED
	if( not defined $channelsdata ) {
		
		unlink "channels.json";
		unlink "chconfig.json";
		$firstlogin = "true";
	
	# IF ENTRY FOUND: SAVE DATA TO ARRAY	
	} else {
		
		# VALIDATE DATA
		eval{
			@ch_selection = @{ $channelsdata->{channels} };
		};
		
		# VALIDATION SUCCEEDED
		if( @ch_selection ) {
			
			$firstlogin = "false";
		
		# VALIDATION FAILED
		} else{
			
			unlink "channels.json";
			unlink "chconfig.json";
			$firstlogin = "true";
			
		}
		
	}

} else {
	
	# FILE NOT FOUND
	unlink "chconfig.json";
	$firstlogin = "true";

}

# DEFINE ORIGIN CHANNEL ID LIST
my $old_name2id;
my $old_id2name;

if( -e "chconfig.json" ) {
	
	# READ JSON INPUT FILE: CHANNELS FILE
	my $chidfile;
	{
		local $/; #Enable 'slurp' mode
		open my $ffh, "<", "chconfig.json" or die "[E] Unable to read file: chconfig.json. Please check file permissions.\n";
		$chidfile = <$ffh>;
		close $ffh;
	}
	
	# PARSE FILE
	my $chiddata;
	eval{
		$chiddata = decode_json($chidfile);
	};
	
	# FILE CANNOT BE PARSED
	if( not defined $chiddata ) {
		
		unlink "channels.json";
		unlink "chconfig.json";
		$firstlogin = "true";
	
	# IF ENTRY FOUND: SAVE DATA TO ARRAY	
	} else {
		
		my %old_name2id;
		my %old_id2name;
		
		# VALIDATE DATA
		eval{
			%old_name2id = %{ $chiddata->{new_name2id} };
		};
		
		eval{
			%old_id2name = %{ $chiddata->{new_id2name} };
		};
		
		# VALIDATION SUCCEEDED
		if( %old_id2name and %old_name2id ) {
			
			$old_id2name = { %old_id2name };
			$old_name2id = { %old_name2id };
			$firstlogin = "false";
		
		# VALIDATION FAILED	
		} else {
			
			unlink "channels.json";
			unlink "chconfig.json";
			$firstlogin = "true";
		
		}	
	
	}		
	
} else {
	
	# FILE NOT FOUND
	unlink "channels.json";
	$firstlogin = "true";
	
}

# FILE NOT FOUND / CANNOT BE PARSED = PLEASE SELECT THE CHANNELS
if( $firstlogin eq "true" and $selection ne "7" ) {
	
	# DEFINE FILE VALUE
	my $ch_file;
	
	# START CHANNEL LIST REQUEST
	eval{
		$ch_file = chlist_request();
	};
	
	# CHECK IF CHANNEL LIST WAS RECEIVED
	if( not defined $ch_file ) {
		die "[E] Exiting script due to invalid request response (channel list).\n";
	}

	# RETRIEVE DATA FROM CHANNEL LIST
	my @ch_groups = @{ $ch_file->{'channellist'} };
	
	# SET UP VALUES FOR UPCOMING PROCESSES
	my @channels;
	my @duplicate_check;
	my @cid_check;
	my %name2id;
	my %id2name;

	foreach my $ch_groups ( sort { lc $a->{"name"} cmp lc $b->{"name"} } @ch_groups ) {
		my $cid   = $ch_groups->{"contentId"};
		my $cname = $ch_groups->{"name"};
		
		# CHECK DUPLICATES
		my @new_cname = ( "$cname" );
		push ( @duplicate_check, @new_cname );
		
		# CHANNEL NAME DUPLICATED?
		my $duplicate = 0;
		foreach my $duplicate_check ( @duplicate_check ) {
			if( $duplicate_check eq $cname ) {
				$duplicate = ($duplicate + 1);
			}
		}
		
		# APPEND NUMBER TO DUPLICATED CHANNEL NAME
		if( $duplicate > 1 ) {
			$cname = $cname . " ($duplicate)";
		}
		
		# CHANNEL ID DUPLICATED = REMOVE CHANNEL
		my $cid_ok = "1";
		foreach my $cid_check ( @cid_check ) {
			if( $cid eq $cid_check ) {
				undef $cid_ok;
			}
		}
		
		# APPEND NEW CID TO CHECK FOR DUPLICATED IDs IN THE NEXT ROUND
		my @new_cid   = ( "$cid" );
		push ( @cid_check, @new_cid );
		
		# IF NO DUPLIACTED CHANNEL ID WAS FOUND
		if( defined $cid_ok ) {
			
			# CREATE MENU ENTRY
			my @channels_new = ( "$cname", [ "$cid", 0 ] );
			push( @channels, @channels_new );
			
			# CREATE ID CHECK ENTRIES
			my %name2id_new = ( $cname => $cid );
			%name2id = ( %name2id, %name2id_new );
			my %id2name_new = ( $cid => $cname );
			%id2name = ( %id2name, %id2name_new );
			
		}
	}
		
	# MENU
	@chm_selection = $d->checklist( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > CHANNEL LIST',
								    title => "TELEKOM | CHANNEL LIST",
								    listheight => 13,
								    height => 15,
								    width => 70,
								    text => 'Please choose the channels you want to grab:',
								    list => [ @channels ]
								  );
		
	# ABORT PROCESS IF CHECKLIST RETURNS WITH ZERO ENTRIES OR WITH RESULT "0"
	if( @chm_selection == 1 ) {
		foreach my $chm_selection ( @chm_selection ) {
			if( $chm_selection eq "0" ) {
				die "\r[E] Channel selection aborted\n";
			}
		}
	} elsif( ! @chm_selection ) {
		die "\r[E] Channel selection aborted: No channel selected\n";
	}				
	
	# SAVE CHANNEL CONFIGURATION, DECODE UTF8
	foreach my $ch_selection ( @chm_selection ) {
		$ch_selection = decode_utf8($ch_selection);
		push( @ch_selection, $ch_selection );
	}
	
	# SET ID CHECK DATA
	$old_name2id = { %name2id };
	$old_id2name = { %id2name };

	# CREATE JSON PARAMS
	my $channels_json = to_json( { channels => \@chm_selection }, { pretty => 1 } );	# SELECTED CHANNELS
	my $idcheck_json  = to_json( { new_name2id => \%name2id, new_id2name => \%id2name }, { pretty => 1 } );	# COMPARISM LIST
	my $epg_json      = to_json( { day => 7, cid => 0, genre => 1, category => 1, episode => "xmltv_ns", forks => 16, simple => 0 }, { pretty => 1 });	# EPG DEFAULT SETTINGS

	# SAVE JSON TO FILE
	open(my $fha, '>:utf8', 'channels.json'); # SELECTED CHANNELS
	print $fha $channels_json;
	close $fha;

	open(my $fhb, '>:utf8', 'chconfig.json'); # CHANNEL IDs
	print $fhb $idcheck_json;
	close $fhb;
		
	# SAVE JSON IF FILE DOES NOT EXIST
	if( ! -e "epgconfig.json" ) {
		open(my $fhc, '>:utf8', 'epgconfig.json'); # EPG CONFIG DATA
		print $fhc $epg_json;
		close $fhc;
	}
		
	# SUCCESS MESSAGE
	$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > CHANNEL LIST',
				title => "TELEKOM | CHANNEL LIST",
				height => 5,
				width => 40,
				text => 'Channel list saved successfully!'
			  );

} elsif( $firstlogin eq "true" and $selection eq "7" ) {

	die "[E] Wrong or missing channel configuration, please enter UI mode to set up your channels.\n";

}


#
# CHECK EPG SETTINGS
#
	
# Check if epg settings file exists and can be parsed. Also check the correct content of the expected values. Wrong or missing values lead to set the default value of the related setting.
	
# DEFINE EPG SETTINGS
my $day;
my $cid;
my $genre;
my $category;
my $episode;
my $forks;
my $simple;

if( -e "epgconfig.json" ) {
	
	# READ JSON INPUT FILE: EPG CONFIG FILE
	my $epgconffile;
	{
		local $/; #Enable 'slurp' mode
		open my $fh, "<", "epgconfig.json" or die "[E] Unable to read file: epgconfig.json. Please check file permissions.\n";
		$epgconffile = <$fh>;
		close $fh;
	}
		
	my $epgconfdata;
	eval{
		$epgconfdata = decode_json($epgconffile);
	};
		
	# SET DEFAULT SETTINGS: EPG CONFIG FILE IS BROKEN
	if( not defined $epgconfdata ) {
		unlink "epgconfig.json";
		
		# CREATE JSON PARAMS
		my $epg_json      = to_json( { day => 7, cid => 0, genre => 1, category => 1, episode => "xmltv_ns", forks => 16, simple => 0 }, { pretty => 1 });
		
		open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
		print $fh $epg_json;
		close $fh;
	
	}
		
	# CHECK DAY NUMBER
	if( defined $epgconfdata->{day} ) {
		if( $epgconfdata->{day} >= 0 and $epgconfdata->{day} <= 14 ) {
			$day = $epgconfdata->{day};
		} else {
			print "[W] INVALID SETTING: DAY NUMBER (0)\n";
			$day = 7;
		}
	} else {
		print "[W] INVALID SETTING: DAY NUMBER (1)\n";
		$day = 7;
	}
		
	# CHECK RYTEC FORMAT SETTING
	if( defined $epgconfdata->{cid} ) {
		if( $epgconfdata->{cid} == 0 or $epgconfdata->{cid} == 1 ) {
			$cid = $epgconfdata->{cid};
		} else {
			print "[W] INVALID SETTING: RYTEC FORMAT (0)\n";
			$cid = 0;
		}
	} else {
		print "[W] INVALID SETTING: RYTEC FORMAT (1)\n";
		$cid = 0;
	}
	
	# CHECK EIT FORMAT SETTING
	if( defined $epgconfdata->{genre} ) {
		if( $epgconfdata->{genre} == 0 or $epgconfdata->{genre} == 1 ) {
			$genre = $epgconfdata->{genre};
		} else {
			print "[W] INVALID SETTING: EIT FORMAT (0)\n";
			$genre = 1;
		}
	} else {
		print "[W] INVALID SETTING: EIT FORMAT (1)\n";
		$genre = 1;
	}
		
	# CHECK MULTIPLE CATEGORIES SETTING
	if( defined $epgconfdata->{category} ) {
		if( $epgconfdata->{category} == 0 or $epgconfdata->{category} == 1 ) {
			$category = $epgconfdata->{category};
		} else {
			print "[W] INVALID SETTING: MULTIPLE CATEGORIES (0)\n";
			$category = 1;
		}
	} else {
		print "[W] INVALID SETTING: MULTIPLE CATEGORIES (1)\n";
		$category = 1;
	}
	
	# CHECK EPISODE FORMAT SETTING
	if( defined $epgconfdata->{episode} ) {
		if( $epgconfdata->{episode} eq "xmltv_ns" or $epgconfdata->{episode} eq "onscreen" ) {
			$episode = $epgconfdata->{episode};
		} else {
			print "[W] INVALID SETTING: EPISODE FORMAT (0)\n";
			$episode = "xmltv_ns";
		}
	} else {
		print "[W] INVALID SETTING: EPISODE FORMAT (1)\n";
		$episode = "xmltv_ns";
	}
	
	# CHECK FORKS NUMBER
	if( defined $epgconfdata->{forks} ) {
		if( $epgconfdata->{forks} >= 1 and $epgconfdata->{forks} <= 64 ) {
			$forks = $epgconfdata->{forks};
		} else {
			print "[W] INVALID SETTING: FORKS NUMBER (0)\n";
			$forks = 16;
		}
	} else {
		print "[W] INVALID SETTING: FORKS NUMBER (1)\n";
		$forks = 16;
	}
	
	# CHECK SIMPLE GRABBER MODE
	if( defined $epgconfdata->{simple} ) {
		if( $epgconfdata->{simple} == 0 or $epgconfdata->{simple} == 1 ) {
			$simple = $epgconfdata->{simple};
		} else {
			print "[W] INVALID SETTING: GRABBER MODE (0)\n";
			$simple = 0;
		}
	} else {
		print "[W] INVALID SETTING: GRABBER MODE (1)\n";
		$simple = 0;
	}

} else {
		
	# CREATE JSON PARAMS
	my $epg_json      = to_json( { day => 7, cid => 0, genre => 1, category => 1, episode => "xmltv_ns", forks => 16, simple => 0 }, { pretty => 1 } );
		
	open(my $gfh, '>', 'epgconfig.json'); # EPG CONFIG DATA
	print $gfh $epg_json;
	close $gfh;
		
	# SET DEFAULT SETTINGS: EPG CONFIG FILE DOES NOT EXIST
	
	$day      = 7;
	$cid      = 0;
	$genre    = 1;
	$category = 1;
	$episode  = "xmltv_ns";
	$forks    = 10;
	$simple   = 0;
	
}


#
# MAIN MENU
#
	
# Change the EPG settings and modify the channel list.

# RUN MENU UNTIL USER ABORTS THE PROCESS OR RUNS THE XML SCRIPT
until( $selection eq "0" or $selection eq "7" ) {
	
	# MENU
	$selection = $d->menu( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS',
						   title => "TELEKOM | SETTINGS",
						   listheight => 12,
						   height => 16,
						   width => 60,
						   text => 'Please select the option you want to change:',
						   list => [ '1', 'MODIFY CHANNEL LIST',
									 '2', "TIME PERIOD (currently: $day day(s))",
									 '3', "CONVERT CHANNEL IDs INTO RYTEC FORMAT (enabled: $cid)",
									 '4', "CONVERT CATEGORIES INTO EIT FORMAT (enabled: $genre)",
									 '5', "USE MULTIPLE CATEGORIES (enabled: $category)",
									 '6', "EPISODE FORMAT (currently: $episode)",
									 '7', 'RUN XML SCRIPT',
									 '8', "NUMBER OF PARALLEL FORKS (currently: $forks)",
									 'R', 'REMOVE GRABBER INSTANCE' ] );
		
	# ABORT
	if( $selection eq "0" ) {
			
		die "[E] User left menu\n";
	
	# MODIFY CHANNEL LIST
	} elsif( $selection eq "1" ) {
		
		# DEFINE FILE VALUE
		my $menu_ch_file;
		
		# START CHANNEL LIST REQUEST
		eval{
			$menu_ch_file = chlist_request();
		};
		
		# CHECK IF CHANNEL LIST WAS RECEIVED
		if( not defined $menu_ch_file ) {
			
			# ERROR MESSAGE
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CHANNEL LIST',
						title => "TELEKOM | CHANNEL LIST",
						height => 5,
						width => 40,
						text => 'ERROR: Channel list could not be loaded from provider!'
					  );
			
			die "\r[E] Exiting script due to invalid request response (channel list).\n";
		}

		# RETRIEVE DATA FROM CHANNEL LIST
		my @ch_groups = @{ $menu_ch_file->{'channellist'} };
		
		# SET UP VALUES OF NEW CHANNEL LIST
		my @menu_ch_groups = @{ $menu_ch_file->{'channellist'} };
		my @duplicate_check;
		my @new_channels;
		my @cid_check;
		my %name2id;
		my %id2name;

		foreach my $ch_groups ( sort { $a->{"name"} cmp $b->{"name"} } @menu_ch_groups ) {
			my $cid   = $ch_groups->{"contentId"};
			my $cname = $ch_groups->{"name"};
			
			# CHECK DUPLICATES
			my @new_cname = ( "$cname" );
			push ( @duplicate_check, @new_cname );
			
			# CHANNEL NAME DUPLICATED = APPEND NUMBER
			my $duplicate = 0;
			foreach my $duplicate_check ( @duplicate_check ) {
				if( $duplicate_check eq $cname ) {
					$duplicate = ($duplicate + 1);
				}
			}
				
			if( $duplicate > 1 ) {
				$cname = $cname . " ($duplicate)";
			}
				
			# CHANNEL ID DUPLICATED = REMOVE CHANNEL
			my $cid_ok = "1";
			foreach my $cid_check ( @cid_check ) {
				if( $cid eq $cid_check ) {
					undef $cid_ok;
				}
			}
				
			my @new_cid   = ( "$cid" );
			push ( @cid_check, @new_cid );
			
			if( defined $cid_ok ) {
				
				# CREATE ID CHECK ENTRIES
				my %name2id_new = ( $cname => $cid );
				%name2id = ( %name2id, %name2id_new );
				my %id2name_new = ( $cid => $cname );
				%id2name = ( %id2name, %id2name_new );
					
				# ADD NEW CHANNEL NAME TO LIST
				push( @new_channels, $cname );
				
			}
			
		}
			
		# GET CHANNEL IDs FROM NEW CHANNEL CONFIGURATION
		my $idcheck  = { new_name2id => \%name2id, new_id2name => \%id2name };
		my $new_name2id = $idcheck->{new_name2id};
		my $new_id2name = $idcheck->{new_id2name};
		
		### CHECK CHANNEL CONDITIONS
		my %chmenu_config;
		my %applied_channels;
		my $key_counter = 0;
		my @channels;
		
		foreach my $old_channel ( @ch_selection ) {
			
			# OLD CHANNEL NAME IN NEW CHANNEL LIST? - YES: ENABLE MENU ENTRY - NO: CHECK FURTHER
			if( defined $new_name2id->{$old_channel} ) {
				
				$key_counter = $key_counter + 1;
				%chmenu_config = ( %chmenu_config, $key_counter => { name => $old_channel, id => $new_name2id->{$old_channel}, enabled => 1 } );
				%applied_channels = ( %applied_channels, $old_channel => 1 );
				
			# OLD ID OF OLD CHANNEL NAME IN NEW CHANNEL LIST? - YES: CHECK FURTHER - NO: NOTHING
			} elsif( defined $new_id2name->{ $old_name2id->{$old_channel} } ) {
				
				# OTHER OLD CHANNEL NAME WITH OLD ID OF THE ACTUAL CHANNEL NAME IN NEW CHANNEL LIST? - YES: NOTHING - NO: ENABLE MENU ENTRY
				if( not defined $old_name2id->{ $new_id2name->{ $old_name2id->{$old_channel} } } ) {
					
					$key_counter = $key_counter + 1;
					%chmenu_config = ( %chmenu_config, $key_counter => { name => $new_id2name->{ $old_name2id->{$old_channel} }, id => $old_name2id->{$old_channel}, enabled => 1 } );
					%applied_channels = ( %applied_channels, $old_name2id->{$old_channel} => 1 );
					
				}
				
			}
						
		}
			
		my $applied_channels = { known => { %applied_channels } };
			
		foreach my $new_channel ( @new_channels ) {
				
			# NEW CHANNEL NAME ALREADY DEFINED IN MENU?
			if( not defined $applied_channels->{known}->{$new_channel} ) {
				
				$key_counter = $key_counter + 1;
				%chmenu_config = ( %chmenu_config, $key_counter => { name => $new_channel, id => $new_name2id->{$new_channel}, enabled => 0 } );
					
			}
				
		}
		
		my $chmenu_config = { entries => \%chmenu_config };
		my %ch_keys = %{ $chmenu_config->{entries} };
		
		# SORT CHANNELS, CREATE LIST
		foreach my $chmenu_config ( sort { lc $ch_keys{$a}->{name} cmp lc $ch_keys{$b}->{name} } keys %ch_keys ) {
		
			my @channels_new = ( $ch_keys{$chmenu_config}->{name}, [ $ch_keys{$chmenu_config}->{id}, $ch_keys{$chmenu_config}->{enabled} ] );
			push( @channels, @channels_new );
		
		}
			
		# MENU
		my @new_ch_selection = $d->checklist( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CHANNEL LIST',
								   title => "TELEKOM | CHANNEL LIST",
								   listheight => 13,
								   height => 15,
								   width => 55,
								   text => 'Please choose the channels you want to grab:',
								   list => [ @channels ] );
										
		# ABORT PROCESS IF CHECKLIST RETURNS WITH ZERO ENTRIES OR WITH RESULT "0"
		if( @new_ch_selection == 1 ) {
			foreach my $ch_selection ( @new_ch_selection ) {
				if( $ch_selection eq "0" ) {
					$selection = "X";
				}
			}
		} elsif( ! @new_ch_selection ) {
			$selection = "X";
		}
	
		if( $selection ne "X" ) {
			
			# SAVE NEW CHANNEL CONFIGURATION, DECODE UTF8
			undef @ch_selection;
			foreach my $ch_selection ( @new_ch_selection ) {
				$ch_selection = decode_utf8($ch_selection);
				push( @ch_selection, $ch_selection );
			}
			$old_id2name = { %id2name };
			$old_name2id = { %name2id };
			
			# CREATE JSON PARAMS
			my $channels_json = to_json( { channels => \@ch_selection }, { pretty => 1 } );	# SELECTED CHANNELS
			my $idcheck_json  = to_json( { new_name2id => \%name2id, new_id2name => \%id2name }, { pretty => 1 } );	# COMPARISM LIST

			# SAVE JSON TO FILE
			open(my $fha, '>:utf8', 'channels.json'); # SELECTED CHANNELS
			print $fha $channels_json;
			close $fha;
			
			open(my $fhb, '>:utf8', 'chconfig.json'); # CHANNEL IDs
			print $fhb $idcheck_json;
			close $fhb;
			
			# SUCCESS MESSAGE
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CHANNEL LIST',
						title => "TELEKOM | CHANNEL LIST",
						height => 5,
						width => 40,
						text => 'Channel list saved successfully!'
					  );
		
		}
		
	# TIME PERIOD
	} elsif( $selection eq "2" ) {
			
		my $day_old = $day;
			
		# MENU
		$day = $d->menu( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > TIME PERIOD',
					     title      => 'EPG GRABBER',
						 listheight => 10,
						 height     => 14,
						 width      => 46,
						 text       => 'Please select the number of days you want to retrieve the EPG information.',
						 list       => [ 'X', "Disable EPG Grabber",
						                 '1', '1 day',
						                 '2', '2 days',
						                 '3', '3 days',
						                 '4', '4 days',
						                 '5', '5 days',
						                 '6', '6 days',
						                 '7', '7 days',
						                 '8', '8 days',
						                 '9', '9 days',
						                 '10', '10 days',
						                 '11', '11 days',
						                 '12', '12 days',
						                 '13', '13 days',
						                 '14', '14 days' ] );
			
		# ABORT, RETURN TO MAIN MENU
		if( $day eq "0" ) {
				
			$day       = $day_old;
			$selection = "X";
				
		# DISABLE EPG GRABBER
		} elsif( $day eq "X" ) {
				
			# CREATE JSON PARAMS
			$day = 0;
			my $epg_json      = to_json( { day => 0, cid => $cid, genre => $genre, category => $category, episode => $episode, forks => $forks, simple => $simple }, { pretty => 1 });
					
			open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
			print $fh $epg_json;
			close $fh;
				
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > TIME PERIOD', 
						title     => 'INFO', 
						height    => 5,
						width     => 26,
						text      => 'EPG grabber disabled!' );
		
		# SET NEW NUMBER OF DAYS
		} else {
				
			# CREATE JSON PARAMS
			my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => $episode, forks => $forks, simple => $simple }, { pretty => 1 });
				
			open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
			print $fh $epg_json;
			close $fh;
				
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > TIME PERIOD', 
						title     => 'INFO', 
						height    => 5,
						width     => 42,
						text      => "EPG grabber enabled for $day day(s)!" );
		}
		
	# CONVERT CHANNEL IDs INTO RYTEC FORMAT
	} elsif( $selection eq "3" ) {
			
		# MENU
		$cid = $d->yesno( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CONVERT CHANNEL IDs',
				      title      => 'CHANNEL IDs',
						  height     => 8,
						  width      => 55,
						  text       => 'Do you want to use the Rytec ID format?\n\nRytec ID example: ChannelNameHD.de\nUsual ID example: Channel Name HD' );
			
		# CREATE JSON PARAMS
		my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => $episode, forks => $forks, simple => $simple }, { pretty => 1 });
			
		open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
		print $fh $epg_json;
		close $fh;
							    
		# YES
		if( $cid eq "1" ) {				
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CONVERT CHANNEL IDs', 
						title     => 'INFO', 
						height    => 5,
						width     => 30,
						text      => "Rytec Channel IDs enabled!" );
			
		# NO
		} else {
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CONVERT CHANNEL IDs', 
						title     => 'INFO', 
						height    => 5,
						width     => 32,
						text      => "Rytec Channel IDs disabled!" );
		
		}
		
	# CONVERT CATEGORIES INTO EIT FORMAT
	} elsif( $selection eq "4" ) {
			
		# MENU
		$genre = $d->yesno( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CONVERT CATEGORIES',
					        title      => 'CATEGORIES',
						    height     => 5,
						    width      => 55,
						    text       => 'Do you want to use the EIT format for tvHeadend?' );
			
		# CREATE JSON PARAMS
		my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => $episode, forks => $forks, simple => $simple }, { pretty => 1 });
			
		open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
		print $fh $epg_json;
		close $fh;
			
		# YES
		if( $genre eq "1" ) {				

			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CONVERT CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 30,
						text      => "EIT categories enabled!" );
			
		# NO
		} else {
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > CONVERT CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 32,
						text      => "EIT categories disabled!" );
		
		}
		
	# USE MULTIPLE CATEGORIES
	} elsif( $selection eq "5" ) {
		
		# MENU
		$category = $d->yesno( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > MULTIPLE CATEGORIES',
					           title      => 'MULTIPLE CATEGORIES',
						       height     => 5,
						       width      => 60,
						       text       => 'Do you want to use multiple categories for tvHeadend?' );
			
		# CREATE JSON PARAMS
		my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => $episode, forks => $forks, simple => $simple }, { pretty => 1 });
			
		open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
		print $fh $epg_json;
		close $fh;
			
		# YES
		if( $category eq "1" ) {				
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > MULTIPLE CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 35,
						text      => "Multiple categories enabled!" );
			
		# NO
		} else {
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > MULTIPLE CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 35,
						text      => "Multiple categories disabled!" );
		
		}
			
	# EPISODE FORMAT
	} elsif( $selection eq "6" ) {
			
		my $episode_old = $episode;
			
		# MENU
		$episode = $d->menu( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > EPISODE FORMAT',
					         title      => 'EPISODE',
						     listheight => 10,
						     height     => 14,
						     width      => 60,
						     text       => 'Please select the format you want to use.\n\nonscreen: move the episode data into the broadcast description\nxmltv_ns: episode data to be parsed by tvHeadend',
						     list       => [ '1', 'ONSCREEN', '2', 'XMLTV_NS' ] );
			
		# ABORT, RETURN TO MAIN MENU
		if( $episode eq "0" ) {
				
			$episode   = $episode_old;
			$selection = "X";
			
		# ENABLE ONSCREEN
		} elsif( $episode eq "1" ) {
				 
			# CREATE JSON PARAMS
			my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => "onscreen", forks => $forks, simple => $simple }, { pretty => 1 });
					
			open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
			print $fh $epg_json;
			close $fh;
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > EPISODE FORMAT', 
						title     => 'INFO', 
						height    => 5,
						width     => 40,
						text      => "Episode format 'onscreen' enabled!" );
			
			$episode = "onscreen";
			
		# ENABLE XMLTV_NS
		} elsif( $episode eq "2" ) {
			 
			# CREATE JSON PARAMS
			my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => "xmltv_ns", forks => $forks, simple => $simple }, { pretty => 1 });
				
			open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
			print $fh $epg_json;
			close $fh;
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > EPISODE FORMAT', 
						title     => 'INFO', 
						height    => 5,
						width     => 40,
						text      => "Episode format 'xmltv_ns' enabled!" );
			
			$episode = "xmltv_ns";
			
		}		 
	
	# NUMBER OF FORKS
	} elsif( $selection eq "8" ) {
			
		my $forks_old = $forks;
			
		# MENU
		$forks = $d->menu( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > NUMBER OF FORKS',
					       title      => 'NUMBER OF FORKS',
						   listheight => 10,
						   height     => 14,
						   width      => 46,
						   text       => 'Please select the number of forks you want to use for EPG grabber.',
						   list       => [ '1', '1 fork',
						                 '2', '2 forks',
						                 '4', '4 forks',
						                 '8', '8 forks',
						                 '16', '16 forks',
						                 '32', '32 forks' ] );
			
		# ABORT, RETURN TO MAIN MENU
		if( $forks eq "0" ) {
				
			$forks       = $forks_old;
			$selection = "X";
		
		# SET NEW NUMBER OF FORKS
		} else {
				
			# CREATE JSON PARAMS
			my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => $episode, forks => $forks, simple => $simple }, { pretty => 1 });
				
			open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
			print $fh $epg_json;
			close $fh;
				
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > NUMBER OF FORKS', 
						title     => 'INFO', 
						height    => 5,
						width     => 42,
						text      => "EPG grabber enabled with $forks fork(s)!" );
		}
	
	# REMOVE GRABBER INSTANCE
	} elsif( $selection eq "R" ) {
			
		my $delete = $d->yesno( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > DELETE INSTANCE',
								title     => 'WARNING',
								height    => 5,
								width     => 50,
								text      => 'Do you want to delete this service?' );
				   
		if( $delete eq "1" ) {
			
			unlink "userfile.json";
			unlink "channels.json";
			unlink "chconfig.json";
			unlink "epgconfig.json";
					
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > TELEKOM > SETTINGS > DELETE INSTANCE', 
						title     => 'INFO', 
						height    => 5,
						width     => 30,
						text      => "Service deleted!" );
					
			die "\rDONE\n";
		
		}
		
	}
		
}


#
# DOWNLOAD PROCESS
#

print "\n\n=== DOWNLOAD PROCESS ===\n\n";

if( $day eq "0" ) {
	
	die "[E] Grabber disabled, grab process stopped.\n";
	
}

### DOWNLOAD NEW CHANNEL LIST TO RETRIEVE NEW NAME/ID CONFIGURATION
print "* Downloading new channel list...\n\n";

# DEFINE FILE VALUE
my $dl_ch_file;
		
# START CHANNEL LIST REQUEST
eval{
	$dl_ch_file = chlist_request();
};
		
# CHECK IF CHANNEL LIST WAS RECEIVED
if( not defined $dl_ch_file ) {
	die "[E] Exiting script due to missing channels file.\n";
}

# RETRIEVE DATA FROM CHANNEL LIST
my @ch_groups = @{ $dl_ch_file->{channellist} };

# SET UP VALUES OF NEW CHANNEL LIST
my @dl_ch_groups = @{ $dl_ch_file->{channellist} };
my @duplicate_check;
my @cid_check;
my %name2id;
my %id2name;
my %id2logo;

foreach my $ch_groups ( @dl_ch_groups ) {
	
	my $cid   = $ch_groups->{contentId};
	my $cname = $ch_groups->{name};
	my $logo;
	
	# LOGO SEARCH
	my @logo = @{ $ch_groups->{pictures} };
	my $image_location;
	if( @logo ) {
		
		while( my( $image_id, $img ) = each( @logo ) ) {
			
			if( $img->{imageType} eq "15" ) {
				$image_location = $image_id;
				last;
			}
			
		}
			
		if( defined $image_location ) {
			$logo = $ch_groups->{pictures}[$image_location]{href};
		} else {
			$logo = "http://programm-manager.telekom.de/media/5907a60bfb29f7bd3d141b1dc36ab3c74d4b6e5b.png";
		}
		
	}

	# CHECK DUPLICATES
	my @new_cname = ( "$cname" );
	push ( @duplicate_check, @new_cname );
		
	# CHANNEL NAME DUPLICATED?
	my $duplicate = 0;
	foreach my $duplicate_check ( @duplicate_check ) {
		if( $duplicate_check eq $cname ) {
			$duplicate = ($duplicate + 1);
		}
	}
		
	# APPEND NUMBER TO DUPLICATED CHANNEL NAME
	if( $duplicate > 1 ) {
		$cname = $cname . " ($duplicate)";
	}
		
	# CHANNEL ID DUPLICATED = REMOVE CHANNEL
	my $cid_ok = "1";
	foreach my $cid_check ( @cid_check ) {
		if( $cid eq $cid_check ) {
			undef $cid_ok;
		}
	}
		
	# APPEND NEW CID TO CHECK FOR DUPLICATED IDs IN THE NEXT ROUND
	my @new_cid   = ( "$cid" );
	push ( @cid_check, @new_cid );
		
	# IF NO DUPLIACTED CHANNEL ID WAS FOUND
	if( defined $cid_ok ) {
			
		# CREATE ID CHECK ENTRIES
		my %name2id_new = ( $cname => $cid );
		%name2id = ( %name2id, %name2id_new );
		my %id2name_new = ( $cid => $cname );
		%id2name = ( %id2name, %id2name_new );
		my %id2logo_new = ( $cid => $logo );
		%id2logo = ( %id2logo, %id2logo_new );
			
	}

}

# SET NEW CONFIGURATION LISTS
my $new_name2id = { %name2id };
my $new_id2name = { %id2name };
my $new_id2logo = { %id2logo };

### CHECK CONFIGURATION, COMPARE OLD/NEW CHANNEL ID DATA

my %ch_config;

foreach my $old_channel ( @ch_selection ) {
	
	# DEFINE NEW ID/NAME KEY
	my %ch_config_new;
	
	# OLD CHANNEL NAME IN NEW CHANNEL LIST?
	if( defined $new_name2id->{$old_channel} ) {
		
		%ch_config_new = ( $new_name2id->{$old_channel} => { name => $old_channel, logo => $new_id2logo->{ $new_name2id->{$old_channel} } } );
		%ch_config     = ( %ch_config, %ch_config_new );
		
		if( $new_name2id->{$old_channel} ne $old_name2id->{$old_channel} ) {
			
			print "[I] Channel \"" . encode_utf8($old_channel) . "\" received new ID \"" . $new_name2id->{$old_channel} . "\"!\n";
			
		}
	
	# OLD CHANNEL NAME IN OLD CHANNEL LIST?
	} elsif( not defined $old_name2id->{$old_channel} ) {
		
			print "[W] Channel \"" . encode_utf8($old_channel) . "\" not found in configuration files!\n";
				
	# OLD ID OF OLD CHANNEL NAME IN NEW CHANNEL LIST? - YES: CHECK FURTHER - NO: NOTHING
	} elsif( defined $new_id2name->{ $old_name2id->{$old_channel} } ) {
			
		# OTHER OLD CHANNEL NAME WITH OLD ID OF THE ACTUAL CHANNEL NAME IN NEW CHANNEL LIST? - YES: NOTHING - NO: CREATE MENU ENTRY
		if( not defined $old_name2id->{ $new_id2name->{ $old_name2id->{$old_channel} } } ) {
			
			%ch_config_new = ( $old_name2id->{$old_channel} => { name => $old_channel, logo => $new_id2logo->{ $old_name2id->{$old_channel} } } );
			%ch_config     = ( %ch_config, %ch_config_new );
			
			print "[I] Channel \"" . encode_utf8($old_channel) . "\" received new channel name \"" . $new_id2name->{ $old_name2id->{$old_channel} } . "\"!\n";
			
		} else {
			
			print "[W] Renamed channel \"" . encode_utf8($old_channel) . "\" already exists in old channel configuration!\n";
			
		}
			
	}
				
}

my $ch_config = { channels => \%ch_config };

### DOWNLOAD MAIN PROGRAMME LISTS

# URL
my $guide_url = "https://web.magentatv.de/EPG/JSON/ExecuteBatch?PlayBillList&SID=guidebatch&T=PC_firefox_72";

# REQUEST PARAM
my $guide_agent = LWP::UserAgent->new(
	agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
);

# COOKIES
my $cookie_jar    = HTTP::Cookies->new({});
$cookie_jar->set_cookie(0,'JSESSIONID',$j_token,'/EPG','web.magentatv.de',443);
$cookie_jar->set_cookie(0,'JSESSIONID',$j_token,'/EPG/','web.magentatv.de',443);
$cookie_jar->set_cookie(0,'CSESSIONID',$c_token,'/EPG/','web.magentatv.de',443);
$cookie_jar->set_cookie(0,'CSRFSESSION',$csrf_token,'/EPG/','web.magentatv.de',443);
$guide_agent->cookie_jar($cookie_jar);

# TIMESTAMPS
my $time_start  = gmtime();
my $time_end    = gmtime() + ( 86400 * $day );

my $time_start_date   = $time_start->ymd . " 06:00:00";
my $time_end_date     = $time_end->ymd . " 05:59:59";
	
my $time_start_secs   = Time::Piece->strptime( "$time_start_date", "%Y-%m-%d %H:%M:%S" );
my $time_end_secs     = Time::Piece->strptime( "$time_end_date", "%Y-%m-%d %H:%M:%S" );

my $start_epoch  = $time_start_secs->strftime("%Y%m%d%H%M%S");
my $end_epoch    = $time_end_secs->strftime("%Y%m%d%H%M%S");

# CHANNEL LIST
my %ch_keys = %{ $ch_config->{channels} };

# GENERATE FORM DATA
my @request_form;
my @element;
my $programme_counter = 0;

# GET ARRAY OF 15 CHANNEL ELEMENTS
foreach my $channel ( keys %ch_keys ) {
	
	my $prop_form  = { "name" => "playbill", "include" => "channelid,name,subName,starttime,endtime,cast,country,producedate,ratingid,pictures,introduce,genres,subNum,seasonNum" };
	my $param_form = { "channelid" => $channel, "type" => 2, "offset" => 0, "count" => -1, "isFillProgram" => 1, "properties" => [ $prop_form ], "endtime" => $end_epoch, "begintime" => $start_epoch };
	my $list_form  = { "name" => "PlayBillList", "param" => $param_form };
	
	if( $programme_counter < 15 ) {
		
		push( @request_form, $list_form );
		$programme_counter = $programme_counter + 1;
	
	} else {
		
		my $form_list = { "requestList" => \@request_form };
		my $form_json = encode_json( $form_list );
		push( @element, $form_json );
		undef @request_form;
		
		push( @request_form, $list_form );
		$programme_counter = 1;
	
	}
	
}

# PUSH ELEMENTS LEFT
if( @request_form ) {
	
	my $form_list = { "requestList" => \@request_form };
	my $form_json = encode_json( $form_list );
	push( @element, $form_json );
	undef @request_form;

}

# PARALLEL FORK MANAGER - SETUP
my $pm = Parallel::ForkManager->new($forks);
my @programme_details;
my $size = @element;
my $pm_counter = 0;

$pm->run_on_finish(
		
	sub {
		
		my( $pid, $exit_code, $ident, $signal, $core, $ds ) = @_;
			
		if( not defined $ds ) {
			die "[E] No datastructure received from child process (programme download)!\n";
		} else {
			$pm_counter = ( $pm_counter + 1 );
			my $percentage = ( $pm_counter / $size ) * 100;
			$percentage = POSIX::round($percentage);
			print "\r[I] Processing download: $percentage% ($pm_counter/$size)";
		}
		
		@programme_details = ( @programme_details, @{ $ds->{results} } );
	}
		
);

foreach my $json_element ( @element ) {
	
	$pm->start and next;
	
	my @listings;
	
	# REQUEST, INCLUDING CSRF TOKEN HEADER
	my $guide_request  = HTTP::Request::Common::POST($guide_url, ":X_CSRFToken" => $csrf_token, Content => $json_element );
		
	my $guide_response = $guide_agent->request($guide_request);
				
	if( $guide_response->is_error ) {
		die "[E] Channel URL: Invalid response\nRESPONSE:\n" . $guide_response->content . "\n";
	}
	
	# READ JSON
	my $guide_file;
		
	eval{
		$guide_file    = decode_json($guide_response->content);
	};
						
	if( not defined $guide_file ) {
		die "[E] Failed to parse JSON file: Guide\n";
	}

	my @guide_file;
	
	eval{
		@guide_file = @{ $guide_file->{responseList} };
	};
	
	if( ! @guide_file ) {
		die "[E] Failed to retrieve guide data\n";
	}
	
	# CHANNEL LIST
	foreach my $response ( @guide_file ) {
		
		my @playbill_list;
		
		if( defined $response->{msg}->{counttotal} ) {
			
			if( $response->{msg}->{counttotal} ne "0" ) {
				
				eval{
					@playbill_list = @{ $response->{msg}->{playbilllist} };
				};
		
				if( ! @playbill_list ) {
					die "[E] Failed to retrieve playbill data\n";
				}
				
				# GET THE CHANNEL'S DATA
				foreach my $ch_guide_info ( @playbill_list ) {
					
					# DATA
					my $start 			= $ch_guide_info->{starttime};
					my $end   			= $ch_guide_info->{endtime};
					$start =~ s/[-: ]//g;
					$end   =~ s/[-: ]//g;
					$start =~ s/UTC.*//g;
					$end =~ s/UTC.*//g;
					my $channel         = $ch_guide_info->{channelid};
					my $title 			= $ch_guide_info->{name};
					my $episode_title 	= $ch_guide_info->{subName};
					my $episode_number 	= $ch_guide_info->{subNum};
					my $series_number 	= $ch_guide_info->{seasonNum};
					my $image 			= $ch_guide_info->{pictures};
					my $genre           = $ch_guide_info->{genres};
					my $description     = $ch_guide_info->{introduce};
					my $year            = $ch_guide_info->{producedate};
					my $country         = $ch_guide_info->{country};
					my $age             = $ch_guide_info->{ratingid};
					my $director        = $ch_guide_info->{cast}->{director};
					my $actor           = $ch_guide_info->{cast}->{actor};
					
					# ...APPEND DATA + CHECK IF START/END TIME + TITLE ARE IN THE LIST
					if( not defined $start or not defined $end ) {
						die "[E] Missing required data from guide programmes!\n";
					} elsif( not defined $title ) {
						$title = "No programme title available";
					}
					
					my %data = ( channel => $channel, start => $start, end => $end, title => $title );
					
					# ...CHECK IF EPISODE TITLE IS AVAILABLE IN THE LIST		
					if( defined $episode_title ) {		
						if( $episode_title ne "" ) {
							%data = ( %data, episode_title => $episode_title );
						}
					}
					
					# ...CHECK IF EPISODE NUMBER IS AVAILABLE IN THE LIST		
					if( defined $episode_number ) {
						if( $episode_number ne "" ) {
							%data = ( %data, episode_number => $episode_number );
						}
					}
					
					# ...CHECK IF SERIES NUMBER IS AVAILABLE IN THE LIST		
					if( defined $series_number ) {
						if( $series_number ne "" ) {
							%data = ( %data, series_number => $series_number );
						}
					}
					
					# ...CHECK IF IMAGE IS AVAILABLE IN THE LIST		
					if( defined $image ) {
						my @image;
						my $img_loc;
						
						eval{
							@image = @{ $image };
						};
					
						if ( @image ) {
							while( my( $image_id, $img ) = each( @image ) ) {		# SEARCH FOR IMAGE WITH THE HIGHEST RESOLUTION
								my @res = @{ $img->{'resolution'} };
								my $img = $img->{'href'};
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
								$image = $image[$img_loc]{'href'};
								%data = ( %data, image => $image );
							}
						}
					}
					
					# ...CHECK IF GENRE IS AVAILABLE IN THE LIST		
					if( defined $genre ) {
						
						my @genres;
						
						if( $genre =~ /,/ ) {
							
							@genres = split ",",  $genre;
							
							if( defined $genres[0] ) {
								%data = ( %data, genre_1 => $genres[0] );
							}
							
							if( defined $genres[1] ) {
								%data = ( %data, genre_2 => $genres[1] );
							}
							
							if( defined $genres[2] ) {
								%data = ( %data, genre_3 => $genres[2] );
							}
							
						} elsif( $genre ne "" ) {
							
							%data = ( %data, genre_1 => $genre );
							
						}
						
					}
					
					# ...CHECK IF DESCRIPTION IS AVAILABLE IN THE LIST
					if( defined $description ) {
						if( $description ne "" ) {
							%data = ( %data, description => $description );
						}
					}
					
					# ...CHECK IF YEAR IS AVAILABLE IN THE LIST
					if( defined $year ) {
						if( $year ne "" ) {
							$year =~ s/-.*//g;
							%data = ( %data, year => $year );
						}
					}
					
					# ...CHECK IF COUNTRY IS AVAILABLE IN THE LIST
					if( defined $country ) {
						if( $country ne "" ) {
							%data = ( %data, country => uc($country) );
						}
					}
					
					# ...CHECK IF AGE RATING IS AVAILABLE IN THE LIST
					if( defined $age ) {
						if( $age ne "-1" and $age ne "" ) {
							%data = ( %data, age => $age );
						}
					}
					
					# ...CHECK IF DIRECTOR IS AVAILABLE IN THE LIST
					if( defined $director ) {
						
						my @director;
						
						if( $director =~ /,/ ) {
							
							@director = split ",", $director;
							%data = ( %data, director => \@director );
							
						} elsif( $director ne "" ) {
							
							%data = ( %data, director => [ $director ] );
							
						}
						
					}
					
					# ...CHECK IF ACTOR IS AVAILABLE IN THE LIST
					if( defined $actor ) {
						
						my @actor;
						
						if( $actor =~ /,/ ) {
							
							@actor = split ",", $actor;
							%data = ( %data, actor => \@actor );
							
						} elsif( $actor ne "" ) {
							
							%data = ( %data, actor => [ $actor ] );
							
						}
						
					}
							
					push( @listings, { %data } );
					
				}
				
			} else {
				
				# PLAYBILLLIST COUNT = 0
				print "\r[W] No playbill data found in results\n";
				
			}
			
		} else {
			
			# NO PLAYBILLLIST COUNT FOUND
			die "[E] Failed to retrieve playbill data (2)\n";
			
		}
		
	}
	
	$pm->finish( 0, { results => \@listings } );
	
}

$pm->wait_all_children();


print "\n\n=== FILE CREATION PROCESS ===\n\n* Preparing EPG file creation...\n\n";

### DOWNLOAD RYTEC

# URL
my $rytec_url = "https://raw.githubusercontent.com/sunsettrack4/config_files/master/tkm_channels.json";

# CHANNEL M3U REQUEST
my $rytec_agent = LWP::UserAgent->new(
	agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
);
					
my $rytec_request  = HTTP::Request::Common::GET($rytec_url);
my $rytec_response = $rytec_agent->request($rytec_request);
			
if( $rytec_response->is_error ) {
	die "[E] Rytec URL: Invalid response\n\nRESPONSE:\n\n" . $rytec_response->content . "\n\n";
}

# READ JSON
my $rytec_file;

eval{
	$rytec_file    = decode_json($rytec_response->content);
};
					
if( not defined $rytec_file ) {
	die "[E] Failed to parse JSON file: Rytec\n";
}

my $rytec_db = $rytec_file->{channels}->{DE};

if( not defined $rytec_db ) {
	print "[W] Failed to retrieve Rytec data\n";
}


### DOWNLOAD EIT GENRE

# URL
my $eit_url = "https://raw.githubusercontent.com/sunsettrack4/config_files/master/tkm_genres.json";

# CHANNEL M3U REQUEST
my $eit_agent = LWP::UserAgent->new(
	agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
);
					
my $eit_request  = HTTP::Request::Common::GET($eit_url);
my $eit_response = $eit_agent->request($eit_request);
			
if( $eit_response->is_error ) {
	die "[E] EIT URL: Invalid response\n\nRESPONSE:\n\n" . $eit_response->content . "\n";
}

# READ JSON
my $eit_file;

eval{
	$eit_file    = decode_json($eit_response->content);
};
					
if( not defined $rytec_file ) {
	die "[E] Failed to parse JSON file: EIT\n";
}

my $eit_db = $eit_file->{categories}->{DE};

if( not defined $eit_db ) {
	print "[W] Failed to retrieve EIT data\n";
}


#
# CREATE XML FILE
#

print "* Creating EPG file...\n\n";

# DECLARE OUTPUT FILE
my $output = IO::File->new(">telekom.xml");
 
# CREATE WRITER OBJECT
my $writer = XML::Writer->new(OUTPUT => $output, DATA_MODE => 1, ENCODING => 'utf-8' );

# FIRST DECLARATION
$writer->xmlDecl("UTF-8");

# COMMENT
$writer->comment("EPG XMLTV FILE CREATED BY THE EASYEPG PROJECT - (c) 2019-2020 Jan-Luca Neumann");
$writer->comment("created on " . localtime() );
$writer->comment("SOURCE: TELEKOM DE (MAGENTA TV)");

# TV
$writer->startTag("tv");

foreach my $channel ( sort { lc $a cmp lc $b } keys %ch_keys ) {
	
	if( $cid eq "1" and defined $rytec_db->{ $ch_keys{$channel}->{name} } ) {
		$writer->startTag( "channel", "id" => $rytec_db->{ $ch_keys{$channel}->{name} } );
	} elsif( $cid eq "1" ) {
		print "[W] Channel \"" . encode_utf8($ch_keys{$channel}->{name}) . "\" not found in Rytec ID list!\n";
		$writer->startTag( "channel", "id" => $ch_keys{$channel}->{name} );
	} else {
		$writer->startTag( "channel", "id" => $ch_keys{$channel}->{name} );
	}
	
	$writer->startTag( "display-name", "lang" => "de" );
	
	$writer->characters( $ch_keys{$channel}->{name} );
	
	$writer->endTag( "display-name" );
	
	$writer->emptyTag( "icon", "src" => $ch_keys{$channel}->{logo} );
	
	$writer->endTag( "channel" );
	
}

# CATEGORY RESEARCH PARAMS, PART 1 - CHECK IF EIT WAS ALREADY MISSING, AVOID DUPLICATED WARNING MESSAGES
my %already_not_found;
my $already_not_found;

# PROGRAMME LIST
foreach my $prog ( sort { lc $a->{channel} cmp lc $b->{channel} || $a->{start} cmp $b->{start} } @programme_details ) {
	
	# DEFINE CHANNEL ID
	my $channel_id   = $prog->{channel};
	my $channel_name = $ch_config->{channels}->{$channel_id}->{name};
	
	# START / END / CHANNEL ID
	if( $cid eq "1" and defined $rytec_db->{ $channel_name } ) {
		$writer->startTag( "programme", "start" => $prog->{start}, "stop" => $prog->{end}, "channel" => $rytec_db->{ $channel_name } );
	} else {
		$writer->startTag( "programme", "start" => $prog->{start}, "stop" => $prog->{end}, "channel" => $channel_name );
	}
	
	if( defined $prog->{image} ) {
		$writer->emptyTag( "image", "url" => $prog->{image} );
	}
	
	# TITLE
	$writer->startTag( "title", "lang" => "de" );
	$writer->characters( $prog->{title} );
	$writer->endTag( "title" );
	
	# SUB TITLE
	if( defined $prog->{"episode-title"} ) {
		$writer->startTag( "sub-title", "lang" => "de" );
		$writer->characters( $prog->{"episode-title"} );
		$writer->endTag( "sub-title" );
	}
	
	# DESCRIPTION
	if( defined $prog->{description} ) {
		$writer->startTag( "desc", "lang" => "de" );
		$writer->characters( $prog->{description} );
		$writer->endTag( "desc" );
	}
	
	# CREDITS
	if( defined $prog->{director} or defined $prog->{actor} ) {
		
		$writer->startTag( "credits" );
		
		if( defined $prog->{director} ) {
			my @director = @{ $prog->{director} };
			foreach my $director ( @director ) {
				$writer->startTag( "director" );
				$writer->characters( $director );
				$writer->endTag( "director" );
			}
		}
		
		if( defined $prog->{actor} ) {
			my @actor = @{ $prog->{actor} };
			foreach my $actor ( @actor ) {
				$writer->startTag( "actor" );
				$writer->characters( $actor );
				$writer->endTag( "actor" );
			}
		}
		
		$writer->endTag( "credits" );
	
	}
	
	# DATE
	if( defined $prog->{year} ) {
		$writer->startTag( "date" );
		$writer->characters( $prog->{year} );
		$writer->endTag( "date" );
	}
	
	# COUNTRY
	if( defined $prog->{country} ) {
		$writer->startTag( "country" );
		$writer->characters( $prog->{country} );
		$writer->endTag( "country" );
	}
	
	# CATEGORY RESEARCH PARAMS, PART 2 - CHECK IF EIT CATEGORY WAS ALREADY PRINTED, AVOID DUPLICATED ENTRIES
	my %already_defined;
	my $already_defined;
	
	# CATEGORY 1
	if( defined $prog->{genre_1} ) {
		
		$writer->startTag( "category", "lang" => "de" );
		
		# EIT ENABLED AND FOUND = PRINT EIT + MARK EIT CATEGORY AS "ALREADY DEFINED"
		if( $genre eq "1" and defined $eit_db->{ $prog->{genre_1} } ) {
			
			$writer->characters( $eit_db->{ $prog->{genre_1} } );
			%already_defined = ( %already_defined, $eit_db->{ $prog->{genre_1} } => 1 );
			$already_defined = { category => \%already_defined };
			
		# EIT ENABLED BUT NOT FOUND
		} elsif( $genre eq "1" ) {
			
			# IF EIT IS NOT ALREADY DEFINED AS "MISSING" = PRINT VALUE + MARK EIT AS "MISSING"
			if( not defined $already_not_found->{category}->{ $prog->{genre_1} } ) {
				
				print "[W] Category (G) \"" . encode_utf8($prog->{genre_1}) . "\" not found in EIT list!\n";
				%already_not_found = ( %already_not_found, $prog->{genre_1} => 1 );
				$already_not_found = { category => \%already_not_found };
			}
			
			$writer->characters( $prog->{genre_1} );
			
		# EIT DISABLED = PRINT VALUE
		} else {
			
			$writer->characters( $prog->{genre_1} );
			
		}
		
		$writer->endTag( "category" );
		
	}
	
	# MULTIPLE CATEGORIES ENABLED
	if( $category eq "1" ) {
		
		# CATEGORY2
		if( defined $prog->{genre_2} ) {
			
			# EIT ENABLED AND FOUND
			if( $genre eq "1" and defined $eit_db->{ $prog->{genre_2} } ) {
				
				# EIT ENABLED AND FOUND + NOT PRINTED YET = PRINT EIT + MARK EIT CATEGORY AS "ALREADY DEFINED"
				if( not defined $already_defined->{category}->{ $eit_db->{ $prog->{genre_2} } } ) {
					
					$writer->startTag( "category", "lang" => "de" );
					$writer->characters( $eit_db->{ $prog->{genre_2} } );
					$writer->endTag( "category" );
					%already_defined = ( %already_defined, $eit_db->{ $prog->{genre_2} } => 1 );
					$already_defined = { category => \%already_defined };
					
				}
				
			# EIT ENABLED BUT NOT FOUND = PRINT VALUE +  MARK EIT AS "ALREADY NOT FOUND"
			} elsif( $genre eq "1" ) {
				
				# IF EIT IS NOT ALREADY DEFINED AS "MISSING" = PRINT VALUE + MARK EIT AS "MISSING"
				if( not defined $already_not_found->{category}->{ $prog->{genre_2} } ) {
					
					print "[W] Category (G) \"" . encode_utf8($prog->{genre_2}) . "\" not found in EIT list!\n";
					%already_not_found = ( %already_not_found, $prog->{genre_2} => 1 );
					$already_not_found = { category => \%already_not_found };
					
				}
				
				$writer->startTag( "category", "lang" => "de" );
				$writer->characters( $prog->{genre_2} );
				$writer->endTag( "category" );
				%already_defined = ( %already_defined, $prog->{genre_2} => 1 );
				$already_defined = { category => \%already_defined };
				
			# EIT DISABLED = PRINT VALUE
			} else {
				
				$writer->startTag( "category", "lang" => "de" );
				$writer->characters( $prog->{genre_2} );
				$writer->endTag( "category" );
				%already_defined = ( %already_defined, $prog->{genre_2} => 1 );
				$already_defined = { category => \%already_defined };
				
			}
			
		} 
	
		# CATEGORY3
		if( defined $prog->{genre_3} ) {
			
			# EIT ENABLED AND FOUND
			if( $genre eq "1" and defined $eit_db->{ $prog->{genre_3} } ) {
				
				# EIT ENABLED AND FOUND + NOT PRINTED YET = PRINT EIT
				if( not defined $already_defined->{category}->{ $eit_db->{ $prog->{genre_3} } } ) {
					
					$writer->startTag( "category", "lang" => "de" );
					$writer->characters( $eit_db->{ $prog->{genre_3} } );
					$writer->endTag( "category" );
					
				}
				
			# EIT ENABLED BUT NOT FOUND = PRINT VALUE
			} elsif( $genre eq "1" ) {
				
				# IF EIT IS NOT ALREADY DEFINED AS "MISSING" = PRINT VALUE + MARK EIT AS "MISSING"
				if( not defined $already_not_found->{category}->{ $prog->{genre_3} } ) {
					
					print "[W] Category (G) \"" . encode_utf8($prog->{genre_3}) . "\" not found in EIT list!\n";
					%already_not_found = ( %already_not_found, $prog->{genre_3} => 1 );
					$already_not_found = { category => \%already_not_found };
					
				}
				
				$writer->startTag( "category", "lang" => "de" );
				$writer->characters( $prog->{genre_3} );
				$writer->endTag( "category" );
				
			# EIT DISABLED = PRINT VALUE
			} else {
				
				$writer->startTag( "category", "lang" => "de" );
				$writer->characters( $prog->{genre_3} );
				$writer->endTag( "category" );
				
			}
			
		} 
		
	}
	
	# UNDEFINE CATEGORY RESEARCH PARAMS, PART 2
	undef %already_defined;
	undef $already_defined;
	
	# SEASON/EPISODE
	if( defined $prog->{series_number} or defined $prog->{episode_number} ) {
			
		my $series_no;
			
		if( not defined $prog->{series_number} and $episode eq "xmltv_ns" ) {
			$series_no  = 0;
		} elsif( defined $prog->{series_number} and $episode eq "xmltv_ns" ) {
			$series_no = ( $prog->{series_number} - 1 );
		} elsif( defined $prog->{series_number} and $episode eq "onscreen" ) {
			$series_no = "S" . $prog->{series_number};
		} else {
			undef $series_no;
		}
		
		my $episode_no;
		
		if( not defined $prog->{episode_number} and $episode eq "xmltv_ns" ) {
			$episode_no  = 0;
		} elsif( defined $prog->{episode_number} and $episode eq "xmltv_ns" ) {
			$episode_no = ( $prog->{episode_number} - 1 );
		} elsif( defined $prog->{episode_number} and $episode eq "onscreen" ) {
			$episode_no = "E" . $prog->{episode_number};
		} else {
			undef $episode_no;
		}
		
		$writer->startTag( "episode-num", "system" => $episode );
		
		if( $episode eq "xmltv_ns" ) {
			$writer->characters( "$series_no . $episode_no . " );
		} elsif( $episode eq "onscreen" and defined $series_no and defined $episode_no ) {
			$writer->characters( "$series_no $episode_no" );
		} elsif( $episode eq "onscreen" and defined $series_no and not defined $episode_no ) {
			$writer->characters( "$series_no" );
		} elsif( $episode eq "onscreen" and not defined $series_no and defined $episode_no ) {
			$writer->characters( "$episode_no" );
		}
		
		$writer->endTag( "episode-num" );
		
	}
			
	
	# AGE RATING
	if( defined $prog->{age} ) {
		$writer->startTag( "rating" );
		$writer->startTag( "value" );
		$writer->characters( $prog->{age} );
		$writer->endTag( "value" );
		$writer->endTag( "rating" );
	}
	
	$writer->endTag( "programme" );
	
}
	
# END
$writer->endTag("tv");
$writer->end();

print "\n=== EPG FILE CREATED! ===\n";
