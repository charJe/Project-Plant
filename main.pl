#!/usr/bin/perl
# Charles Jackson
use warnings;
use strict;
use lib "$ENV{HOME}/.cpanm/latest-build/";
use WWW::Mechanize;	     # https://metacpan.org/pod/WWW::Mechanize
use lib "$ENV{HOME}/.cpanm/latest-build/DBD-mysql-4.050/lib/";
use DBI;		     # https://metacpan.org/pod/DBD::mysql

### initialize mqSQL ###
print("Login to mySQL$/username: "); # ask the user for their mySQL username
my $user = <STDIN>;		     # get username from console
print("password: ");		     # ask user for mySQL password
my $pass = <STDIN>;		     # get password from console
my $db = DBI->connect("","$user","$pass"); # log in to mySQL server
$db->do("create table [if not exists] plants (
	  order VARCHAR(100),
	  family VARCHAR(100),
	  genus VARCHAR(100),
	  species VARCHAR(100));"); # create a table for the orders

### initialize psudo-browser ###
our %depths = (order => 0, # enumerated type to to keep trac of the depth of taxonomy
	       family => 1,
	       genus => 2,
	       species => 3);
my $bro = WWW::Mechanize->new();	# instantiate browser
$bro->get("http://www.worldfloraonline.org/classification"); # request website
my $depth = $depths{order};	# initalize depth to the most shallow
