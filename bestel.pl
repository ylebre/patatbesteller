#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;
use Mail::Mailer;

$fileroot ="/path/to/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";

#dir voor vandaag aanmaken:
(undef,undef,undef,$mday,$mon,$year,undef,undef,undef) = localtime(time);
$year += 1900; $mon++;
$today = "$year-$mon-$mday";

my $fut_time=gmtime(time()+365*24*3600)." GMT";  # Add 12 months (365 days)
my $cookieuser = cookie('user');

#if (! (-e $fileroot.$today)) {
#  mkdir $fileroot.$today, 0777 or die "Can't create today dir: $!";
#}
$todaydir = $fileroot.$today;

sub notify {
   my $not_user = shift;
   my $mailer = Mail::Mailer->new("sendmail");
   $mailer->open(
       {
           From       => 'patat@example.com',
           To         => 'patat-list@example.com',
           Subject    => "Patat geopend op $hour:$min door $not_user"
       }
     );
   print $mailer "http://patat.example.com/\n";
   $mailer->close();
}

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
#  $menucounter++;
}


if (defined param('userlist') && (!(param('userlist') eq "[naam]"))) {
   $user = param('userlist');
   $user =~ s/[\/]//g;                      #geen slashes!
} elsif (defined param('userfield')) {
   $user = lc ( param('userfield') );
   $user =~ s/[\/]//g;                      #geen slashes!
   #voeg user toe aan users
   open USERFILE , "> ${userdir}${user}";
   close USERFILE;
}  

@besteld = param('bestelling');

if ( $user ){
  $usercookie = cookie(-name => 'user', -value => $user, -expires => $fut_time, -path => '/');
  print header(-cookie => $usercookie);
  print start_html("Bestel");
  print '
  <body bgcolor="#000066" vlink="#FFFFFF" alink="#FFFFFF">
  <table width="100%" align="left" valign="top">
  <tr>
     <td width="4%" bgcolor="#0A0AFF" align="left" valign="top">&nbsp;</td>
     <td align="left" valign="top"><font color="white">
  ';

  my $userfile = $userdir . $user;
  open USERFILE , "< $userfile" or die "Can't open userfile: $!";
  while ($line = <USERFILE>){
     my ($id, $aantal) = split /:/ , $line;
     $userhistory{$id} = int($aantal);
  }
  close USERFILE;


  if (param('Annuleer bestelling')) {
     open BESTELLING, "< $todaydir/$user";
     $bestelling = <BESTELLING>;
     close BESTELLING;
     chomp($bestelling);

     my @ids = split /:/, $bestelling;
     foreach my $item (@ids) {
        $userhistory{$item}--;
     }

     my $filename = $todaydir . "/" . $user;

     unlink($filename);
     print "Bestelling geannuleerd.<br><br>\n";

     #wegschrijven history
     open USERFILE , "> ${userdir}$user";
     foreach $item (keys %userhistory){
        print USERFILE "${item}:$userhistory{$item}\n";
     }
     close USERFILE;
  } else {
  if ( @besteld ){
    #make todaydir and notify
    if (! (-e $todaydir)) {
        mkdir $todaydir, 0775;
        notify($user);
    }

     $bestelling = join ':' , @besteld;
     
     foreach $item (@besteld) {
        $userhistory{$item}++;
     }
     
     if (param('Bestel bij')) {
        open BESTELLING, "< $todaydir/$user" or die "Can't open file: $!";
        $bestelling = <BESTELLING>;
        close BESTELLING;
        chomp($bestelling);
        $bestelling =~ s/\n//g;
        $bestelbij = join ':', @besteld;
        $bestelling .= ":" . $bestelbij;
     } elsif (param('Nieuwe bestelling')) {
        open BESTELLING, "< $todaydir/$user" or die "Can't open file: $!";
        my $oud_bestelling = <BESTELLING>;
        close BESTELLING;
        chomp($oud_bestelling);
        my @oud = split /:/, $oud_bestelling;
        foreach my $item (@oud) {
           $userhistory{$item}--;
        }
     }

     $bestelling =~ s/\+/:/g;
     open BESTELLING, "> $todaydir/$user";
     print BESTELLING $bestelling ."\n";
     close BESTELLING;
     chmod(0666, "$todaydir/$user");
     #wegschrijven history
     open USERFILE , "> ${userdir}$user" or die "Can't open userfile: $!";
     foreach $item (keys %userhistory){
        print USERFILE "${item}:$userhistory{$item}\n";
     }
     close USERFILE;
     
  }
  @keys = sort {$a <=> $b} keys %menu;
  @keys =sort { $userhistory{$b} <=> $userhistory{$a} } @keys;
  print start_form;
  if (-e "$fileroot$today/$user") {
      open BESTELLING, "< $fileroot$today/$user";
      $bestelling = <BESTELLING>;
      close BESTELLING;
      @los = split /:/ , $bestelling;
      print "Hallo $user<p>\nJe hebt het volgende besteld:<p>\n";
      print "<ul>\n";
      foreach $item (@los) {
         $item = int($item);
         ($itemnaam, $prijs) = split /:/, $menu{$item};
         print "<li> $itemnaam $prijs</li>\n";
      }
      print "<br><br>\n";
      $knoppen = submit("Bestel bij") . " " . submit("Nieuwe bestelling") . " " . submit("Annuleer bestelling") . "<br><br>\n";
  } else {
      print "Hallo $user<p>\nWat wil je vandaag eten?<p>\n"; 
      $knoppen = submit("Bestel") . "<br><br>\n";
  }        
  print $knoppen;
  print checkbox_group(-name=>'bestelling',
                       -values=>\@keys,
                       -linebreak=>'true',
                       -labels=>\%menu
                       ),
        hidden(-name=>'userfield',-default=>$user),
        hidden(-name=>'userlist',-default=>"[naam]"),     #Bah wat een vieze hack!
        $knoppen,
        end_form;
  }
} else { #user not defined
    print header();
    print start_html("Bestel");
    print '
    <body bgcolor="#000066" vlink="#FFFFFF" alink="#FFFFFF">
    <table width="100%" align="left" valign="top">
    <tr>
       <td width="4%" bgcolor="#0A0AFF" align="left" valign="top">&nbsp;</td>
       <td align="left" valign="top"><font color="white">
    ';

   print "Geef eerst aan wie je bent in onderstaand menu.<br> Als je niet in
          het menu staat kun je de invulruimte daaronder gebruiken.<p>";
   #get list of known users
   my @userlist = ("[naam]");
   opendir(DIR, $userdir) or die "can't opendir $userdir: $!";
   while (defined($user = readdir(DIR))) {
     if (-f $userdir.$user ){
        push @userlist, $user; 
     }
   }
   @userlist = sort @userlist;
   if (!defined $cookieuser) {
      $cookieuser = "[naam]";
   }

   print start_form,
         "Wie ben je?  ",p, "Kies:",               
         popup_menu(-name=>'userlist',
                    -values=>\@userlist,
		    -default=>$cookieuser)
         ,p,"Of vul in:",
         textfield('userfield'),p,
         submit("OK"),
         end_form,
         hr; 
} 


print hr(), end_html;
