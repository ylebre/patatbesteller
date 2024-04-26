#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;
use JSON;

$fileroot ="/home/yvo/public_html/patat/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";

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

if (defined param('userlist') && (!(param('userlist') eq "[naam]"))) {
   $user = param('userlist');
   $user =~ s/[\/]//g;                      #geen slashes!

  if ( $user ) {
    my $userfile = $userdir . $user;
    if (-e $userfile) {
      open USERFILE , "< $userfile" or die "Can't open userfile: $!";
      while ($line = <USERFILE>){
         my ($id, $aantal) = split /:/ , $line;
         $userhistory{$id} = int($aantal);
      }
      close USERFILE;

      @keys = sort { $userhistory{$b} <=> $userhistory{$a} } @keys;
    }
  }
}

my @sortedmenu;
foreach my $item (@keys) {
  my ($description, $price) = split ":", $menu{$item};
  my %item = (
     'id' => $item,
     'description' => $description,
     'price' => $price
  );
  push @sortedmenu, \%item;
}

# Print JSON encode van het menu.
print header;
print encode_json \@sortedmenu;
