#!/usr/bin/perl -w
use strict;
use CGI qw/:standard/;
use CGI::Carp qw/fatalsToBrowser/;
use HTML::Entities;

# send the obligatory Content-Type
print header();
print start_html("Bewerk menu");

if (param('Save')) {
   my $tekst = param('tekst');
   my @in = split("\r\n", $tekst);

   if ( open(SYS, ">system.txt") ){
      foreach my $line (@in) {
         $line = HTML::Entities::encode($line);
         print SYS "$line\n";
      }
      close SYS;
      print "Changes saved<br>\n";
   } else {
      print "Problem opening file: $!<br>\n";
   }
}

my @lines = ();
#Read current data
if ( open (SYS, "<system.txt")){
   @lines = <SYS>;
   chomp @lines;
   close SYS;
}

print start_form();

my @out = map {HTML::Entities::decode($_)}  @lines;

print hr, "Zet mededelingen op aparte regels en zorg dat ze niet te lang zijn", br;

print textarea('tekst', join("\n", @out), 10 , 80);
print br;
print submit('Save', 'save'); 
print end_form();


print hr, "Gesponsorde SMS berichten", br;

if (param('SaveSponsored')) {
   my $tekst = param('spons_tekst');
   my @in = split("\r\n", $tekst);

   if ( open(SYS, ">sponsored.txt") ){
      foreach my $line (@in) {
         $line = HTML::Entities::encode($line);
         print SYS "$line\n";
      }
      close SYS;
      print "Changes saved<br>\n";
   } else {
      print "Problem opening file: $!<br>\n";
   }
}

my @spons_lines = ();
#Read current data
if ( open (SPONS, "<sponsored.txt")){
   @spons_lines = <SPONS>;
   chomp @spons_lines;
   close SPONS;
}

print start_form();

my @spons_out = map {HTML::Entities::decode($_)}  @spons_lines;
print textarea('spons_tekst', join("\n", @spons_out), 5 , 80);
print br;
print submit('SaveSponsored', 'save'); 
print end_form();

print hr;

print br;
print start_form();
print "Voeg een SMS bericht toe",br;
print textarea('message', '', 1,80);
print br;
print submit('AddSMS', 'toevoegen');
print end_form();
print br;

#### LOGO ########

if (param('SaveLogo' )) {
   my $logo = param('logos');
   chomp $logo;
   if ($logo eq "none") {
      $logo = '';
   }
   if ( open(SYS, ">logo.txt") ){
      print SYS $logo;
      close SYS;
      print "Logo saved<br>\n";
   }
}

##### SMS bar #####
if (param('SaveSMS')) {
   my $status = param('showsms');
   chomp $status;
   if (open(SYS, ">showsms.txt")) {
     print SYS $status;
     close SYS;
     print "SMS bar status saved<br>\n";
   } else {
     print STDERR "$!";
   }
}

##### Add SMS #####
if (param('AddSMS')) {
   my $message = param('message');
   chomp $message;
   if (open OUT, ">>smslist.txt") {
      print OUT time . " ";
      print OUT  "admin $message\n" ;
      close OUT;
   }
}
 
print end_html();

