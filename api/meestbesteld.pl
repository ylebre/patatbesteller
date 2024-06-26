#!/usr/bin/perl -w

use strict;

use lib '..';
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;
use JSON;
use Time::Local;

my $fileroot ="/path/to/db/";
my $userdir = $fileroot."users/";
my $globaldir = $fileroot."global/";

#Menu inlezen:
open MENU, "${globaldir}menu.txt";
my @lijst = <MENU>;
close MENU;
my %menu = ();
my %userhistory = ();

my $menucounter = 0;
foreach my $item (@lijst){
  my ($id, $value) = split /:/, $item, 2;
  $menu{$id}=$value;
  $userhistory{$id} = 0;
}

my @keys = sort {$a <=> $b} keys %menu;

opendir (DIR, $fileroot) or die "Can't open directory $!";
# Read files

my %entries;

my $user = param('user');

my @meest;
my @laatst;

if ($user) {
	$user =~ s/[\/]//g;                      #geen slashes!

	my $count = 0;
	# Find the entries that have the specified user
	foreach my $entry ( reverse sort { $a <=> $b } readdir(DIR) )
		if ($count > 20) {
			last;
		}
		$count++;
		next if ($entry =~ m/^\./);
		print "Entry: $entry\n";
		if ($entry =~ m/\d+-\d+-\d+/) {
			if (-e $fileroot . "/" . $entry . "/" . $user) {
				print "Entry has info for the user\n";
				$entries{$entry} = 1;
			}
		}
	}
	closedir DIR;

	sub my_sort {
	  # got hash keys $a and $b automatically
		my ($ay, $am, $ad) = split "-", $a;
		my ($by, $bm, $bd) = split "-", $b;

		my $aval = timelocal(0,0,0,$ad, $am-1, $ay);
		my $bval = timelocal(0,0,0,$bd, $bm-1, $by);

		return $aval <=> $bval;
	}

	$count = 0;
	my %counters;

	sub counters_sort {
		return $counters{$a} <=> $counters{$b};
	}

	my $laatst_besteld;

	foreach my $key (reverse sort my_sort keys %entries) {
		if ($count > 19) {
			last;
		}
		$count++;

		open ENTRY, "< $fileroot/$key/$user";
		my $bestelling = <ENTRY>;
		chomp($bestelling);
		my @items = split ":", $bestelling;
		$bestelling = join ":", sort(@items);
		if (!defined $laatst_besteld) {
			$laatst_besteld = $bestelling;
		}

		$counters{$bestelling}++;
		close ENTRY;
	}

	my @sorted_bestellingen = sort counters_sort keys %counters;
	my $meest_besteld = pop @sorted_bestellingen;

	if ($meest_besteld && $laatst_besteld) {
		if ($meest_besteld eq $laatst_besteld) {
			$meest_besteld = pop(@sorted_bestellingen);
		}

		my @meest_los = split /:/ , $meest_besteld;

		foreach my $item (@meest_los) {
			my ($description, $price) = split ":", $menu{$item};
			my %meest_item = (
				'id' => $item,
				'description' => $description,
				'price' => $price
			);
			push @meest, \%meest_item;
		}

		my @laatst_los = split /:/ , $laatst_besteld;

		foreach my $item (@laatst_los) {
			my ($description, $price) = split ":", $menu{$item};
			my %laatst_item = (
				'id' => $item,
				'description' => $description,
				'price' => $price
			);
			push @laatst, \%laatst_item;
		}
	}
}

my %result = (
	'laatst' => \@laatst,
	'meest' => \@meest
);

#print "Meest besteld: $meest_besteld : " . $counters{$meest_besteld} . "\n";
#print "Laatst besteld: $laatst_besteld\n";

# Print JSON encode van het menu.
print header;
print encode_json \%result;
