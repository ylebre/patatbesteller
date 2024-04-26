#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;

$fileroot ="/path/to/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";

$combinatie = "";

#Menu inlezen:
open MENU, "${globaldir}menu.txt";
my @lijst = <MENU>;
close MENU;
my %menu = ();

my $menucounter = 1;
foreach $item (@lijst){
  ($id, $value) = split /:/, $item, 2;
  $menu{$id}=$value;
  unless ($id =~ /\+/) {
     $menucounter++;
  }
}

print header();
print start_html("Voeg combinatie toe");
print '
<body bgcolor="#000066" vlink="#FFFFFF" alink="#FFFFFF">
<table width="100%" align="left" valign="top">
<tr>
   <td width="4%" bgcolor="white" align="left" valign="top">&nbsp;</td>
   <td align="left" valign="top"><font color="white">
';

@combo = param('bestelling');
if (@combo) {
   foreach $item (@combo) {
      $combinatie .= $item . "+";
   }
   $combinatie =~ s/\+$//;
} else {
   $combinatie = $menucounter + 1;
}

$omschrijving = param('omschrijving');

if (param('Voeg toe')) {
   print "$omschrijving toegevoegd aan het menu<br>\n";
   if ($combinatie) {
      print "ID is $combinatie<br>\n"      
   }
   open MENU, ">> ${globaldir}menu.txt";
   print MENU "$combinatie:$omschrijving:0,00\n";
   close MENU;
# Write to menu
} else {
   @keys = sort {$a <=> $b} keys %menu;
   print start_form;
   "Omschrijving:<br>\n",
   textfield('omschrijving'),p,
   submit('Voeg toe'),
   print checkbox_group(-name=>'bestelling',
                     -values=>\@keys,
                     -linebreak=>'true',
                     -labels=>\%menu
                    ), "<br><br>\n",
   "Omschrijving:<br>\n",
   textfield('omschrijving'),p,
   submit('Voeg toe'),
     end_form;
}

print hr(), end_html;
