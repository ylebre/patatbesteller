#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;


$fileroot ="/home/yvo/public_html/patat/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";


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
print start_html("Stats");
print '
<body bgcolor="#000066" vlink="#FFFFFF" alink="#FFFFFF">
<table width="100%" align="left" valign="top">
<tr>
   <td width="4%" bgcolor="#0A0AFF" align="left" valign="top">&nbsp;</td>
   <td align="left" valign="top"><font color="white">
';

print "<h1>Statistieken</h1>\n";

my @userlist = ();
opendir(DIR, $userdir) or die "can't opendir $userdir: $!";
while (defined($user = readdir(DIR))) {
  if (-f "$userdir/$user" ){
        push @userlist, $user;
        
  }
}  
close DIR;

foreach (sort @userlist){
   print "<a href=\"#$_\">$_</a> \n";
}

print "<p><b><a href=\"#ranglijst\">Algemene ranglijst</a></b><hr>\n";

my %totaal = ();
my $totaalprijs = 0;
my %ranglijst =();

print "<ul>\n";
foreach $user (sort @userlist){
    my $bedrag = 0;
    open BESTELLING , "< $userdir/$user";
    @bestellingen = <BESTELLING>;
    close BESTELLING;
    my %bestellist;
    foreach $ding (@bestellingen){
       my ($hapje, $aantal) = split /:/, $ding;
       $bestellist{$hapje} = $aantal, if ($aantal >0);
    }
    print "<a name=\"$user\">\n";
    print "<li><b>$user</b>\n";
    print "<ul>\n";
    foreach $item (keys %bestellist) {
      $item = int($item);
      print "<li>$bestellist{$item} X $menu{$item} </li>\n";
      (undef, $prijs) = split /:/ , $menu{$item};
      $prijs =~ s/\,/\./;
      $bedrag += ($prijs * $bestellist{$item});
      $totaal{$item}++; 
    }
   
    $ranglijst{$user} = $bedrag;
    printf "<li>---> Totaal van $user: \&euro; %.2f</li>\n", $bedrag;
    print "</ul>\n";
    print "</li>\n";
}
print "</ul>\n";
print hr();

print h2("Ranglijst");
print "<a name=\"ranglijst\">\n<pre><ol>";

foreach $user (sort {$ranglijst{$b} <=> $ranglijst{$a} } keys %ranglijst) {
  printf "<li>%-15s - \&euro; %.2f</li>", $user, $ranglijst{$user};
  $totaalprijs += $ranglijst{$user};
}

printf "</ol></pre><b>Totaalbedrag: \&euro; %.2f</b>\n", $totaalprijs;

print hr(); 

#print "<h2>Cumulatief</h2>\n";
#print "<pre>";

#foreach $item (sort keys %totaal) {
#   ($eten, $prijs) = split /:/ , $menu{$item};
#   $prijs =~ s/\n//g;
#   printf "%2dx %-40s a %.2f = %.2f\n", $totaal{$item}, $eten, $prijs, $totaal{$item} * ($prijs); 
#}
#print "-" x 60;
#print "\n";
#printf "%-52s %.2f\n", "Totaal:" , $totaalprijs; 

#print "</pre>";

#Snel de printerfriendly pagina maken voordat iemand er op klikt!
#open FROP, "> /home/patat/public_html/printerfriendly.txt";

#print FROP "Bestellingen van Aukevleerstraat 1 van ". localtime(time) . "\n\n";

#foreach $item (sort keys %totaal) {
#   ($eten, $prijs) = split /:/ , $menu{$item};
#   $prijs =~ s/\n//g;
#   printf FROP "%2dx %-40s a %.2f = %.2f\n", $totaal{$item}, $eten, $prijs, $totaal{$item} * ($prijs);
#}
#print FROP "-" x 60;
#print FROP "\n";
#printf FROP "%-52s %.2f\n", "Totaal:" , $totaalprijs;

#close FROP;
print end_html;
