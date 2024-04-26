#!/usr/bin/perl -w

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;
use Mail::Mailer;
use JSON;

$fileroot ="/db/";
$userdir = $fileroot."users/";
$globaldir = $fileroot."global/";

print header();

#get list of known users
my @userlist;
opendir(DIR, $userdir) or die "can't opendir $userdir: $!";
while (defined($user = readdir(DIR))) {
  if (-f $userdir.$user ){
     push @userlist, $user;
  }
}
@userlist = sort @userlist;

print encode_json \@userlist;
