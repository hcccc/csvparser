#! /usr/bin/perl

use strict;
use warnings;
use Switch;
use Data::Dumper;

sub getAreaInfo;
sub getShopInfo;
sub cleanup;

my $file = $ARGV[0];
open(INFO, $file) or die("Can not read the input");

my $count = 0;
my $shop_count = 0;
my %event_info;
my %shop_info;

my $bbtitle = "BBCP";
my $p4utitle = "P4U";
my $ggtitle = "GGAC";
my $area_final = "エリア決勝";

my $bb_out_file = 'bb_date.csv';
my $p4u_out_file = 'p4u_date.csv';
my $gg_out_file = 'gg_date.csv';


my $parseShopInfo = 0;

#getAreaInfo
my $subject = "";
my $shop_name = "";
my $shop_url = "";
my $region = "";
my $area_number = 0;
my $date = "";
my $event_title = 0;

#getShopMap
my $is_area_final = 0;
my $map_url = "";
my $address = "";
my $title = "";
my $tel = "";
my $bb_date = "";
my $is_bb_final = 0;
my $p4u_date = "";
my $is_p4u_final = 0;
my $gg_date = "";
my $is_gg_final = 0;



open(BBOUTFILE,">$bb_out_file") or die("Can not open output file");
print BBOUTFILE "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Description,Location,Private\n";
open(P4UOUTFILE,">$p4u_out_file") or die("Can not open output file");
print P4UOUTFILE "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Description,Location,Private\n";
open(GGOUTFILE,">$gg_out_file") or die("Can not open output file");
print GGOUTFILE "Subject,Start Date,Start Time,End Date,End Time,All Day Event,Description,Location,Private\n";


foreach my $line (<INFO>) {
	chomp($line); #remove the new line

	if ($parseShopInfo == 0 && $line =~ m/予選実施店舗詳細一覧/) {
		$parseShopInfo = 1;
	}

	if ($parseShopInfo == 0){
		getAreaInfo($line);
	}
	else {
		getShopInfo($line);
	}

}

cleanup();


for (my $i = 0; $i < $count; $i++) {
	$subject = $event_info{$i}{'subject'};
	$date = $event_info{$i}{'date'};
	$shop_name = $event_info{$i}{'shop_name'};
	$area_number = $event_info{$i}{'area_number'};
	$region = $event_info{$i}{'region'};
	$event_title = $event_info{$i}{'event_title'};

	#print "shop name: $shop_name\n";

	$shop_url = $shop_info{$shop_name}{'shop_url'};
	$tel = $shop_info{$shop_name}{'tel'};
	$address = $shop_info{$shop_name}{'address'};
	#$map_url = $shop_info{$shop_name}{'map_url'};
	$is_area_final = 0;

	switch ($event_title) {
		case 1	{ 
			if ($shop_info{$shop_name}{'is_bb_final'} == 1) {
				$is_area_final = 1;
			}
		}
		case 2  { 
			if ($shop_info{$shop_name}{'is_p4u_final'} == 1) {
				$is_area_final = 1;
			}
		}
		case 3  { 
			if ($shop_info{$shop_name}{'is_gg_final'} == 1) {
				$is_area_final = 1;
			}
		}
	}

	my $event_subject = "";
	my $description = "";
	if (defined($area_number)) {
		$event_subject = "$subject $region エリア$area_number $shop_name予選"; 
	}
	else {
		$event_subject = "$subject $region $shop_name予選"; 
	}

	if ($is_area_final == 1) { 	
		$event_subject = $event_subject . "[エリア決勝]";
	}

	$description = $event_subject;

	if ($shop_url ne '') {
		$description = $description . "  URL: $shop_url";
	}

	$description = $description . "  $tel";

	my $map_detail = $shop_name . "  " . $address;

	switch ($event_title) {
		case 1 {
			print BBOUTFILE "$event_subject,$date,0:00,$date,0:00,true,$description,$map_detail,false\n";
		}
		case 2 {
			print P4UOUTFILE "$event_subject,$date,0:00,$date,0:00,true,$description,$map_detail,false\n";
		}
		case 3 {
			print GGOUTFILE "$event_subject,$date,0:00,$date,0:00,true,$description,$map_detail,false\n";
		}
	}

} 


#print Dumper(\%event_info); 
#print Dumper(\%shop_info);
#my $size = scalar(keys %event_info);
#print "$size\n";


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

	if ($line =~ m/\<th.*\>(.*エリア)/) {
		$region = $1;
	}

	if ($line =~ m/ア\<br\s\/\>\s?(.*)\<\/th\>/) {
		$area_number = $1;
	} 

	if ($line =~ m/\<th\scolspan=\"3\"\>.*エリア\<\/th\>/) {
		undef $area_number;
	}

	if ($line =~ m/\<a\shref="#scd[0-9]{3}"\>(.*)\<\/a\>/) {
		$1 =~ m/(.*)\<\/a\>/;
		$shop_name = $1;

		switch ($event_title) {
			case 1	{ $subject = "[$bbtitle]"; }
			case 2  { $subject = "[$p4utitle]"; }
			case 3  { $subject = "[$ggtitle]";	}
		}

		$event_info{$count}{'subject'} = $subject;
		$event_info{$count}{'region'} = $region;
		$event_info{$count}{'shop_name'} = $shop_name;
		$event_info{$count}{'date'} = $date;
		$event_info{$count}{'area_number'} = $area_number;
		$event_info{$count}{'event_title'} = $event_title;

		$count++;
	}

	if ($line =~ m/([0-9]+)月([0-9]+)日/) {
		$date = "$1/$2/2013";
	}
}


sub getShopInfo {

	my $line = $_[0];

	# url (if available) and shop name
	if ($line =~ m/\<th\>.*href="(.*)"\starget.*scd_link_hp"\>(.*)\<\/a\>/) {
		$shop_name = $2;
		$shop_url = $1; 
	}
	elsif ($line =~ m/\<th\>(.*)\<\/th\>/) {		
		$shop_name = $1;
	}


	if ($line =~ m/span\sclass="(.*)"\>.*([0-9]+)月([0-9]+)日(.*)/) {
		if ($1 eq "icon_bb") {
			$bb_date = "$2/$3/2013";
			if ($4 =~ m/エリア決勝/) {
				$is_bb_final = 1;
			}
			else {
				$is_bb_final = 0;
			}
		} elsif ($1 eq "icon_p4u") {
			$p4u_date = "$2/$3/2013";
			if ($4 =~ m/エリア決勝/) {
				$is_p4u_final = 1;
			}
			else {
				$is_p4u_final = 0;
			}
		} elsif ($1 eq "icon_ggx") {
			$gg_date = "$2/$3/2013";
			if ($4 =~ m/エリア決勝/) {
				$is_gg_final = 1;
			}
			else {
				$is_gg_final = 0;
			}
		}

	}

	#map
	if ($line =~ m/href="(.*)"\starget.*scd_link_map"\>(.*)\<\/a\>/) {
		$map_url = $1;
		$address = $2;
	}

	#if ($line =~ m/.*scd_link_map.*target="_blank"\>(.*)\<\/a\>/) {
	#	$address = $1;
	#}


	if ($line =~ m/(TEL:.*)\<\/td\>/) {
		$tel = $1;

		$shop_info{$shop_name}{'tel'} = $tel;
		$shop_info{$shop_name}{'address'} = $address;
		#$shop_info{$shop_name}{'map_url'} = $map_url;
		$shop_info{$shop_name}{'shop_url'} = $shop_url;

		if($bb_date ne ""){
			$shop_info{$shop_name}{'bb_date'} = $bb_date;
			$shop_info{$shop_name}{'is_bb_final'} = $is_bb_final;
		}
		if($p4u_date ne ""){
			$shop_info{$shop_name}{'p4u_date'} = $p4u_date;
			$shop_info{$shop_name}{'is_p4u_final'} = $is_p4u_final;
		}
		if($gg_date ne ""){
			$shop_info{$shop_name}{'gg_date'} = $gg_date;
			$shop_info{$shop_name}{'is_gg_final'} = $is_gg_final;
		}

		cleanup();
		$shop_count++;
	}
}


sub cleanup {
	#getAreaInfo
	$subject = "";
	$shop_name = "";
	$shop_url = "";
	$region = "";
	$area_number = 0;
	$date = "";
	$event_title = 0;

	#getShopMap
	$is_area_final = 0;
	$map_url = "";
	$address = "";
	$title = "";
	$tel = "";
	$bb_date = "";
	$is_bb_final = 0;
	$p4u_date = "";
	$is_p4u_final = 0;
	$gg_date = "";
	$is_gg_final = 0;
}

#print CSVFILE "$subject,$date,$date,true,$subject,$location,false\n";
close (INFO);
close (BBOUTFILE);
close (P4UOUTFILE);
close (GGOUTFILE);

exit 0;
