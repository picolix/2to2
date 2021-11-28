#!/bin/perl
# Picolix Design / Naeba / 2021/11/21

use strict;
use Time::Local;

my $top_domain = "gy";
my $listfile = "dlist.txt";

open(FP,"+>" . $listfile) or die("Error");

## STEP 1. whois from aa to zz##

my @str = ("aa".."zz");
foreach my $s1 (@str){
	my $domain = "$s1.$top_domain";
	my $cmd = "echo $domain ; whois $domain";
	print STDERR $domain . "...\n";
	my $rst = `$cmd`;
	print FP $rst;
	sleep 3;
}

## STEP 2. list create ##
seek(FP, 0, 0); 
while(<FP>){
	chop($_);  #LF

	if(/^..\.gy/){
		print "\n" . $_ . ",";
		next;
	}

	if(/Domain Status: No Object Found/){
		print ",";
		next;
	}


	if(/Creation Date/){
		my @data = split(/Creation Date: /,$_);
		#GMT to JST 
		my $tm = $data[1];
		$tm =~ /^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)/;
		my $utm = timegm($6, $5, $4, $3, $2-1, $1);
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($utm);
		my $timemsg = sprintf("%04d/%02d/%02d %02d:%02d:%02d",$year+1900,++$mon,$mday,$hour,$min,$sec);
		print $timemsg;
		next;
	}
	if(/Registrant Country/){
		my @data = split(/Registrant Country: /,$_);
		print "," .$data[1];
	}
}

print "\n";

close(FP);
