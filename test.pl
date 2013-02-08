#! /usr/bin/perl

use strict;
use warnings;

my $file = $ARGV[0];
open(INFO, $file) or die("Can not read the input");

my $count = 0;
my $event = 0;

my @bbinfo;
my @p4uinfo;
my @gginfo;

my $bbtitle = "BBCP";
my $p4utitle = "P4U";
my $ggtitle = "GGAC";

foreach my $line (<INFO>) {
	chomp($line); #remove the new line
	# <th colspan>  area name
	# nowwrap 
	#rd 
	#<a href="scd007"

	if ($line =~ $bbtitle) {
		print "$line\n";
	}

	if ($line =~ $p4utitle) {
		print "$line\n";
	}

	if ($line =~ $ggtitle) {
		print "$line\n";
	}

	if ($line =~ m/\<th.*\>(.*エリア)/) {
		print "$1\n";
	}

	if ($line =~ m/エ.*リ.*ア\<br\s\/\>(.*)\<\/th\>/) {
		print "エリア$1\n";
	}

	if ($line =~ m/\<a\shref="#scd[0-9]{3}"\>(.*)\<\/a\>/) {
		$1 =~ m/(.*)\<\/a\>/;
		print "Location: $1\n";
	}

	if ($line =~ m/([0-9]+)月([0-9]+)日/) {
		print "Date: $1/$2/2013\n";
	}


	#$infolist[$count] = $line;
	#$count++;
}

if ($ARGV[0] eq "あ"){
    print "Yes\n";
}
else{
    print "No \n";
}
