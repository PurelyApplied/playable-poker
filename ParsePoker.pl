#!/usr/bin/perl -w
# (c) Patrick Rhomberg, August 2013
# This program parses the pages of Cardfight.com to build a .csv sheet

use strict;
use Getopt::Std;
use LWP::Simple;
use URI::Escape;

my %opts;
sub process{
    my $c1 = $_[0];
    my $c2 = $_[1];
    my $s  = $_[2];
    my @input = @_;
    while(@input) {
	my $line = shift(@input);
	if($line =~ /Hand Rank:.*> (\d+) of 169/){
	    my $rnk = $1;
	    print "$c1$c2";
	    if( $s eq "s"){
		print "$s";
	    }
	    elsif( $s eq "o"){
		print "$s";
	    }
	    else{
		print " ";
	    }
	    printf (", %3d, ",$rnk);
	    my $perc = 0.0 + 100 * $rnk / 169 ;
	    printf ("%5.2f\n",$perc);
	}
    }
}




print "Name, Rank, Tier \n";
my @cardname = ('2','3','4','5','6','7','8','9','T','J','Q','K','A');
my @IsSuit = ('s','o');

my $ic1;
my $ic2;
my $so;
my $html;
my @inarr;
for ( $ic1 = 12 ; $ic1>=0 ; $ic1-- ){
    for ( $ic2 = $ic1 ; $ic2>=0 ; $ic2-- ){
	if ( $ic1 == $ic2){
	    $html= get("http://www.cardfight.com/$cardname[$ic1]$cardname[$ic2].html\n") or
		die ("Failed to fetch web data\n");
	    @inarr= split(/\n/m, $html);
	    &process($cardname[$ic1],$cardname[$ic2],-1,@inarr);
	}
	else {
	    for ( $so = 0 ; $so < 2 ; $so++ ){
		$html= get("http://www.cardfight.com/$cardname[$ic1]$cardname[$ic2]$IsSuit[$so].html\n") or
		    die ("Failed to fetch web data\n");
		@inarr= split(/\n/m, $html);
		&process($cardname[$ic1],$cardname[$ic2],$IsSuit[$so],@inarr);
	    }
	}
    }
}
