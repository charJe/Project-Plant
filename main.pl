#!/usr/bin/perl
# Charles Jackson
use warnings;
use strict;
use WWW::Mechanize;	     # https://metacpan.org/pod/WWW::Mechanize
use DBI;		     # https://metacpan.org/pod/DBD::mysql
use Data::Dumper;

### initialize mqSQL ###
#print("Login to mySQL$/username: "); # ask the user for their mySQL username
#my $user = <STDIN>;		     # get username from console
#print("password: ");		     # ask user for mySQL password
#my $pass = <STDIN>;		     # get password from console
#my $db = DBI->connect("","$user","$pass"); # log in to mySQL server
### create tables ##
#$main::FIELD_SIZE = 50;
#my $db->do("create table [if not exists] orders 
#	  (order varchar($main::FIELD_SIZE), order_id integer auto_increment, general_information text);");
#my $db->do("create table [if not exists] families
#	  (order_id integer, family varchar($main::FIELD_SIZE), family_id integer auto_increment, general_information text);");
#my $db->do("create table [if not exists] genera
#	  (family_id integer, genus varchar($main::FIELD_SIZE), genus_id integer auto_increment, general_information text);");
#my $db->do("create table [if not exists] species
#	  (genus_id integer, species varchar($main::FIELD_SIZE), species_id integer auto_increment, general_information text);");
#my $db->do("create table [if not exists] varieties
#	  (species_id integer, name varchar($main::FIELD_SIZE), variety_id integer auto_increment, general_information text);");
#my $db->do("create table [if not exists] synonyms
#	  (species_id integer, nym varchar($main::FIELD_SIZE));");
### initialize psudo-browser ###
our %depths = (order   => 0, # enumerated type to to keep trac of the depth of taxonomy
	       family  => 1,
	       genus   => 2,
	       species => 3);
my $bro = WWW::Mechanize->new();	# instantiate browser
$bro->get("http://www.worldfloraonline.org/classification"); # request website
my @order_links = $bro->links();
# find out how many orders there are
my $i;
for($i=$#order_links; $order_links[$i]->text() ne "Data Providers" ; $i--){}
$i--;				# $i is now on the last order
@order_links = @order_links[16..($i)]; # @order_links now contains only order links

## order ##
my $depth = $depths{order};
for(my $o_id=0; $o_id < 1 and $o_id <= $#order_links; $o_id++){ # for every order
    my $order = $order_links[$o_id]->text(); # get the name of the order
#    $db->do("insert into orders () 
    #	   values($order,0) [on duplicate key update order];"); # store order in database
    $bro->follow_link( url => $order_links[$o_id]->url() );
    $depth++;			# go into family
    ## family, genus, species... ##
    sub dps{
	my @links = $bro->links(); # get the webpage
	for(my $id=0; $id <= $#links; $id++){ # find the links containing the taxon childeren
	    my $attr = $links[$id]->attrs(); 
	    if($attr->{'title'} =~ /^Comment on Included/){
		last;	       
	    }
	}
	
    }
    print Dumper $bro->links();
}
