#! /usr/bin/perl

use strict;
use warnings;
use Switch;

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

my $outfile = 'date.csv';

open(CSVFILE,">>$outfile") or die("Can not open output file");
print CSVFILE "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Description,Location,Private\n";


foreach my $line (<INFO>) {
	chomp($line); #remove the new line

	# new shop 
	if ($line =~ m/\<a\sid="scd.*"\>/) {
		$count++;
	}

	if ($line =~ m/\<th\>.*"(.*)".*scd_link_hp/) {
		print $1;
	}


	my $subject = "";
	my $location = "";
	my $region = "";
	my $area_number = 0;
	my $date = "";


	if ($line =~ m/\<th.*\>(.*エリア)/) {
		print "$1\n";
		$region = $1;
	}

	if ($line =~ m/エ.*リ.*ア\<br\s\/\>(.*)\<\/th\>/) {
		print "エリア$1\n";
		$area_number = $1;
	}

	if ($line =~ m/\<a\shref="#scd[0-9]{3}"\>(.*)\<\/a\>/) {
		$1 =~ m/(.*)\<\/a\>/;
		print "Location: $1\n";
		$location = $1;
	}

	if ($line =~ m/([0-9]+)月([0-9]+)日/) {
		print "Date: $1/$2/2013\n";
		$date = "$1/$2/2013";
	}


	switch ($event) {
		case 1	{ $subject = "[$bbtitle]$region $location予選"; }
		case 2  { $subject = "[$p4utitle]$region $location予選";	}
		case 3  { $subject = "[$ggtitle]$region $location予選";	}
	}

	print CSVFILE "$subject,$date,$date,true,$subject,$location,false\n";

	#$infolist[$count] = $line;
	#$count++;
}

close (INFO);
close (CSVFILE);

exit 0;
