#!/usr/bin/perl
use warnings;
use strict;

#Global variables:
my @args;
my @urls;
my $totalsize = 0;
my $indexurl = "http://theamphour.libsyn.com/theamphour/size/400";
my $usage = "Usage: $0 episode_number [another_episode_number ...]\n";

die "$usage" unless @ARGV; #Print usage if there are no arguments.

#Make sure each argument is a number, and push each one into an array.
foreach my $arg (@ARGV) {
        $arg =~ m/\d+\z/ or die "Argument $arg is not a number!\n$usage";
        push(@args, $arg);
}
@args = uniq(@args); #Remove duplicate elements from the array.

print "Fetching index...   ";
my $index = `curl -sS $indexurl`; #Use cURL to fetch index webpage.
print "Fetched!\n";

#Break the index page into chunks. There *should* be one usable link per chunk.
my @indexarray = split /Direct download:/, $index;

#Search the index chunks for the URLs of the specified episodes.
OUTER:  foreach my $number (@args) {
INNER:          foreach my $element (@indexarray) {
                #Gah! This regex could be a lot better...
                if ($element =~ m|http://traffic.libsyn.com/theamphour/[a-zA-Z_-]+$number[a-zA-Z_-]+[a-zA-Z0-9_-]+\.mp3|) {
                        push (@urls, $&); #Push URLs into an array.
                        last INNER; #Found it, look for the next one.
                }
        }
}

foreach my $url (@urls) {
	#Thanks, Google. Good developers may only use their best code once, but noobs like me can copy and paste it forever.
        $totalsize += `wget $url --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`;
}

#Make sure the user knows what they're doing. :)
print "Warning: going to download " .scalar(@args) . " files, " . scaleIt($totalsize) . ". Are you sure? [y/N]"; ##TODO #UPDATE I think this works now.
chomp ($_ = <STDIN>);
die "Ok, aborting.\n" unless (/^[Yy](?:es)?$/);
print "Ok, downloading...\n";

#Pass each URL to wget.
foreach my $url (@urls) {
        system("wget $url");
}
exit; #Done!

#Remove duplicate elements from arrays. Thanks StackOverflow!
sub uniq {
        my %seen;
        grep!$seen{$_}++, @_;
}

#Yoomin-readable filesizes. Thanks again, StackOverflow!
sub scaleIt {
    my( $size, $n ) =( shift, 0 );
    ++$n and $size /= 1024 until $size < 1024;
    return sprintf "%.2f %s",
          $size, ( qw[ bytes KB MB GB ] )[ $n ];
}
