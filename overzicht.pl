#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;


$fileroot ="/home/yvo/public_html/patat/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";

#dir voor vandaag aanmaken:
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
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
print start_html("Overzicht");
print '
<body bgcolor="#000066" vlink="#FFFFFF" alink="#FFFFFF">
<table width="100%" align="left" valign="top">
<tr>
   <td width="4%" bgcolor="#0A0AFF" align="left" valign="top">&nbsp;</td>
   <td align="left" valign="top"><font color="white">
';

print "<a href=\"printerfriendly.txt\" target=\"_new\"><img src=\"printer.gif\" align=\"right\"></a>\n";
print "<h1>Overzicht bestellingen vandaag ($mday $mon $year)</h1>\n";

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

print "<ul>\n";
foreach $user (@userlist){
    my $bedrag = 0;
    open BESTELLING , "< $todaydir/$user";
    $bestelling = <BESTELLING>;
    close BESTELLING;
    @los = split /:/ , $bestelling;
    print "<li>$user\n";
    print "<ul>\n";
    foreach $item (@los) {
      $item = int($item);
      ($itemnaam, $prijs) = split /:/ , $menu{$item};
#      print "<li> $menu{$item} </li>\n";
      print "<li> $itemnaam = $prijs </li>\n";
#      ($dummy, $prijs) = split /:/ , $menu{$item};
      $prijs =~ s/\,/\./g;
      $bedrag += $prijs;
      $totaalprijs += $prijs; 
      $totaal{$item}++;
    }
    printf "<li>---> Te betalen: %.2f</li>\n", $bedrag;
    print "</ul>\n";
    print "</li>\n";
}
print "</ul>\n";
print hr();

print "<a href=\"printerfriendly.txt\" target=\"_new\"><img src=\"printer.gif\" align=\"right\"></a>\n";

print "<h2>Cumulatief</h2>\n";
print "<pre>";

my $totaalaantal = 0;
foreach $item (sort keys %totaal) {
   ($eten, $prijs) = split /:/ , $menu{$item};
   $prijs =~ s/\n//g;
   $prijs =~ s/\,/\./g;
   $totaalaantal +=  $totaal{$item};
   printf "%2dx %-40s a %.2f = %.2f\n", $totaal{$item}, $eten, $prijs, $totaal{$item} * ($prijs); 
}
print "-" x 60;
print "\n";
printf "%-52s %.2f\n", "Totaal:" , $totaalprijs; 

print "</pre>";

#Snel de printerfriendly pagina maken voordat iemand er op klikt!
open FROP, "> /home/yvo/public_html/patat/printerfriendly.txt" or die "$!";

print FROP "Bestellingen van ". localtime(time) . "\n\n";

foreach $item (sort keys %totaal) {
   ($eten, $prijs) = split /:/ , $menu{$item};
   $prijs =~ s/\,/\./g;
   $prijs =~ s/\n//g;
   printf FROP "%2dx %-40s a %.2f = %.2f\n", $totaal{$item}, $eten, $prijs, $totaal{$item} * ($prijs);
}
print FROP "-" x 60;
print FROP "\n";
printf FROP "%-52s %.2f\n", "Totaal:" , $totaalprijs;
print FROP "($totaalaantal items)\n";


print FROP "\n\n\n -------------Wie eet wat?--------------\n\n";

foreach $user (@userlist){
    my $bedrag = 0;
    my $wrap = 0;
    open BESTELLING , "< $todaydir/$user";
    $bestelling = <BESTELLING>;
    close BESTELLING;
    @los = split /:/ , $bestelling;
    printf FROP "%-12s : ", $user;
    foreach $item (@los) {
      $item = int($item);
      ($dummy, $prijs) = split /:/ , $menu{$item};
      $prijs =~ s/\,/\./g;
      $wrap += length($dummy);
      if ($wrap > 70) {
         $wrap = 0;
         print FROP "\n", " "x15;
      }
      print FROP "$dummy, ";
      $bedrag += $prijs;
    }
    printf FROP " Betalen: %.2f \n", $bedrag;
}



close FROP;
print end_html;
