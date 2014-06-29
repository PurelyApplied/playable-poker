#!/usr/bin/perl -w
# (c) Patrick Rhomberg, June 2014

my %ranked;
my %weight;
my %sorted;
my @cards = (
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    't',
    'j',
    'q',
    'k',
    'a'
);

my @valarr = (
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    't',
    'j',
    'q',
    'k',
    'a'
);

print "\n Texas Hold'em pocket cards ranking reference.\n\n";
print "  This program returns the static and weighted rankings of a given set of hole cards in Texas Hold'em.\n";
print "  Static card ranking of 169 possible combinations taken from www.cardfight.com\n";
print "  Off-suit combinations are weighed by a factor of three to adjust for their relative likelihood.\n";

print "\n Source code written by Patrick Rhomberg, June 2014.\n";

print "Enter your pocket cards in nonincreasing order.\n";
print "  Use T do denote a ten.\n";
print "  Optionally, include 's' or 'o' for suited or off-suit, respectively.\n";
print "  Matching is not case sensitive.\n";
print "  Examples:  aK, jj, t5s, J2o, top 7\n";
print "\nUse ctrl-D to terminate in *nix environments, ctrl-C in Windows.\n  (Not sure what signals eof in Mac, sorry.)\n";

open( RANKING, "<", "./Ranking");



for(<RANKING>){
    if(/^(\w\w)([\w ]),\s+(\d+),\s+\d+.\d+/){
	my $c=lc $1;
	unless($2 eq " "){ $c = $c.$2; }
	my $r=$3;
	$ranked{$c} = $r;
	$weight{$r} = $c;
	if($c=~/o/){
	    $weight{$r+0.1}=$c;
	    $weight{$r+0.2}=$c;
	}
    }
}

my $current = 1;
foreach $w (sort( { $a <=> $b } keys(%weight))){
 #   print "$weight{$w} has weighted rank $w\n";
    unless( defined( $sorted{ $weight{$w} } ) ){
	$sorted{ $weight{$w} }=$current;
	if( $weight{$w} =~ /o/ ){ $current+=3;}
	else{ $current++; }
    }
}

print"\n>> ";
while(<>){
    chomp();
    my $inp = lc $_;
    unless($inp eq ""){
	if($inp =~ /^top\s+(\d+)/){
	    my $players = $1;
	    print "Good hands for a $players player game:\n";
	    foreach $w (sort( { $sorted{$a} <=> $sorted{$b} } keys(%sorted))){
		if( 325.0 / $sorted{$w} < $players){last;}
		else{ printf( " %-3s ", $w); }
	    }
	}
	elsif($inp =~ /^good\s+(\d+)/){
	    my $players = $1;
	    print "Good hands for a $players player game:\n";
	    for( my $row = $#cards ; $row >= 0; $row--){
		for( my $col = $#cards ; $col >= 0; $col--){
		    my $hand;
		    my $suits;
		    if(  $row == $col ){
			$hand = $cards[$row] . $cards[$col];
			$suits='';
		}
		    elsif( $row < $col ){
			$hand = $cards[$col] . $cards[$row];
			$suits='o';
		}
		    else{
			$hand = $cards[$row] . $cards[$col] ;
			$suits='s';
		}
		
		
		my $toprint;
		if( 325.0 / $sorted{$hand.$suits} >= $players){
			printf( "%-4s", (uc $hand) . $suits);
		}
		else{ printf "%-4s", "---"; }
	}
	print "\n";
    	}}
	else{
	    my $l1 = $inp;
	    my $l2 = $inp.'o';
	    my $l3 = $inp.'s';
	    
	    if( defined $sorted{$l1}){
		printf("%s plays even at %02.2f players.\n  (simple rank %3d of 169, top %5.2f%% ; weighted rank %3d of 325, top %5.2f%%)\n",
		       $l1,325.0/$sorted{$l1},
		       $ranked{$l1}, $ranked{$l1} / 1.690,
		       $sorted{$l1}, $sorted{$l1} / 3.250);
	    }
	    
	    if( defined $sorted{$l2}){
		printf("%s plays even at %02.2f players.\n  (simple rank %3d of 169, top %5.2f%% ; weighted rank %3d of 325, top %5.2f%%)\n",
		       $l2,325.0/$sorted{$l2},
		       $ranked{$l2}, $ranked{$l2} / 1.690,
		       $sorted{$l2}, $sorted{$l2} / 3.250);
	    }
	    
	    if( defined $sorted{$l3}){
		printf("%s plays even at %02.2f players.\n  (simple rank %3d of 169, top %5.2f%% ; weighted rank %3d of 325, top %5.2f%%)\n",
		       $l3,325.0/$sorted{$l3},
		       $ranked{$l3}, $ranked{$l3} / 1.690,
		       $sorted{$l3}, $sorted{$l3} / 3.250);
	    }
	}   
    }
    print"\n>> ";
}
print "\n";

