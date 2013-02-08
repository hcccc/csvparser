#! /usr/bin/perl

use strict;
use warnings;
use Switch;

my $file = $ARGV[0];
open(INFO, $file) or die("Can not read the input");

my $count = 0;
my $event = 0;

my %shopinfo;

my $bbtitle = "BBCP";
my $p4utitle = "P4U";
my $ggtitle = "GGAC";
my $area_final = "エリア決勝";

my $outfile = 'date.csv';

open(CSVFILE,">>$outfile") or die("Can not open output file");
print CSVFILE "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Description,Location,Private\n";


foreach my $line (<INFO>) {
	chomp($line); #remove the new line

	my $subject = "";
	my $location = "";
	my $region = "";
	my $area_number = 0;
	my $date = "";
	my $url = "";
	my $shop_name = "";
	my $is_area_final = 0;
	my $map_url = "";
	my $address = "";

	my $title = "";
	my $tel = "";

	# new shop 
	if ($line =~ m/\<a\sid="scd.*"\>/) {
		$count++;
		print "\n";
	}

	# url (if available) and shop name
	if ($line =~ m/\<th\>.*href="(.*)"\starget.*scd_link_hp"\>(.*)\<\/a\>/) {
		$shopinfo{$count}{"url"} = $1;
		$shopinfo{$count}{"shop_name"} = $2;
		print "$shopinfo{$count}{'shop_name'}: $1\n";
	}
	elsif ($line =~ m/\<th\>(.*)\<\/th\>/) {
		print "$1\n";
		$shop_name = $1;
		$shopinfo{$count}{"shop_name"} = $1;
	}

	if ($line =~ m/(TEL:.*)\<\/td\>/) {
		print "$1\n"; 
		$tel = $1;
		$shopinfo{$count}{"tel"} = $1;
	}

	if ($line =~ m/span\sclass="(.*)"\>.*([0-9]+)月([0-9]+)日(.*)/) {
		if ($1 eq "icon_bb") {
			$title = $bbtitle;
		} elsif ($1 eq "icon_p4u") {
			$title = $p4utitle;
		} elsif ($1 eq "icon_ggx") {
			$title = $ggtitle;
		}

		$date = "$2/$3/2013";

		if ($4 =~ m/エリア決勝/) {
			$is_area_final = 1;
		}

		if ($is_area_final) {
			print "$title: $date  $area_final\n";
		}
		else {
			print "$title: $date\n";
		}

		#$shopinfo{$count}{$title}{$date} = $2;
		
	}

	#map
	if ($line =~ m/href="(.*)"\starget.*scd_link_map"\>(.*)\<\/a\>/) {
		print "$2: $1\n";
		$map_url = $1;
		$address = $2;
	}


	#$infolist[$count] = $line;
	#$count++;
}


#print CSVFILE "$subject,$date,$date,true,$subject,$location,false\n";
close (INFO);
close (CSVFILE);

exit 0;
