#!/usr/bin/perl
# Charles Jackson
use warnings;
use strict;
use WWW::Mechanize;	   # https://metacpan.org/pod/WWW::Mechanize
use Try::Tiny;
use DBI;		   # https://metacpan.org/pod/DBD::mysql
use Data::Dumper;
use v5.10;
$| = 1; # so the ... will appear on the same line and at the right time

## given a WWW::Mechanize::Link to a world flora online taxon,
## returns the portion of the link starting with wfo and containing the unique identifier for that taxon
sub wfo {
    my $link = shift;
    my @url = split /\/|;/, $link->url(); # break up the link by / and ;
    return $url[2];
}
# for debugging messages
my %debug=(
    info => 1,
    min  => 2,
    med  => 3,
    max  => 4);
my $dblevel = 1;
### initialize mySQL ###
print("Login to mySQL$/username: "); # ask the user for their mySQL username
my $user = <STDIN>;		     # get username from console
chomp($user);
print("password: ");		     # ask user for mySQL password
my $pass = <STDIN>;		     # get password from console
chomp($pass);
my $dbh = DBI->connect("DBI:mysql:plants","$user","$pass") # log in to mySQL server
    or die "Could not connect to mysql. Is the server running? Don't use root user. make sure you have access from any ip: $@.$/";
$pass = undef;
print("connected mysql-server$/");
print "Creating Tables..." if($dblevel >= $debug{info});
### create tables ##
my @table_names = ("orders", "families","genera", "species", "subspecies"); # for selecting which table to insert into
my @depths = ("order", "family","genus", "species", "subspecies"); # for selecting what is being stored in the table
my $FIELD_SIZE = 500;		# the size for taxon names
$dbh->do("use plants");
$dbh->do("create table if not exists orders (wfo varchar($FIELD_SIZE) unique key, `order` varchar($FIELD_SIZE), order_id int not null auto_increment primary key);"); # orders table
$dbh->do("create table if not exists order_synonyms (wfo varchar($FIELD_SIZE) unique key, synonym varchar($FIELD_SIZE), synonym_id int not null auto_increment primary key, order_id integer);"); # order synonym table
for (my $i = 1; $i <= $#depths; $i++) { # the rest of the tables and synonym tables
    $dbh->do("create table if not exists $table_names[$i] (wfo varchar($FIELD_SIZE) unique key, $depths[$i] varchar($FIELD_SIZE), $depths[$i]_id int not null auto_increment primary key, $depths[$i-1]_id integer);");
    $dbh->do("create table if not exists $depths[$i]_synonyms (wfo varchar($FIELD_SIZE) unique key, synonym varchar($FIELD_SIZE), synonym_id int not null auto_increment primary key, $depths[$i]_id integer);");
}
print "Done$/" if($dblevel >= $debug{info});
### initialize psudo-browser ###
print "Connecting to WFO..." if($dblevel >= $debug{info});
my $bro = WWW::Mechanize->new(cookie_jar => undef);	# instantiate browser
my $basename = "http://www.worldfloraonline.org";
$bro->get("$basename/classification") # request website
    or die "Could not connect to $basename/classification. Are you connected to the internet? Can you reach the website in your browser?: $@";
print "Done$/" if($dblevel >= $debug{info});
my @order_links = $bro->links();
# find out how many orders there are
my $i;
for($i=$#order_links; $order_links[$i]->text() ne "Data Providers"; $i--){}
$i--;	# $i is now on the last order. the next statement is 0 indexed
@order_links = @order_links[16..($i)]; # @order_links now contains only order links. the first order is the 17th link I think

## orders ##
my $orderIndex;
my $pfh;			# place file handle
if( -f 'place.num'){
    open($pfh,'<','place.num'); # read in where we left off
    $orderIndex = <$pfh>;
    chomp($orderIndex);
    close($pfh);
}else{
    $orderIndex = 0;
}
my $depth = 0;
print Dumper @order_links if($dblevel >= $debug{max});
for(;$orderIndex <= $#order_links; $orderIndex++) { # for every order
    open($pfh, '>', 'place.num');		   # save the current order we are working on in case we crash
    print $pfh $orderIndex;
    close($pfh);
    my $order = $order_links[$orderIndex]->text(); # get the name of the order
    print "$order..." if($dblevel >= $debug{info});
    my $wfo = &wfo($order_links[$orderIndex]); # get the wfo id for the order
    $dbh->do("insert into orders (wfo, `order`) values (?, ?);", undef, $wfo, $order); # store order in database.
    my $connected=0;
    until($connected){
	try{
	    $bro->get($order_links[$orderIndex]->url()); # follow link to go to order page that has a list of families
	    $connected = 1;
	}catch{print "."}
    }
    $connected = undef;
    $depth++;			# go into families
    &dftraverse($order);
    $depth--;			# exit back to orders
    print "Done$/" if($dblevel >= $debug{info});
    ## families, genera, species... ##
    sub dftraverse {
	my $parent = shift;
	my @links = $bro->links(); # get the webpage
	print Dumper @links if($dblevel >= $debug{max});
	# find the links containing the taxon childeren
	for(my $i=0; $i <= $#links; $i++) { 
	    my $attr = $links[$i]->attrs();
	    next if(!$attr->{'title'});
	    ## sub-taxon ##
	    if($attr->{'title'} =~ /^Comment on Included/){ # found included sub-taxon including varieties
		$i++;		# move first sub-taxon
		until ($links[$i]->url() =~ /^#/) { # until the end of
		    my $name = $links[$i]->text();
		    $wfo = &wfo($links[$i]);
		    $dbh->do("insert into $table_names[$depth] (wfo, $depths[$depth], $depths[$depth-1]_id) values (?, ?, (select $depths[$depth-1]_id from $table_names[$depth-1] where `$depths[$depth-1]` = ?));", undef, $wfo, $name, $parent);
		    $depth++;
		    until($connected){
			try{
			    $bro->get($links[$i]->url());
			    $connected = 1;
			}catch{print "."}
		    }
		    $connected = undef;
		    &dftraverse($name); # go to a new, page one taxon level deeper
		    until($connected){
			try{
			    $bro->back();
			    $connected = 1;
			}catch{print "."}
		    }
		    $connected = undef;
		    $depth--;
		    $i++;	# move to next subtaxon
		}
	    }
	    if($attr->{'title'} =~ /^Comment on Synonyms/) { 
	    	$i++;		# move to the first synonym
	    	$depth--;	# synonyms are actually on the same level as the parent
	    	# get synonyms
	    	until ($links[$i]->url() =~ /#/) {
	    	    my $name = $links[$i]->text();
	    	    my $wfo = &wfo($links[$i]);
	    	    $dbh->do("insert into $depths[$depth]_synonyms (wfo, synonym, $depths[$depth]_id) values (?, ?, (select $depths[$depth]_id from $table_names[$depth] where `$depths[$depth]` = ?));", undef, $wfo, $name, $parent);
	    	    $i++;
	    	}
	    	$depth++;
	    }
	}
    }
}
$dbh->disconnect();
open($pfh, '>', 'place.num'); # start from the begining on the next run
print $pfh 0;
close($pfh);
say("Finished");
