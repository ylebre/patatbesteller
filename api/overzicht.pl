#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;
use JSON;

$fileroot ="/path/to/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";

#dir voor vandaag aanmaken:
#($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
(undef,undef,undef,$mday,$mon,$year,undef,undef,undef) = localtime(time);
$year += 1900; $mon++;
$today = "$year-$mon-$mday";
if (! (-e $fileroot.$today)) {
  mkdir $fileroot.$today, 0775;
}
$todaydir = $fileroot.$today;


#Menu inlezen:
open MENU, "${globaldir}menu.txt";
my @lijst = <MENU>;
close MENU;
my %menu = ();
foreach $item (@lijst){
  ($id, $value) = split /:/, $item, 2;
  $menu{$id}=$value;
}

print header();

my @userlist = ();
opendir(DIR, $todaydir) or die "can't opendir $userdir: $!";
while (defined($user = readdir(DIR))) {
  if (-f "$todaydir/$user" ){
        push @userlist, $user;
  }
}  
close DIR;

my %totaal = ();
my $totaalprijs = 0;

my %overzicht = ();

my @overzicht_users;

foreach $user (@userlist) {
    my $bedrag = 0;
    open BESTELLING , "< $todaydir/$user";
    $bestelling = <BESTELLING>;
    close BESTELLING;
    @los = split /:/ , $bestelling;

    my @userbestelling;

    foreach $item (@los) {
      $item = int($item);
      ($itemnaam, $prijs) = split /:/ , $menu{$item};
      my %item = (
         "id" => $item,
         "description" => $itemnaam,
         "price" => $prijs
      );

      push @userbestelling, \%item;

#      ($dummy, $prijs) = split /:/ , $menu{$item};
      $prijs =~ s/\,/\./g;
      $bedrag += $prijs;
      $totaalprijs += $prijs; 
      $totaal{$item}++;
    }
    my %userinfo = (
		"user" => $user,
       "bestelling" => \@userbestelling,
       "usertotal" => sprintf("%.2f", $bedrag)
    );
    $userinfo{"usertotal"} =~ s/\./,/;

    push @overzicht_users, (\%userinfo);

}

my @cumulatief;
my $totaalaantal = 0;
foreach $item (sort keys %totaal) {
   ($eten, $prijs) = split /:/ , $menu{$item};
   $prijs =~ s/\n//g;
   $prijs =~ s/\,/\./g;
   $totaalaantal +=  $totaal{$item};
   my %item = (
      "id" => $item,
      "description" => $eten,
      "price" => $prijs,
      "amount" => $totaal{$item},
      "itemtotal" => sprintf("%.2f", $totaal{$item} * $prijs)
   );
   $item{"itemtotal"} =~ s/\./,/;
   push @cumulatief, \%item;
}

$overzicht{"wie_eet_wat"} = \@overzicht_users;
$overzicht{"total"} = sprintf("%.2f", $totaalprijs);
$overzicht{"total"} =~ s/\./,/;
$overzicht{"cumulatief"} = \@cumulatief;

print encode_json(\%overzicht);
