#! /usr/bin/perl

use strict;
use warnings;

$file = $ARGV[0];
open(INFO, $file) or die("Can not read the input");

$count = 0;

foreach $line (<INFO>) {
	chomp($line); #remove the new line
	# <th colspan>  area name
	# nowwrap 
	#rd 
	#<a href="scd007"

}

if ($ARGV[0] eq "あ"){
    print "Yes\n";
}
else{
    print "No \n";
}
