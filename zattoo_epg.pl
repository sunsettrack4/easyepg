#!/usr/bin/perl

#      Copyright (C) 2020 Jan-Luca Neumann
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

# ###############################
# EASYEPG ZATTOO GRABBER MODULE #
# ###############################

# PERL MODULES
use strict;
use warnings;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::Escape;
use HTTP::Status;
use HTTP::Request::Params;
use HTTP::Request::Common;
use HTTP::Cookies;
use HTML::TreeBuilder;
use UI::Dialog;
use Parallel::ForkManager;
use Time::Piece;
use JSON;
use XML::Writer;
use IO::File;
use POSIX;


#
# LOGIN PROCESS: CREDENTIALS
#

# Check the login credentials required to use this provider. Check if the credentials file is available and contains all required/correct values.
	
# SET VALUES
my $provider;
my $login;
my $pass;
my $firstlogin;
	
# BUILD MENU
my $d = new UI::Dialog ( order => [ 'dialog', 'ascii' ] );

print "Loading userdata... ";
	
# CHECK IF FILE EXISTS
if( -e "userfile.json" ) {
	
	# READ JSON INPUT FILE: USERFILE
	my $userfile;
	{
		local $/; #Enable 'slurp' mode
		open my $dfh, "<", "userfile.json" or die;
		$userfile = <$dfh>;
		close $dfh;
	}
	
	# PARSE FILE
	my $userdata;
	eval{
		$userdata = decode_json($userfile);
	};
	
	# CHECK EXPECTED VALUES
	if( defined $userdata ) {
		$provider = $userdata->{"provider"};
		$login    = $userdata->{"login"};
		$pass     = $userdata->{"password"};
	}
	
	# EXPECTED VALUES UNAVAILABLE = REQUEST NEW DATA
	if( not defined $provider or not defined $login or not defined $pass ) {
		unlink "userfile.json";
		undef $provider;
		undef $login;
		undef $pass;
		$firstlogin = "true";
		print "Wrong login data (0)\n";
		
	# PROVIDER MUST BE A KNOWN ONE
	} elsif(    $provider eq "zattoo.com" or 
				$provider eq "www.1und1.tv" or 
				$provider eq "mobiltv.quickline.com" or
				$provider eq "tvplus.m-net.de" or
				$provider eq "player.waly.tv" or
				$provider eq "www.meinewelt.cc" or
				$provider eq "www.bbv-tv.net" or
				$provider eq "www.vtxtv.ch" or
				$provider eq "www.myvisiontv.ch" or
				$provider eq "iptv.glattvision.ch" or
				$provider eq "www.saktv.ch" or
				$provider eq "nettv.netcologne.de" or
				$provider eq "tvonline.ewe.de" or
				$provider eq "www.quantum-tv.com" or
				$provider eq "tv.salt.ch" or
				$provider eq "tvonline.swb-gruppe.de" or
				$provider eq "tv.eir.ie" ) {
					
					print "OK!\n\n";
					$firstlogin = "false";
	
	# IF PROVIDER DOMAIN IS UNKNOWN = REQUEST NEW DATA			
	} else {
		
		unlink "userfile.json";
		undef $provider;
		undef $login;
		undef $pass;
		$firstlogin = "true";
		print "Wrong login data (1)\n";
		
	}

# FILE DOES NOT EXIST = REQUEST NEW DATA
} else {
	
	$firstlogin = "true";

}
	
# SELECT PROVIDER, ENTER CREDENTIALS
if( $firstlogin eq "true" ) {
		
	# CHOOSE PROVIDER
	$provider = $d->menu(      title => 'PROVIDER SELECTION',
							   backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > PROVIDER',
							   text => 'Please select the provider domain:',
							   width => 55,
							   listheight => 13,
							   height => 15,
							   list => [ 'zattoo.com', 'Zattoo',
										 'www.1und1.tv', '1&1 TV',
										 'mobiltv.quickline.com', 'Quickline Mobil-TV',
										 'tvplus.m-net.de', 'M-net TVplus',
										 'player.waly.tv', 'WALY.TV',
										 'www.meinewelt.cc', 'Meine Welt unterwegs',
										 'www.bbv-tv.net', 'BBV TV',
										 'www.vtxtv.ch', 'VTX TV',
										 'www.myvisiontv.ch', 'myVision mobile TV',
										 'iptv.glattvision.ch', 'glattvision+',
										 'www.saktv.ch', 'SAK TV',
										 'nettv.netcologne.de', 'NetTV',
										 'tvonline.ewe.de', 'EWE TV App',
										 'www.quantum-tv.com', 'Quantum TV',
										 'tv.salt.ch', 'Salt TV',
										 'tvonline.swb-gruppe.de', 'swb TV App',
										 'tv.eir.ie', 'eir TV' ]
							  );
	
	# USER ABORTED THE PROCESS
	if( $provider eq "0" ) {
		die "Login process aborted (0)\n";
	}

	# ENTER LOGIN NAME (ZATTOO = EMAIL, RESELLER = USERNAME)
	if( $provider eq "zattoo.com" ) {
		$login = $d->inputbox( title => "ZATTOO | LOGIN PAGE",
							   height => 8,
							   width => 50,
							   backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
							   text => '\nPlease enter your email address:' );
	} else {
		$login = $d->inputbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
							   height => 8,
							   width => 50,
							   title => "$provider | LOGIN PAGE",
							   text => '\nPlease enter your username:' );
	}					   

	# ESCAPE LOGIN
	if( $login eq "0" ) {
		die "Login process aborted (1)\n";
	}

	# ZATTOO LOGIN MUST BE EMAIL
	if( $provider eq "zattoo.com" ) {
		until( $login =~ /(.*)@(.*).(.*)/ ) {
			$login = $d->inputbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
								   height => 8,
								   width => 50,
								   title => 'ZATTOO | LOGIN PAGE',
								   beepbefore => 1,
								   text => 'Wrong input detected!\nPlease enter your email address:',
								   entry => 'username@mail.com' );
			
			# ESCAPE LOGIN
			if( $login eq "0" ) {
				die "Login process aborted (2)\n";
			}

		}

	# PROVIDER LOGIN MUST NOT BE EMPTY
	} else {

		until( $login ne "" ) {

			$login = $d->inputbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
								   height => 8,
								   width => 50,
								   title => "$provider | LOGIN PAGE",
								   beepbefore => 1,
								   text => 'Empty input detected!\nPlease enter your username:',
								   entry => 'username' );
				
			# ESCAPE LOGIN
			if( $login eq "0" ) {
				die "Login process aborted (3)\n";
			}

		}

	}
					   
	# ENTER PASSWORD
	if( $provider eq "zattoo.com" ) {
		 $pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
							   height => 8,
							   width => 50,
							   title => 'ZATTOO | LOGIN PAGE',
							   text => "EMAIL: $login\nPlease enter your password:" );

	} else {

		$pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
							  height => 8,
							  width => 50,
							  title => "$provider | LOGIN PAGE",
							  text => "USER: $login\nPlease enter your password:" );

	}

	# PASSWORD MUST NOT BE EMPTY
	until( $pass ne "" ) {

		if( $provider eq "zattoo.com" ) {
			$pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
								  title => 'ZATTOO | LOGIN PAGE',
								  beepbefore => 1,
								  height => 8,
								  width => 50,
								  text => "Empty input detected!\nPlease enter your password:" );

		} else {

			$pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
								  title => "$provider | LOGIN PAGE",
								  beepbefore => 1,
								  height => 8,
								  width => 50,
								  text => "Empty input detected!\nPlease enter your password:" );

		}

	}
					
	# ESCAPE LOGIN
	if( $pass eq "0" ) {

		die "Login process aborted (4)\n";

	}

}


#
# LOGIN PROCESS: RETRIEVE COOKIE DATA
#

# Get beaker session cookie required for all upcoming URL requests of this provider. If credentials are wrong, request new data from the user.

# USE CREDENTIALS TO LOGIN TO WEBSERVICE, RETURN SESSION DATA
my $session;

# START LOGIN PROCESS, EVALUATE STATUS
eval{
     $session = login_process();
};

# IF LOGIN PROCESS DIED, EXIT SCRIPT
if( not defined $session ) {
	die "Exiting script due to error in login process.\n\n";
}

# RETRIEVE SESSION CONFIGRUATION FOR UPCOMING PROCESSES
my $powerid 	= $session->{powerid};
my $country 	= $session->{country};
my $login_token = $session->{login_token};

sub login_process {

	#
	# [SUB] LOGIN PROCESS
	#
	
	print "\rLogin to Zattoo webservice... ";
	
	# BUILD MENU
	my $d = new UI::Dialog ( order => [ 'dialog', 'ascii' ] );
	
	# SET VALUES TO BE DEFINED IN OUR LOGIN PROCESS
	my $login_success = "-";
	my $country;
	my $powerid;
	my $login_token;
	
	# LOGIN TO WEBSERVICE UNTIL RESULT IS SUCCESSFUL
	until( $login_success eq "true" ) {
		
		# GET APPTOKEN
		my $main_url;
		if( $provider eq "zattoo.com" ) {
			$main_url = "https://zattoo.com/int/";
		} else {
			$main_url = "https://$provider/";
		}
			
		my $main_agent    = LWP::UserAgent->new(
			agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
		);

		my $main_request  = HTTP::Request::Common::GET($main_url);
		my $main_response = $main_agent->request($main_request);

		if( $main_response->is_error ) {
			die "UNABLE TO LOGIN TO WEBSERVICE! (no internet connection / service unavailable)\n\nRESPONSE:\n\n" . $main_response->content . "\n\n";
		}
		
		# PARSE WEBPAGE TO GET APPTOKEN
		my $parser        = HTML::Parser->new;
		my $main_content  = $main_response->content;

		if( not defined $main_content) {
			die "UNABLE TO LOGIN TO WEBSERVICE! (empty webpage content)\n\n";
		}

		my $zattootree   = HTML::TreeBuilder->new;
		$zattootree->parse($main_content);

		if( not defined $zattootree) {
			die "UNABLE TO LOGIN TO WEBSERVICE! (unable to parse webpage)\n\n";
		}

		my @scriptvalues = $zattootree->look_down('type' => 'text/javascript');
		my $apptoken     = $scriptvalues[0]->as_HTML;
						
		if( defined $apptoken ) {
			$apptoken        =~ s/(.*window.appToken = ')(.*)(';.*)/$2/g;
		} else {
			die "UNABLE TO LOGIN TO WEBSERVICE! (unable to retrieve appToken)\n\n";
		}

		# GET TEMPORARY SESSION ID REQUIRED TO LOGIN
		my $session_url    = "https://$provider/zapi/session/hello";

		my $session_agent  = LWP::UserAgent->new(
			agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
		);

		my $session_request  = HTTP::Request::Common::POST($session_url, ['client_app_token' => uri_escape($apptoken), 'uuid' => uri_escape('d7512e98-38a0-4f01-b820-5a5cf98141fe'), 'lang' => uri_escape('en'), 'format' => uri_escape('json')]);
		my $session_response = $session_agent->request($session_request);
		my $session_token    = $session_response->header('Set-cookie');
						
		if( defined $session_token ) {
			$session_token       =~ s/(.*)(beaker.session.id=)(.*)(; Path.*)/$3/g;
		} else {
			die "UNABLE TO LOGIN TO WEBSERVICE! (unable to retrieve Session ID)\n\n";
		}

		if( $session_response->is_error ) {
			die "LOGIN FAILED! (invalid response)\n\nRESPONSE:\n\n" . $session_response->content . "\n\n";
		}

		# GET UNIQUE LOGIN COOKIE / SESSION ID
		my $login_url    = "https://$provider/zapi/v2/account/login";
						
		my $login_agent   = LWP::UserAgent->new(
			agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
		);
						
		my $cookie_jar    = HTTP::Cookies->new;
		$cookie_jar->set_cookie(0,'beaker.session.id',$session_token,'/',$provider,443);
		$login_agent->cookie_jar($cookie_jar);

		my $login_request  = HTTP::Request::Common::POST($login_url, ['login' => $login, 'password' => $pass ]);
		my $login_response = $login_agent->request($login_request);
		
		# LOGIN FAILED
		if( $login_response->is_error ) {
			
			# RE-ENTER LOGIN NAME
			if( $provider eq "zattoo.com" ) {
				$login = $d->inputbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
									   title => "ZATTOO | LOGIN PAGE",
									   height => 8,
									   width => 50,
									   beepbefore => 1,
									   text => 'Email or password incorrect!\nPlease re-enter your email address:' );
			} else {
				$login = $d->inputbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
									   title => "$provider | LOGIN PAGE",
									   height => 8,
									   width => 50,
									   beepbefore => 1,
									   text => 'Email or password incorrect!\nPlease re-enter your username:' );
			}					   

			# ESCAPE LOGIN
			if( $login eq "0" ) {
				die "Login process aborted (5)\n";
			}

			# ZATTOO LOGIN MUST BE EMAIL
			if( $provider eq "zattoo.com" ) {
				until( $login =~ /(.*)@(.*).(.*)/ ) {
					$login = $d->inputbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
										   title => 'ZATTOO | LOGIN PAGE',
										   height => 8,
										   width => 50,
										   text => 'Wrong input detected!\nPlease re-enter your email address:',
										   beepbefore => 1,
										   entry => 'username@mail.com' );
					
					# ESCAPE LOGIN
					if( $login eq "0" ) {
						die "Login process aborted (6)\n";
					}
				}
			# PROVIDER LOGIN MUST NOT BE EMPTY
			} else {
				until( $login ne "" ) {
					$login = $d->inputbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
										   title => "$provider | LOGIN PAGE",
										   height => 8,
										   width => 50,
										   text => 'Empty input detected!\nPlease re-enter your username:',
										   beepbefore => 1,
										   entry => 'username' );
					
					# ESCAPE LOGIN
					if( $login eq "0" ) {
						die "Login process aborted (7)\n";
					}
				}
			}
						   
			# RE-ENTER PASSWORD
			if( $provider eq "zattoo.com" ) {
				$pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
									  title => 'ZATTOO | LOGIN PAGE',
									  height => 8,
									  width => 50,
									  text => "EMAIL; $login\nPlease re-enter your password:" );
			} else {
				$pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
									  title => "$provider | LOGIN PAGE",
									  height => 8,
									  width => 50,
									  text => "USER: $login\nPlease re-enter your password:" );
			}
			
			# PASSWORD MUST NOT BE EMPTY
			until( $pass ne "" ) {
				if( $provider eq "zattoo.com" ) {
					$pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
										  title => 'ZATTOO | LOGIN PAGE',
										  beepbefore => 1,
										  height => 8,
										  width => 50,
										  text => 'Empty input detected!\nPlease re-enter your password:' );
				} else {
					$pass = $d->password( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > LOGIN',
										  title => "$provider | LOGIN PAGE",
										  beepbefore => 1,
										  height => 8,
										  width => 50,
										  text => 'Empty input detected!\nPlease re-enter your password:' );
				}
			}
						
			# ESCAPE LOGIN
			if( $pass eq "0" ) {
				die "Login process aborted (8)\n";
			}
			
			print "Login into webservice... ";
			
		} else {
			
			# LOGIN SUCCESSFUL
			print "LOGIN OK!";
			$login_success = "true";
			
			# SAVE SESSION COOKIE
			$login_token    = $login_response->header('Set-cookie');
			
			# VERIFY COOKIE DATA
			if( $login_token =~ /beaker.session.id/ ) {
				$login_token    =~ s/(.*)(beaker.session.id=)(.*)(; Path.*)/$3/g;
			} else {
				die "Unable to get Session ID from cookie\n";
			}
			
			# ANALYSE ACCOUNT
			my $analyse_login;
			
			eval{
				$analyse_login = decode_json($login_response->content);
			};

			if( not defined $analyse_login ) {
				die "Unable to parse user data\n";
			}
			
			# SAVE ACCOUNT INFORMATION
			$powerid        = $analyse_login->{"session"}->{"power_guide_hash"};
			if( $provider eq "zattoo.com" ) {
				$country        = $analyse_login->{"session"}->{"service_region_country"};
			} else {
				$country		= "XX";
			}
			
			# VERIFY ACCOUNT VARIABLES
			if( not defined $powerid or not defined $country ) {
				die "Unable to define account variables\n";
			}
			
			# CREATE JSON PARAMS
			my $login_json    = to_json( { provider => $provider, login => $login, password => $pass }, { pretty => 1 });
			
			# SAVE JSON TO FILE
			open(my $fhc, '>', 'userfile.json'); # LOGIN DATA
			print $fhc $login_json;
			close $fhc;
		}
	}
	
	# RETURN UPDATED CREDENTIALS AND SESSION CONFIGURATIONS
	$session = { powerid => $powerid, country => $country, login_token => $login_token };
	return $session;
	
}


#
# CHANNEL LIST 
#
	
# Check if channels.json file can be found and parsed. If condition is false, download and parse latest Zattoo channel list and present a checklist to the user.
# The channel list must be checked for duplicates. If channel name is duplicated, append count number to the name. If channel ID is duplicated, remove the duplicated entry.
# To recognize changed channel names or IDs, a comparism list will be created. Additionally, a set of default EPG settings will be saved into another file.

sub chlist_request {
	
	#
	# [SUB] CHANNEL LIST 
	#
	
	# URL
	my $channel_url = "https://$provider/zapi/v3/cached/$powerid/channels?";

	# COOKIE
	my $cookie_jar    = HTTP::Cookies->new;
	$cookie_jar->set_cookie(0,'beaker.session.id',$login_token,'/',$provider,443);
	
	# CHANNEL M3U REQUEST
	my $channel_agent = LWP::UserAgent->new(
		agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
	);
					
	$channel_agent->cookie_jar($cookie_jar);
	my $channel_request  = HTTP::Request::Common::GET($channel_url);
	my $channel_response = $channel_agent->request($channel_request);
			
	if( $channel_response->is_error ) {
		die "ERROR: Channel URL: Invalid response\n\nRESPONSE:\n\n" . $channel_response->content . "\n\n";
	}

	# READ JSON
	my $ch_file;
		
	eval{
		$ch_file    = decode_json($channel_response->content);
	};
						
	if( not defined $ch_file ) {
		die "ERROR: Failed to parse JSON file: Channel list\n\n";
	}
	
	my $ch_file_check = $ch_file->{channels}[0];
	
	if( not defined $ch_file_check->{cid} or not defined $ch_file_check->{title} ) {
		die "ERROR: Failed to retrieve channel name or ID in file checker\n\n";
	}
	
	return $ch_file;
	
}

# DEFINE SELECTED CHANNELS
my @ch_selection;

if( -e "channels.json" ) {
	
	# READ JSON INPUT FILE: CHANNELS FILE
	my $channelsfile;
	{
		local $/; #Enable 'slurp' mode
		open my $efh, "<", "channels.json" or die;
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
		open my $ffh, "<", "chconfig.json" or die;
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
if( $firstlogin eq "true" ) {
	
	# DEFINE FILE VALUE
	my $ch_file;
	
	# START CHANNEL LIST REQUEST
	eval{
		$ch_file = chlist_request();
	};
	
	# CHECK IF CHANNEL LIST WAS RECEIVED
	if( not defined $ch_file ) {
		die "Exiting script due to missing channels file.\n";
	}

	# RETRIEVE DATA FROM CHANNEL LIST
	my @ch_groups = @{ $ch_file->{'channels'} };
	
	# SET UP VALUES FOR UPCOMING PROCESSES
	my @channels;
	my @duplicate_check;
	my @cid_check;
	my %name2id;
	my %id2name;

	foreach my $ch_groups ( sort { $a->{"title"} cmp $b->{"title"} } @ch_groups ) {
		my $cid   = $ch_groups->{"cid"};
		my $cname = $ch_groups->{"title"};
		
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
	@ch_selection = $d->checklist( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > CHANNEL LIST',
								   title => "$provider | CHANNEL LIST",
								   listheight => 13,
								   height => 15,
								   width => 55,
								   text => 'Please choose the channels you want to grab:',
								   list => [ @channels ]
								 );
		
	# ABORT PROCESS IF CHECKLIST RETURNS WITH ZERO ENTRIES OR WITH RESULT "0"
	if( @ch_selection == 1 ) {
		foreach my $ch_selection ( @ch_selection ) {
			if( $ch_selection eq "0" ) {
				die "\rChannel selection aborted\n";
			}
		}
	} elsif( ! @ch_selection ) {
		die "\rChannel selection aborted: No channel selected\n";
	}
	
	# SET ID CHECK DATA
	$old_name2id = { %name2id };
	$old_id2name = { %id2name };

	# CREATE JSON PARAMS
	my $channels_json = to_json( { channels => \@ch_selection }, { pretty => 1 } );	# SELECTED CHANNELS
	my $idcheck_json  = to_json( { new_name2id => \%name2id, new_id2name => \%id2name }, { pretty => 1 } );	# COMPARISM LIST
	my $epg_json      = to_json( { day => 7, cid => 0, genre => 1, category => 1, episode => "xmltv_ns", forks => 16, simple => 0 }, { pretty => 1 });	# EPG DEFAULT SETTINGS

	# SAVE JSON TO FILE
	open(my $fha, '>', 'channels.json'); # SELECTED CHANNELS
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
	$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > CHANNEL LIST',
				title => "$provider | CHANNEL LIST",
				height => 5,
				width => 40,
				text => 'Channel list saved successfully!'
			  );

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
		open my $fh, "<", "epgconfig.json" or die;
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
			print "\nINVALID SETTING: DAY NUMBER (0)";
			$day = 7;
		}
	} else {
		print "\nINVALID SETTING: DAY NUMBER (1)";
		$day = 7;
	}
		
	# CHECK RYTEC FORMAT SETTING
	if( defined $epgconfdata->{cid} ) {
		if( $epgconfdata->{cid} == 0 or $epgconfdata->{cid} == 1 ) {
			$cid = $epgconfdata->{cid};
		} else {
			print "\nINVALID SETTING: RYTEC FORMAT (0)";
			$cid = 0;
		}
	} else {
		print "\nINVALID SETTING: RYTEC FORMAT (1)";
		$cid = 0;
	}
	
	# CHECK EIT FORMAT SETTING
	if( defined $epgconfdata->{genre} ) {
		if( $epgconfdata->{genre} == 0 or $epgconfdata->{genre} == 1 ) {
			$genre = $epgconfdata->{genre};
		} else {
			print "\nINVALID SETTING: EIT FORMAT (0)";
			$genre = 1;
		}
	} else {
		print "\nINVALID SETTING: EIT FORMAT (1)";
		$genre = 1;
	}
		
	# CHECK MULTIPLE CATEGORIES SETTING
	if( defined $epgconfdata->{category} ) {
		if( $epgconfdata->{category} == 0 or $epgconfdata->{category} == 1 ) {
			$category = $epgconfdata->{category};
		} else {
			print "\nINVALID SETTING: MULTIPLE CATEGORIES (0)";
			$category = 1;
		}
	} else {
		print "\nINVALID SETTING: MULTIPLE CATEGORIES (1)";
		$category = 1;
	}
	
	# CHECK EPISODE FORMAT SETTING
	if( defined $epgconfdata->{episode} ) {
		if( $epgconfdata->{episode} eq "xmltv_ns" or $epgconfdata->{episode} eq "onscreen" ) {
			$episode = $epgconfdata->{episode};
		} else {
			print "\nINVALID SETTING: EPISODE FORMAT (0)";
			$episode = "xmltv_ns";
		}
	} else {
		print "\nINVALID SETTING: EPISODE FORMAT (1)";
		$episode = "xmltv_ns";
	}
	
	# CHECK FORKS NUMBER
	if( defined $epgconfdata->{forks} ) {
		if( $epgconfdata->{forks} >= 1 and $epgconfdata->{forks} <= 64 ) {
			$forks = $epgconfdata->{forks};
		} else {
			print "\nINVALID SETTING: FORKS NUMBER (0)";
			$forks = 16;
		}
	} else {
		print "\nINVALID SETTING: FORKS NUMBER (1)";
		$forks = 16;
	}
	
	# CHECK SIMPLE GRABBER MODE
	if( defined $epgconfdata->{simple} ) {
		if( $epgconfdata->{simple} == 0 or $epgconfdata->{simple} == 1 ) {
			$simple = $epgconfdata->{simple};
		} else {
			print "\nINVALID SETTING: GRABBER MODE (0)";
			$simple = 0;
		}
	} else {
		print "\nINVALID SETTING: GRABBER MODE (1)";
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
# ASK USER
#

# Check if user wants to enter the menu. This check will be skipped if user logged in for the first time.

# SET SELECTION VALUE FOR MAIN MENU
my $selection;

if( $firstlogin ne "true" ) {
	
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
 
	print "\n\nPlease hit a button to enter the settings within 5 seconds... ";

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
# MAIN MENU
#
	
# Change the EPG settings and modify the channel list.

# RUN MENU UNTIL USER ABORTS THE PROCESS OR RUNS THE XML SCRIPT
until( $selection eq "0" or $selection eq "7" ) {
	
	# MENU
	$selection = $d->menu( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS',
						   title => "$provider | SETTINGS",
						   listheight => 13,
						   height => 17,
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
									 '9', "SIMPLE GRABBER MODE (enabled: $simple)",
									 'R', 'REMOVE GRABBER INSTANCE' ] );
		
	# ABORT
	if( $selection eq "0" ) {
			
		die "User left menu\n";
	
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
			die "\rExiting script due to missing channels file.\n";
		}

		# RETRIEVE DATA FROM CHANNEL LIST
		my @ch_groups = @{ $menu_ch_file->{'channels'} };
		
		# SET UP VALUES OF NEW CHANNEL LIST
		my @menu_ch_groups = @{ $menu_ch_file->{'channels'} };
		my @duplicate_check;
		my @new_channels;
		my @cid_check;
		my %name2id;
		my %id2name;

		foreach my $ch_groups ( sort { $a->{"title"} cmp $b->{"title"} } @menu_ch_groups ) {
			my $cid   = $ch_groups->{"cid"};
			my $cname = $ch_groups->{"title"};
			
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
		my %applied_channels;
		my @channels;
		
		foreach my $old_channel ( @ch_selection ) {
			
			# OLD CHANNEL NAME IN NEW CHANNEL LIST? - YES: CREATE MENU ENTRY - NO: CHECK FURTHER
			if( defined $new_name2id->{$old_channel} ) {
				
				my @channels_new = ( $old_channel, [ $new_name2id->{$old_channel}, 1 ] );
				push( @channels, @channels_new );
				%applied_channels = ( %applied_channels, $old_channel => 1 );
				
			# OLD ID OF OLD CHANNEL NAME IN NEW CHANNEL LIST? - YES: CHECK FURTHER - NO: NOTHING
			} elsif( defined $new_id2name->{ $old_name2id->{$old_channel} } ) {
				
				# OTHER OLD CHANNEL NAME WITH OLD ID OF THE ACTUAL CHANNEL NAME IN NEW CHANNEL LIST? - YES: NOTHING - NO: CREATE MENU ENTRY
				if( not defined $old_name2id->{ $new_id2name->{ $old_name2id->{$old_channel} } } ) {
					
					my @channels_new = ( $new_id2name->{ $old_name2id->{$old_channel} }, [ $old_name2id->{$old_channel}, 1 ] );
					push( @channels, @channels_new );
					%applied_channels = ( %applied_channels, $old_name2id->{$old_channel} => 1 );
					
				}
				
			}
						
		}
			
		my $applied_channels = { known => { %applied_channels } };
			
		foreach my $new_channel ( @new_channels ) {
				
			# NEW CHANNEL NAME ALREADY DEFINED IN MENU?
			if( not defined $applied_channels->{known}->{$new_channel} ) {
					
				my @channels_new = ( $new_channel, [ $new_name2id->{$new_channel}, 0 ] );
				push( @channels, @channels_new );
					
			}
				
		}
			
		# MENU
		my @new_ch_selection = $d->checklist( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CHANNEL LIST',
								   title => "$provider | CHANNEL LIST",
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
			
			# SAVE NEW CHANNEL CONFIGURATION 
			undef @ch_selection;
			push( @ch_selection, @new_ch_selection );
			$old_id2name = { %id2name };
			$old_name2id = { %name2id };
			
			# CREATE JSON PARAMS
			my $channels_json = to_json( { channels => \@ch_selection }, { pretty => 1 } );	# SELECTED CHANNELS
			my $idcheck_json  = to_json( { new_name2id => \%name2id, new_id2name => \%id2name }, { pretty => 1 } );	# COMPARISM LIST

			# SAVE JSON TO FILE
			open(my $fha, '>', 'channels.json'); # SELECTED CHANNELS
			print $fha $channels_json;
			close $fha;
			
			open(my $fhb, '>:utf8', 'chconfig.json'); # CHANNEL IDs
			print $fhb $idcheck_json;
			close $fhb;
				
			# SUCCESS MESSAGE
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CHANNEL LIST',
						title => "$provider | CHANNEL LIST",
						height => 5,
						width => 40,
						text => 'Channel list saved successfully!'
					  );
		
		}
		
	# TIME PERIOD
	} elsif( $selection eq "2" ) {
			
		my $day_old = $day;
			
		# MENU
		$day = $d->menu( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > TIME PERIOD',
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
				
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > TIME PERIOD', 
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
				
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > TIME PERIOD', 
						title     => 'INFO', 
						height    => 5,
						width     => 42,
						text      => "EPG grabber enabled for $day day(s)!" );
		}
		
	# CONVERT CHANNEL IDs INTO RYTEC FORMAT
	} elsif( $selection eq "3" ) {
			
		# MENU
		$cid = $d->yesno( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CONVERT CHANNEL IDs',
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
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CONVERT CHANNEL IDs', 
						title     => 'INFO', 
						height    => 5,
						width     => 30,
						text      => "Rytec Channel IDs enabled!" );
			
		# NO
		} else {
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CONVERT CHANNEL IDs', 
						title     => 'INFO', 
						height    => 5,
						width     => 32,
						text      => "Rytec Channel IDs disabled!" );
		
		}
		
	# CONVERT CATEGORIES INTO EIT FORMAT
	} elsif( $selection eq "4" ) {
			
		# MENU
		$genre = $d->yesno( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CONVERT CATEGORIES',
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

			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CONVERT CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 30,
						text      => "EIT categories enabled!" );
			
		# NO
		} else {
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > CONVERT CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 32,
						text      => "EIT categories disabled!" );
		
		}
		
	# USE MULTIPLE CATEGORIES
	} elsif( $selection eq "5" ) {
		
		# MENU
		$category = $d->yesno( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > MULTIPLE CATEGORIES',
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
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > MULTIPLE CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 35,
						text      => "Multiple categories enabled!" );
			
		# NO
		} else {
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > MULTIPLE CATEGORIES', 
						title     => 'INFO', 
						height    => 5,
						width     => 35,
						text      => "Multiple categories disabled!" );
		
		}
			
	# EPISODE FORMAT
	} elsif( $selection eq "6" ) {
			
		my $episode_old = $episode;
			
		# MENU
		$episode = $d->menu( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > EPISODE FORMAT',
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
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > EPISODE FORMAT', 
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
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > EPISODE FORMAT', 
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
		$forks = $d->menu( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > NUMBER OF FORKS',
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
						                 '32', '32 forks',
						                 '64', '64 forks' ] );
			
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
				
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > NUMBER OF FORKS', 
						title     => 'INFO', 
						height    => 5,
						width     => 42,
						text      => "EPG grabber enabled with $forks fork(s)!" );
		}
	
	# SIMPLE GRABBER MODE
	} elsif( $selection eq "9" ) {
		
		# MENU
		$simple = $d->yesno( backtitle  => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > SIMPLE GRABBER MODE',
					         title      => 'SIMPLE GRABBER MODE',
						     height     => 6,
						     width      => 60,
						     text       => 'Do you want to use simple grabber mode?\nMissing data: Description, credits, year, country etc.' );
			
		# CREATE JSON PARAMS
		my $epg_json      = to_json( { day => $day, cid => $cid, genre => $genre, category => $category, episode => $episode, forks => $forks, simple => $simple }, { pretty => 1 });
			
		open(my $fh, '>', 'epgconfig.json'); # EPG CONFIG DATA
		print $fh $epg_json;
		close $fh;
			
		# YES
		if( $simple eq "1" ) {				
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > SIMPLE GRABBER MODE', 
						title     => 'INFO', 
						height    => 5,
						width     => 35,
						text      => "Simple grabber mode enabled!" );
			
		# NO
		} else {
			
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > SIMPLE GRABBER MODE', 
						title     => 'INFO', 
						height    => 5,
						width     => 35,
						text      => "Simple grabber mode disabled!" );
		
		}
	
	# REMOVE GRABBER INSTANCE
	} elsif( $selection eq "R" ) {
			
		my $delete = $d->yesno( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > DELETE INSTANCE',
								title     => 'WARNING',
								height    => 5,
								width     => 50,
								text      => 'Do you want to delete this service?' );
				   
		if( $delete eq "1" ) {
			
			unlink "userfile.json";
			unlink "channels.json";
			unlink "chconfig.json";
			unlink "epgconfig.json";
					
			$d->msgbox( backtitle => '* EASYEPG SIMPLE XMLTV GRABBER > ZATTOO > SETTINGS > DELETE INSTANCE', 
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
my @ch_groups = @{ $dl_ch_file->{'channels'} };

# SET UP VALUES OF NEW CHANNEL LIST
my @dl_ch_groups = @{ $dl_ch_file->{'channels'} };
my @duplicate_check;
my @cid_check;
my %name2id;
my %id2name;

foreach my $ch_groups ( @dl_ch_groups ) {
	
	my $cid   = $ch_groups->{"cid"};
	my $cname = $ch_groups->{"title"};
	
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
			
	}

}

# SET NEW CONFIGURATION LISTS
my $new_name2id = { %name2id };
my $new_id2name = { %id2name };

### CHECK CONFIGURATION, COMPARE OLD/NEW CHANNEL ID DATA

my %ch_config;

foreach my $old_channel ( @ch_selection ) {
	
	# DEFINE NEW ID/NAME KEY
	my %ch_config_new;
	
	# OLD CHANNEL NAME IN NEW CHANNEL LIST?
	if( defined $new_name2id->{$old_channel} ) {
		
		%ch_config_new = ( $new_name2id->{$old_channel} => $old_channel );
		%ch_config     = ( %ch_config, %ch_config_new );
		
		if( $new_name2id->{$old_channel} ne $old_name2id->{$old_channel} ) {
			
			print "[I] Channel " . $old_channel . "received new ID " . $new_name2id->{$old_channel} . "!\n";
			
		}
	
	# OLD CHANNEL NAME IN OLD CHANNEL LIST?
	} elsif( not defined $old_name2id->{$old_channel} ) {
		
			print "[W] Channel " . $old_channel . " not found in configuration files!\n";
				
	# OLD ID OF OLD CHANNEL NAME IN NEW CHANNEL LIST? - YES: CHECK FURTHER - NO: NOTHING
	} elsif( defined $new_id2name->{ $old_name2id->{$old_channel} } ) {
			
		# OTHER OLD CHANNEL NAME WITH OLD ID OF THE ACTUAL CHANNEL NAME IN NEW CHANNEL LIST? - YES: NOTHING - NO: CREATE MENU ENTRY
		if( not defined $old_name2id->{ $new_id2name->{ $old_name2id->{$old_channel} } } ) {
			
			%ch_config_new = ( $old_name2id->{$old_channel} => $old_channel );
			%ch_config     = ( %ch_config, %ch_config_new );
			
			print "[I] Channel " . $old_channel . "received new channel name " . $new_id2name->{ $old_name2id->{$old_channel} } . "!\n";
			
		} else {
			
			print "[W] Renamed channel " . $old_channel . "already exists in old channel configuration!\n";
			
		}
			
	}
				
}

my $ch_config = { channels => \%ch_config };

### DOWNLOAD MAIN PROGRAMME LISTS

# DATES
my @time_values;

foreach my $time_value ( 1 .. $day ) {
	
	my $time_start  = gmtime() + ( 86400 * ( $time_value - 1 ) );
	my $time_end    = gmtime() + ( 86400 * ( $time_value ) );

	my $time_start_date   = $time_start->ymd . " 06:00";
	my $time_end_date     = $time_end->ymd . " 06:00";
	
	my $time_start_secs   = Time::Piece->strptime( "$time_start_date", "%Y-%m-%d %H:%M" );
	my $time_end_secs     = Time::Piece->strptime( "$time_end_date", "%Y-%m-%d %H:%M" );

	my $start_epoch  = $time_start_secs->strftime("%s");
	my $end_epoch    = $time_end_secs->strftime("%s");
	
	my @time = ( { start => $start_epoch, end => $end_epoch } );
	
	push( @time_values, @time );

}


# PARALLEL FORK MANAGER - SETUP
my @programme_listings;
my $pm = Parallel::ForkManager->new($forks);
my $counter = 0;

$pm->run_on_finish(
	
	sub {
		
		my( $pid, $exit_code, $ident, $signal, $core, $ds ) = @_;
		
		if( not defined $ds ) {
			die "[E] No datastructure received from child process (guide download)!\n";
		} else {
			$counter = ( $counter + 1);
			my $percentage = ( $counter / $day ) * 100;
			$percentage = POSIX::round($percentage);
			print "\r[I] Processing download: $percentage%";
		}
		
		push( @programme_listings, @{ $ds->{results} } );
		
	}
	
);

# START DOWNLOAD

print "* Downloading guides...\n\n";

foreach my $time ( @time_values ) {
	
	$pm->start and next;
	
	my $start = $time->{start};
	my $end   = $time->{end};
	
	my @listings;
	
	# URL
	my $guide_url = "https://$provider/zapi/v3/cached/$powerid/guide?start=$start&end=$end";
	
	# COOKIE
	my $cookie_jar    = HTTP::Cookies->new;
	$cookie_jar->set_cookie(0,'beaker.session.id',$login_token,'/',$provider,443);
	
	# CHANNEL M3U REQUEST
	my $guide_agent = LWP::UserAgent->new(
		agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
	);
					
	$guide_agent->cookie_jar($cookie_jar);
	my $guide_request  = HTTP::Request::Common::GET($guide_url);
	my $guide_response = $guide_agent->request($guide_request);
			
	if( $guide_response->is_error ) {
		die "ERROR: Guide URL: Invalid response\n\nRESPONSE:\n\n" . $guide_response->content . "\n\n";
	}

	# READ JSON
	my $guide_file;
		
	eval{
		$guide_file    = decode_json($guide_response->content);
	};
						
	if( not defined $guide_file ) {
		die "ERROR: Failed to parse JSON file: Guide\n\n";
	}
	
	my $guide_file_check = $guide_file->{channels};
	
	if( not defined $guide_file_check ) {
		die "ERROR: Failed to retrieve guide data\n\n";
	}
	
	# FOR EACH SELECTED CHANNEL ID...
	foreach my $channel ( keys %{ $ch_config->{channels} } ) {

		my @ch_guide;
		
		# ...CHECK IF THE CHANNEL IS AVAILABLE IN THE LIST
		if( defined $guide_file->{channels}->{$channel} ) {
			
			@ch_guide = @{ $guide_file->{channels}->{$channel} };
			
			# ...CHECK IF CHANNEL CONTAINS DATA
			if( @ch_guide ) {
				
				# ...GET THE CHANNEL'S DATA
				foreach my $ch_guide_info ( @ch_guide ) {
			
					my $start 			= $ch_guide_info->{s};
					my $end   			= $ch_guide_info->{e};
					my $startTIME 		= gmtime($start)->strftime('%Y%m%d%H%M%S') . ' +0000';
					my $endTIME   		= gmtime($end)->strftime('%Y%m%d%H%M%S') . ' +0000';
					my $title 			= $ch_guide_info->{t};
					my $episode_title 	= $ch_guide_info->{et};
					my $episode_number 	= $ch_guide_info->{e_no};
					my $series_number 	= $ch_guide_info->{s_no};
					my $image 			= $ch_guide_info->{i_url};
					my $category        = $ch_guide_info->{c};
					my $genre           = $ch_guide_info->{g};
					my $id	            = $ch_guide_info->{id};
					
					# ...APPEND DATA
					if( not defined $start or not defined $end or not defined $title or not defined $id ) {
						die "[E] Missing required data from guide programmes!\n";
					}
					
					my %data = ( channel => $channel, start => $startTIME, end => $endTIME, title => $title, id => $id );
					
					if( defined $episode_title ) {
						%data = ( %data, episode_title => $episode_title );
					}
					
					if( defined $episode_number ) {
						%data = ( %data, episode_number => $episode_number );
					}
					
					if( defined $series_number ) {
						%data = ( %data, series_number => $series_number );
					}
					
					if( defined $image ) {
						%data = ( %data, image => $image );
					}
					
					if( defined $category ) {
						
						my @category = @{ $category };
					
						if( defined $category[0] ) {
							%data = ( %data, category_1 => $category[0] );
						}
								
						if( defined $category[1] ) {
							%data = ( %data, category_2 => $category[1] );
						}
						
						if( defined $category[2] ) {
							%data = ( %data, category_3 => $category[2] );
						}
					
					}
					
					if( defined $genre ) {
						
						my @genre = @{ $genre };
					
						if( defined $genre[0] ) {
							%data = ( %data, genre_1 => $genre[0] );
						}
								
						if( defined $genre[1] ) {
							%data = ( %data, genre_2 => $genre[1] );
						}
						
						if( defined $genre[2] ) {
							%data = ( %data, genre_3 => $genre[2] );
						}
						
					}
					
					push( @listings, { %data } );
					
				}
				
			}
			
		}	
		
	}
	
	$pm->finish( 0, { results => \@listings } );
	
}

$pm->wait_all_children();

print "\r[I] Processing download: 100%\n\n";

my $programme_details;

if( $simple eq "0") {

	### PREPARING DETAILS DOWNLOAD - GET ARRAY OF 620 ID-ELEMENTS

	print "* Preparing details download...\n\n";

	my $programme_counter = 0;
	my $programme_element;
	my @element;

	# FOREACH PROGRAMME ELEMENT...
	foreach my $listing ( @programme_listings ) {
		
		# ...GET PROGRAMME ID
		my $programme_id = $listing->{id};
		
		# ...SET FIRST ID INTO STRING
		if( $programme_counter == 0 ) {
			
			$programme_element = $programme_id;
			$programme_counter = 1;
			
		# ...APPEND NEXT ID INTO STRING
		} else {
			
			$programme_element = $programme_element . "," . $programme_id;
			$programme_counter = ( $programme_counter + 1 );
		}
		
		# PUSH ID STRING INTO ARRAY, UNDEFINE STRING, RESET COUNTER
		if( $programme_counter == 620 ) {
			
			push( @element, ( $programme_element ) );
			undef $programme_element;
			$programme_counter = 0;
			
		}

	}

	# IF ARRAY ELEMENT COULD NOT REACH 620 IDs - PUSH LAST STRING INTO ARRAY
	if( defined $programme_element ) {
		push( @element, ( $programme_element ) );
	}

	if( ! @element ) {
		die "[E] Programme element array is empty!\n";
	}


	### DOWNLOAD PROGRAMME DETAILS

	print "* Downloading programme details...\n\n";

	# PARALLEL FORK MANAGER - SETUP
	my $pm2 = Parallel::ForkManager->new($forks);
	my %programme_details;
	my $size = @element;
	my $pm2_counter = 0;

	$pm2->run_on_finish(
		
		sub {
			
			my( $pid, $exit_code, $ident, $signal, $core, $ds ) = @_;
			
			if( not defined $ds ) {
				die "[E] No datastructure received from child process (programme download)!\n";
			} else {
				$pm2_counter = ( $pm2_counter + 1 );
				my $percentage = ( $pm2_counter / $size ) * 100;
				$percentage = POSIX::round($percentage);
				print "\r[I] Processing download: $percentage% ($pm2_counter/$size)";
			}
			
			%programme_details = ( %programme_details, %{ $ds->{results} } );
		}
		
	);

	foreach my $element ( @element ) {
		
		$pm2->start and next;
		
		my %listings_final;
		
		# URL
		my $programme_url = "https://$provider/zapi/v2/cached/program/power_details/$powerid?program_ids=$element";
		
		# COOKIE
		my $cookie_jar    = HTTP::Cookies->new;
		$cookie_jar->set_cookie(0,'beaker.session.id',$login_token,'/',$provider,443);
		
		# CHANNEL M3U REQUEST
		my $programme_agent = LWP::UserAgent->new(
			agent => "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:54.0) Gecko/20100101 Firefox/72.0"
		);
						
		$programme_agent->cookie_jar($cookie_jar);
		my $programme_request  = HTTP::Request::Common::GET($programme_url);
		my $programme_response = $programme_agent->request($programme_request);
				
		if( $programme_response->is_error ) {
			die "ERROR: Programme URL: Invalid response\n\nRESPONSE:\n\n" . $programme_response->content . "\n\n";
		}

		# READ JSON
		my $programme_file;
			
		eval{
			$programme_file    = decode_json($programme_response->content);
		};
							
		if( not defined $programme_file ) {
			die "ERROR: Failed to parse JSON file: Programme\n\n";
		}
		
		my $programme_file_check = $programme_file->{programs};
		
		if( not defined $programme_file_check ) {
			die "ERROR: Failed to retrieve programme data\n\n";
		}
		
		my @programme;
		
		eval{
			@programme = @{ $programme_file->{programs} };
		};
		
		if( ! @programme ) {
			die "ERROR: Failed to verify programme array data\n\n";
		}
		
		# FOR EACH SELECTED CHANNEL ID...
		foreach my $programme ( @programme ) {
			
			my %listings;
			
			my $id          = $programme->{id};
			my $description = $programme->{d};
			my $year        = $programme->{year};
			my $country     = $programme->{country};
			my $age         = $programme->{yp_r};
			my $director    = $programme->{cr}->{director};
			my $actor       = $programme->{cr}->{actor};
			
			# ...CHECK IF DESCRIPTION IS AVAILABLE IN THE LIST
			if( defined $description ) {
				%listings = ( %listings, description => $description );
			}
			
			# ...CHECK IF YEAR IS AVAILABLE IN THE LIST
			if( defined $year ) {
				%listings = ( %listings, year => $year );
			}
			
			# ...CHECK IF COUNTRY IS AVAILABLE IN THE LIST
			if( defined $country ) {
				%listings = ( %listings, country => $country );
			}
			
			# ...CHECK IF AGE RATING IS AVAILABLE IN THE LIST
			if( defined $age ) {
				%listings = ( %listings, age => $age );
			}
			
			# ...CHECK IF DIRECTOR IS AVAILABLE IN THE LIST
			if( defined $director ) {
				my @director;
				
				eval{ 
					@director = @{ $director };
				};
				
				if( @director ) {
					%listings = ( %listings, director => \@director );
				}
			}
			
			# ...CHECK IF ACTOR IS AVAILABLE IN THE LIST
			if( defined $actor ) {
				my @actor = @{ $actor };
				
				eval{
					@actor = @{ $actor };
				};
				
				if( @actor ) {
					%listings = ( %listings, actor => \@actor );
				}
				
			}
			
			%listings_final = ( %listings_final, $id => \%listings );
			
		}		
		
		$pm2->finish( 0, { results => \%listings_final } );
		
	}

	$pm2->wait_all_children();

	$programme_details = { %programme_details };
	
}

print "\n\n=== FILE CREATION PROCESS ===\n\n* Preparing EPG file creation...\n\n";

### DOWNLOAD RYTEC

# URL
my $rytec_url = "https://raw.githubusercontent.com/sunsettrack4/config_files/master/ztt_channels.json";

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

my $rytec_db = $rytec_file->{channels}->{$country};

if( not defined $rytec_db ) {
	print "[W] Failed to retrieve Rytec data\n";
}


### DOWNLOAD EIT GENRE

# URL
my $eit_url = "https://raw.githubusercontent.com/sunsettrack4/config_files/master/ztt_genres.json";

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

my $eit_db = $eit_file->{categories}->{$country};

if( not defined $eit_db ) {
	print "[W] Failed to retrieve EIT data\n";
}


#
# CREATE XML FILE
#

print "* Creating EPG file...\n\n";

# DECLARE OUTPUT FILE
my $output = IO::File->new(">zattoo.xml");
 
# CREATE WRITER OBJECT
my $writer = XML::Writer->new(OUTPUT => $output, DATA_MODE => 1, ENCODING => 'utf-8' );

# FIRST DECLARATION
$writer->xmlDecl("UTF-8");

# TV
$writer->startTag("tv");

# CHANNEL LIST
my %ch_keys = %{ $ch_config->{channels} };

foreach my $channel ( sort { lc $a cmp lc $b } keys %ch_keys ) {
	
	if( $cid eq "1" and defined $rytec_db->{ $ch_keys{$channel} } ) {
		$writer->startTag( "channel", "id" => $rytec_db->{ $ch_keys{$channel} } );
	} elsif( $cid eq "1" ) {
		print "[W] Channel \"" . $ch_keys{$channel} . "\" not found in Rytec ID list!\n";
		$writer->startTag( "channel", "id" => $ch_keys{$channel} );
	} else {
		$writer->startTag( "channel", "id" => $ch_keys{$channel} );
	}
	
	$writer->startTag( "display-name", "lang" => "de" );
	
	$writer->characters( $ch_keys{$channel} );
	
	$writer->endTag( "display-name" );
	
	$writer->endTag( "channel" );
	
}

# CATEGORY RESEARCH PARAMS, PART 1 - CHECK IF EIT WAS ALREADY MISSING, AVOID DUPLICATED WARNING MESSAGES
my %already_not_found;
my $already_not_found;

# PROGRAMME LIST
foreach my $prog ( sort { lc $a->{channel} cmp lc $b->{channel} || $a->{start} cmp $b->{start} } @programme_listings ) {
	
	# DEFINE CHANNEL ID
	my $channel_id   = $prog->{channel};
	my $channel_name = $ch_config->{channels}->{$channel_id};
	
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
	if( defined $programme_details->{ $prog->{id} }->{description} ) {
		$writer->startTag( "desc", "lang" => "de" );
		$writer->characters( $programme_details->{ $prog->{id} }->{description} );
		$writer->endTag( "desc" );
	}
	
	# CREDITS
	if( defined $programme_details->{ $prog->{id} }->{director} or defined $programme_details->{ $prog->{id} }->{actor} ) {
		
		$writer->startTag( "credits" );
		
		if( defined $programme_details->{ $prog->{id} }->{director} ) {
			my @director = @{ $programme_details->{ $prog->{id} }->{director} };
			foreach my $director ( @director ) {
				$writer->startTag( "director" );
				$writer->characters( $director );
				$writer->endTag( "director" );
			}
		}
		
		if( defined $programme_details->{ $prog->{id} }->{actor} ) {
			my @actor = @{ $programme_details->{ $prog->{id} }->{actor} };
			foreach my $actor ( @actor ) {
				$writer->startTag( "actor" );
				$writer->characters( $actor );
				$writer->endTag( "actor" );
			}
		}
		
		$writer->endTag( "credits" );
	
	}
	
	# DATE
	if( defined $programme_details->{ $prog->{id} }->{year} ) {
		$writer->startTag( "date" );
		$writer->characters( $programme_details->{ $prog->{id} }->{year} );
		$writer->endTag( "date" );
	}
	
	# COUNTRY
	if( defined $programme_details->{ $prog->{id} }->{country} ) {
		$writer->startTag( "country" );
		$writer->characters( $programme_details->{ $prog->{id} }->{country} );
		$writer->endTag( "country" );
	}
	
	# CATEGORY RESEARCH PARAMS, PART 2 - CHECK IF EIT CATEGORY WAS ALREADY PRINTED, AVOID DUPLICATED ENTRIES
	my %already_defined;
	my $already_defined;
	
	# CATEGORY 1 (ZATTOO GENRE 1 FOUND)
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
				
				print "[W] Category (G) \"" . $prog->{genre_1} . "\" not found in EIT list!\n";
				%already_not_found = ( %already_not_found, $prog->{genre_1} => 1 );
				$already_not_found = { category => \%already_not_found };
			}
			
			$writer->characters( $prog->{genre_1} );
			
		# EIT DISABLED = PRINT VALUE
		} else {
			
			$writer->characters( $prog->{genre_1} );
			
		}
		
		$writer->endTag( "category" );
		
	# CATEGORY 1 (ZATTOO GENRE 1 NOT FOUND, CHECK FOR ZATTOO CATEGORY VALUE)
	} elsif( defined $prog->{category_1 } ) {
		
		$writer->startTag( "category", "lang" => "de" );
		
		# EIT ENABLED AND FOUND = PRINT EIT + MARK EIT CATEGORY AS "ALREADY DEFINED"
		if( $genre eq "1" and defined $eit_db->{ $prog->{category_1} } ) {
			
			$writer->characters( $eit_db->{ $prog->{category_1} } );
			%already_defined = ( %already_defined, $eit_db->{ $prog->{category_1} } => 1 );
			$already_defined = { category => \%already_defined };
			
		# EIT ENABLED BUT NOT FOUND
		} elsif( $genre eq "1" ) {
			
			# IF EIT IS NOT ALREADY DEFINED AS "MISSING" = PRINT VALUE + MARK EIT AS "MISSING"
			if( not defined $already_not_found->{category}->{ $prog->{category_1} } ) {
				
				print "[W] Category (C) \"" . $prog->{category_1} . "\" not found in EIT list!\n";
				%already_not_found = ( %already_not_found, $prog->{category_1} => 1 );
				$already_not_found = { category => \%already_not_found };
				
			}
			
			$writer->characters( $prog->{category_1} );
			
		# EIT DISABLED = PRINT VALUE
		} else {
			
			$writer->characters( $prog->{category_1} );
			
		}
		
		$writer->endTag( "category" );
	}
	
	# MULTIPLE CATEGORIES ENABLED
	if( $category eq "1" ) {
		
		# CATEGORY2 (ZATTOO GENRE 2)
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
					
					print "[W] Category (G) \"" . $prog->{genre_2} . "\" not found in EIT list!\n";
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
	
		# CATEGORY3 (ZATTOO GENRE 3)
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
					
					print "[W] Category (G) \"" . $prog->{genre_3} . "\" not found in EIT list!\n";
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
	if( defined $programme_details->{ $prog->{id} }->{age} ) {
		$writer->startTag( "rating" );
		$writer->startTag( "value" );
		$writer->characters( $programme_details->{ $prog->{id} }->{age} );
		$writer->endTag( "value" );
		$writer->endTag( "rating" );
	}
	
	$writer->endTag( "programme" );
	
}
	
# END
$writer->endTag("tv");
$writer->end();

print "\n=== EPG FILE CREATED! ===\n";
