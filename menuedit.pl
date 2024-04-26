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
my %userhistory = ();

my $menucounter = 0;
foreach $item (@lijst){
  ($id, $value) = split /:/, $item, 4;
  $menu{$id}=$value;
  $userhistory{$id} = 0;
}

print header();
print start_html("Bestel");
print '
<body bgcolor="#000066" vlink="#FFFFFF" alink="#FFFFFF">
<table width="100%" align="left" valign="top">
<tr>
   <td width="4%" bgcolor="#0A0AFF" align="left" valign="top">&nbsp;</td>
   <td align="left" valign="top"><font color="white">
';

if (param('Update')) {
   print "Update menu";

    open(FH, "> $globaldir/formlog")              or die "can't append to formlog: $!";
    flock(FH, 2)                            or die "can't flock formlog: $!";

    # either using the procedural interface
    use CGI qw(:standard);
    save_parameters(*FH);                   # with CGI::save
    close FH;

} else {
    $knoppen = submit("Update") . "<br><br>";   

    @keys = sort {$a <=> $b} keys %menu;

    print start_form;
    print $knoppen;

    print '<table width="100%" align="left" valign="top" style="color: white;">';
    print '<tr><td>Index</td><td>Omschrijving</td><td>Prijs</td><td>Extra informatie</td></tr>';
    foreach $item (@lijst) {
       @items = split /:/, $item;
       print '<tr><td width="20">' . $items[0] . '</td><td><input type="text" name="menu' . $items[0] . 'desc" value="' . $items[1] . '"></td>';
       print '<td><input type="text" name="menu' . $items[0] . 'prijs" value="' . $items[2] . '"></td>';
       print '<td><input type="text" name="menu' . $items[0] . 'extra" value="' . $items[3] . '"></td>';
       print '</tr>';
    }
    print '</font></table>';
    print $knoppen;
    print end_form;
}

print hr();
print end_html;
