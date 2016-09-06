#!/usr/bin/perl
use warnings;
use strict;

my @args;
my @urls;
my $indexurl = "http://theamphour.libsyn.com/theamphour/size/400";
print "Fetching index...   ";
my $index = `curl -sS $indexurl`;
print "Fetched!\n";
my @indexarray = split /Direct download:/, $index;
foreach my $arg (@ARGV) {
	$arg =~ m/\d+\z/ or die "Argument $arg is not a number! $!";
	push(@args, $arg);
}
@args = uniq(@args);
print "Warning: going to download " . scalar(@args) . " files. Are you sure? [y/N]:";
chomp ($_ = <STDIN>);
die "Ok, aborting.\n" unless (/^[Yy](?:es)?$/);	
OUTER:	foreach my $number (@args) {
	$number =~ m/\d+\z/ or die "Argument is not a number! $!";
INNER:		foreach my $element (@indexarray) {
		if ($element =~ m|http://traffic.libsyn.com/theamphour/[a-zA-Z_-]+$number[a-zA-Z_-]+[a-zA-Z0-9_-]+\.mp3|) {
			push (@urls, $&);
			last INNER;
		}
	}
}

foreach my $url (@urls) {
	system("wget $url");
	#print $url;
}
exit;

sub uniq {
	my %seen;
	grep!$seen{$_}++, @_;
}
