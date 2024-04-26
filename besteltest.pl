#!/usr/bin/perl -w
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;

print header();
print start_html("Bestel");

          print start_form,
          submit("Bestel"),
          checkbox_group(-name=>'bestelling',
                         -values=>("frop", "blaat", "boe"),
                         -linebreak=>'true',
                         -labels=>("hop", "hap", "hup")
                         ),
          hidden(-name=>'userfield',-default=>"joost"),
          hidden(-name=>'userlist',-default=>"[naam]"),  
          submit("Bestel"),
          end_form;

print end_html();