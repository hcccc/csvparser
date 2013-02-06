#! /usr/bin/perl

use strict;
use warnings;

my $file = $ARGV[0];
open(INFO, $file) or die("Can not read the input");

my $count = 0;
my @infolist;

my $bbtitle = "BBCP";
my $p4utitle = "P4U";
my $ggtitle = "GGAC";
my $event = 0; 


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

	if ($line =~ m/エ.*リ.*ア/){
		print "$line\n";
	}

	$infolist[$count] = $line;
	$count++;
}

if ($ARGV[0] eq "あ"){
    print "Yes\n";
}
else{
    print "No \n";
}
