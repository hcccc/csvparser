#! /usr/bin/perl

use strict;
use warnings;
use Switch;
use Data::Dumper;

sub getAreaInfo;
sub getShopInfo;

my $file = $ARGV[0];
open(INFO, $file) or die("Can not read the input");

my $count = 0;
my %event_info;
my %shop_info;

my $bbtitle = "BBCP";
my $p4utitle = "P4U";
my $ggtitle = "GGAC";
my $area_final = "エリア決勝";
my $outfile = 'date.csv';

my $parseShopInfo = 0;
my $subject = "";
my $shop_name = "";
my $shop_url = "";
my $region = "";
my $area_number = 0;
my $date = "";
my $event_title = 0;


open(CSVFILE,">>$outfile") or die("Can not open output file");
print CSVFILE "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Description,Location,Private\n";


foreach my $line (<INFO>) {
	chomp($line); #remove the new line

	if ($parseShopInfo == 0 && $line =~ m/予選実施店舗詳細一覧/) {
		$parseShopInfo = 1;
	}

	if ($parseShopInfo == 0){
		getAreaInfo($line);
	}
	else {
		#getShopInfo($line);
	}

}


sub getAreaInfo {
	my $line = $_[0];

	if ($line =~ m/BBCP/) {
		$event_title = 1;
	}

	if ($line =~ m/P4U/) {
		$event_title = 2;
	}

	if ($line =~ m/GGACPR/) {
		$event_title = 3;
	}

	if ($line =~ m/\<a\shref="#scd.*"\>/) {
		if($count == 0) {
			$count++;
		}
		else {
			switch ($event_title) {
				case 1	{ $subject = "[$bbtitle]$region $shop_name予選"; }
				case 2  { $subject = "[$p4utitle]$region $shop_name予選";	}
				case 3  { $subject = "[$ggtitle]$region $shop_name予選";	}
			}

			$event_info{$count}{'subject'} = $subject;
			$event_info{$count}{'region'} = $region;
			$event_info{$count}{'shop_name'} = $shop_name;
			$event_info{$count}{'date'} = $date;
			$event_info{$count}{'area_number'} = $area_number;

			$count++;
		}
	}

	if ($line =~ m/\<th\>.*"(.*)".*scd_link_hp/) {
		print $1;
		$shop_url = $1;
	}

	if ($line =~ m/\<th.*\>(.*エリア)/) {
		print "$1\n";
		$region = $1;
	}

	if ($line =~ m/.*ア\<br\s\/\>(.*)\<\/th\>/) {
		print "エリア$1\n";
		$area_number = $1;
	}

	if ($line =~ m/\<a\shref="#scd[0-9]{3}"\>(.*)\<\/a\>/) {
		$1 =~ m/(.*)\<\/a\>/;
		print "Location: $1\n";
		$shop_name = $1;
	}

	if ($line =~ m/([0-9]+)月([0-9]+)日/) {
		print "Date: $1/$2/2013\n";
		$date = "$1/$2/2013";
	}

	#print CSVFILE "$subject,$date,$date,true,$subject,$location,false\n";

	#$infolist[$count] = $line;
	#$count++;

}


sub getShopInfo {
	my $subject = "";
	my $location = "";
	my $region = "";
	my $area_number = 0;
	my $date = "";
	my $url = "";

	my $is_area_final = 0;
	my $map_url = "";
	my $address = "";

	my $title = "";
	my $tel = "";

	my $line = $_[0];

	# new shop 
	if ($line =~ m/\<a\sid="scd.*"\>/) {
		$count++;
		print "\n";
	}

	# url (if available) and shop name
	if ($line =~ m/\<th\>.*href="(.*)"\starget.*scd_link_hp"\>(.*)\<\/a\>/) {
		print "$1\n";
	}
	elsif ($line =~ m/\<th\>(.*)\<\/th\>/) {
		print "$1\n";
		$shop_name = $1;
	}

	if ($line =~ m/(TEL:.*)\<\/td\>/) {
		print "$1\n"; 
		$tel = $1;
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
