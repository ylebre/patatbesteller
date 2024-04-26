#!/usr/bin/perl -w

use strict;

use Mail::Mailer;

sub notify {
   my $not_user = shift;
   my $mailer = Mail::Mailer->new("sendmail");
   $mailer->open(
       {
           From       => 'patat@muze.nl',
           To         => 'yvo@muze.nl',
           Subject    => "!msg muzepatat Patat geopend door $not_user"
       }
     );
   print $mailer "http://patat.muze.nl/\n";
   $mailer->close();
}

notify("Frop");
