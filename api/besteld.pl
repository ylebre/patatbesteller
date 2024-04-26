#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;
use Mail::Mailer;
use JSON;

$fileroot ="/home/yvo/public_html/patat/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";

#dir voor vandaag aanmaken:
(undef,undef,undef,$mday,$mon,$year,undef,undef,undef) = localtime(time);
$year += 1900; $mon++;
$today = "$year-$mon-$mday";

my $fut_time=gmtime(time()+365*24*3600)." GMT";  # Add 12 months (365 days)

#Menu inlezen:
open MENU, "${globaldir}menu.txt";
my @lijst = <MENU>;
close MENU;
my %menu = ();
my %userhistory = ();

my $menucounter = 0;
foreach $item (@lijst){
  ($id, $value) = split /:/, $item, 2;
  $menu{$id}=$value;
  $userhistory{$id} = 0;
}

@keys = sort {$a <=> $b} keys %menu;

print header;
my @result;

if (defined param('userlist') && (!(param('userlist') eq "[naam]"))) {
   $user = param('userlist');
   $user =~ s/[\/]//g;                      #geen slashes!

	if ( $user ){
	  if (-e "$fileroot$today/$user") {
	      open BESTELLING, "< $fileroot$today/$user";
	      $bestelling = <BESTELLING>;
	      close BESTELLING;
		  chomp($bestelling);
	      @los = split /:/ , $bestelling;

			foreach my $item (@los) {
			  my ($description, $price) = split ":", $menu{$item};
			  my %item = (
			     'id' => $item,
			     'description' => $description,
			     'price' => $price
			  );
			  push @result, \%item;
			}
	  }
	}
}
print encode_json \@result;
