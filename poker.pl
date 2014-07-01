#!/usr/bin/perl -w
# (c) Patrick Rhomberg, June 2014

use Term::ANSIColor;
sub print_top;



########## 
# Edit this if you want different colors.
# Order them from "good" to "bad"
# Valid colors are: black  red  green  yellow  blue  magenta  cyan  white ; any may be prepended with `bright_`
our @color_rankings = (
    'bright_green',
    'green',
    'bright_yellow',
    'yellow',
    'bright_blue',
    'blue',
    'bright_red'#,
    #'red'
    );

# Unless you know what you're doing, don't change anything else.
##########

our @cards = ('2','3','4','5','6','7','8','9','t','j','q','k','a');
our %values = (
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    't' => 10,
    'j' => 11,
    'q' => 12,
    'k' => 13,
    'a' => 14
    );

our %ranked;
our %fractional;
our %weighted;

# build hashes
open( RANKING, "<", "./Ranking");

for(<RANKING>){
    if(/^(\w\w)([\w ]),\s+(\d+),\s+\d+.\d+/){
	my $c=lc $1;
	unless($2 eq " "){ $c = $c.$2; }
	my $r=$3;
	$ranked{$c} = $r;
	$fractional{$r} = $c;
	if($c=~/o/){
	    $fractional{$r+0.1}=$c;
	    $fractional{$r+0.2}=$c;
	}
    }
}

my $current = 1;
foreach $w (sort( { $a <=> $b } keys(%fractional))){
    unless( defined( $weighted{ $fractional{$w} } ) ){
	$weighted{ $fractional{$w} }=$current;
	if( $fractional{$w} =~ /o/ ){ $current+=3;}
	else{ $current++; }
    }
}


#################
## main:
#################

# get_color_i(hand,section)
sub get_color_i{
    my ($cards,$section) = @_;
    my $wedge_size = 325 / ($section * ($#color_rankings+1) );
    my $color = int( $weighted{$cards} / $wedge_size);
    return $color_rankings[$color];
}

hello();
print"\n>> ";
while(<>){
    chomp();
    my $inp = lc $_;
    unless($inp eq ""){
	if($inp =~ /^\s*exit/){ print "Goodbye!\n";last;}
	elsif($inp =~ /^\s*help/){  help(); }
	elsif($inp =~ /^\s*info/i){ info(); }
	elsif($inp =~ /^\s*odds (\w\w\w) (\d+)/){odds_to_win($1,$2);}
	elsif($inp =~ /^\s*list top\s+(\d+)/){
#	    my $section = $1;
	    list_top($1);
	}
	elsif($inp =~ /^\s*top\s+(\d+)/){
	    print_top($1);
	}
	elsif($inp =~ /^\s*list play\s+(\d+)\s*(\d*)/){
	    list_play($1,$2);
	}
	elsif($inp =~ /^\s*play\s+(\d+)\s*(\d*)/){
	    print_play($1,$2);
	}
	elsif($inp =~ /^\s*(\w)(\w)(\w?)\s*(\d*)/){
	    my ($c1, $c2, $suit, $beat) = ($1, $2, $3, $4);
	    if(0==is_a_card($c1)){     print "$c1 is not a valid card.\n"; }
	    elsif(0==is_a_card($c2)){  print "$c2 is not a valid card.\n"; }
	    else{
		if( $values{$c1} < $values{$c2} ){ my $tmp = $c2; $c2 = $c1; $c1 = $tmp; }
		my $hand = $c1 . $c2;
		# if an invalid suit is provided, we ignore it.
		if($suit ne 'o' && $suit ne 's'){$suit = '';}
		
		# if a suit is provided or we have a pocket pair
		if($suit ne "" || $c1 eq $c2){
		    lookup_head();
		    lookup($hand.$suit, $beat);
		}
		else{
		    lookup_head();
		    lookup($hand.'s', $beat);
		    lookup($hand.'o', $beat);
		}
	    }
	}
    }
    print"\n>> ";
}
print "\n";

############
## subs
############


#! Correct color scheme: get wedge size ; int ( value / wedge size )
# g_c_b_r($hand,$odds,$players);
sub get_color_by_rate{
    my ($hand, $rate, $players) = @_;
    my $odds = odds_to_win($hand,$players);
    my $wedge_size = (100.0 - $rate) / ($#color_rankings+1);
    my $color = int( (100.0 - $odds) / $wedge_size);
    return $color_rankings[$color];
}

#! rate should be in %?

#l_p(players,rate)
sub list_play{
    my ($players, $rate) = @_;
    unless(length($rate)>0){ $rate=50; }
    lookup_head($players);
    foreach $w (sort( { $weighted{$a} <=> $weighted{$b} } keys(%weighted))){
	my $odds = odds_to_win($w,$players);
	if( $odds < $rate ){last;}
	else{
	    unless($^O =~ /win/i){
		print color get_color_by_rate($w,$rate,$players);
	    }
	    lookup($w,$odds); 
	    unless($^O =~ /win/i){
		print color 'reset';
	    }
	}
    }
    
}

sub print_play{
    my ($players,$rate) = @_;
    print " Hands with at least $rate% chance of being best\n";
    print "   in a game of $players players.\n  ";
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
	    my $odds = odds_to_win($hand.$suits,$players);
	    if( $odds >= $rate){
		print color get_color_by_rate($hand.$suits,$rate,$players);
		printf( "%-4s", (uc $hand) . $suits);
		print color 'reset';
	    }
	    else{ printf "%-4s", " . "; }
	}
	print "\n  ";
    }
    print "\n";
}

sub list_top{
    my ($section) = @_;
    print " Top 1/$section of possible hole cards:\n";
    lookup_head();
    foreach $w (sort( { $weighted{$a} <=> $weighted{$b} } keys(%weighted))){
	if( 325.0 / $weighted{$w} < $section){last;}
	else{
	    unless($^O =~ /win/i){print color get_color_i($w,$section);}
	    lookup($w); 
	    unless($^O =~ /win/i){print color 'reset';}
	}
    }
}

sub lookup_head{
    my ($players) = @_;
    print( "   hole ; static rank ; weighed rank " );
    if(length($players)){printf(                "; odds with %d players",$players);}
    print "\n";
    print( " -------------------------------------" );
    if(length($players)){print                  "----------------------";}
    print "\n";
}

#sub lookup(cards,sorted,ranks,beat){
sub lookup{
    my ($hand, $odds) = @_;
    printf( "    %-3s ;  %3d of 169 ; %3d of 325", f_hand($hand),$ranked{$hand},$weighted{$hand}); 

    if(length($odds)){
	printf ( "   ; %0.3f%% ", $odds );
    }
    print "\n";
}

sub hello{
    print "\n Texas Hold'em pocket cards ranking reference.\n\n";
    print "\n Source code written by Patrick Rhomberg, June 2014.\n";
    print "  Enter 'help` for possible commands.\n";
    print "  Enter `info` for information regarding this program.\n";
    print "  Enter `exit` or an end-of-file signal to terminate.\n";
}

sub info{
    print "  This program relies on weighted rankings of Texas Hold'em hole cards.\n";
    print "  Static card ranking of 169 possible combinations taken from www.cardfight.com\n";
    print "  Off-suit hole cards are weighed by a factor of three\n   to adjust for their likelihood.\n";
    print "\n";
#print "  No reported information takes into consideration the mutual exclusivity of hands.\n";
#print "\n";
    print "  This program is to be used only as a reference.\n";
    print "  The creator assumes no responsibility for its usage,\n";
    print "    actions based on reported information, et cetera.\n";
    print "\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "  Use at your own risk.\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "\n";
    print "  (And while I feel obligated to put the above... it's a Perl script.\n";
    print "   You can look at the source.\n";
    print "   Learn how to read some code.\n";
    print "   Make sure I'm not ruining your computer.\n";
    print "   That's cyber-responsibility in this day and age.)\n";
}

sub f_hand{
    my ($h) = @_;
    my @c = split('',$h);
    my $ret = (uc $c[0]) . (uc $c[1]);
    if( $#c == 2){$ret = $ret . $c[2];}
    return $ret;
}


sub help{
    print "  Valid commands, listed in parse order:\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    exit\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       Exit this program.\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    help\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       Print this.\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    info\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       Print information regarding this program.\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    list top <n>\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       List the top 1/<n> ranked hole cards, in order.\n";
    print "       Example: `list top 5` lists the top 20% of hole cards.\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    top <n>\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       Gives `list top <n>` information in visual format.\n";
    print "         Coloring can be changed by a simple source edit.\n";
    print "       Example: `top 5` shows the top 20% of hole cards.\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    list play <n> <r=50>\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       Gives hands to play in a game of <n> people,\n";
    print "         where you have at least <r>% chance to have the best cards.\n";
    print "       Computation is naive and does **not** consider\n";
    print "         the your hand when deciding an opponent's hand.\n";
    print "       If <r> is not provided, uses 50% as the threashold.\n";
    print "       Example: `list play 5` lists the hands that have even odds\n";
    print "           of being the best hole cards in a 5 player game (counting yourself).\n";
    print "       Example: `list play 6 75` lists the hands that have 75% chance\n";
    print "           of being the best hole cards in a 6 player game (counting yourself).\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    play <n> <f=0.5>\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       As with `top <n>`, gives the `list play` infomation visually.\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    <possible hole cards>\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "       Gives ranking information for input cards.\n";
    print "       Example: `ak`  gives information about Ace-King suited and offsuit.\n";
    print "                `t9o` gives information about Ten-Nine offsuit.\n";
    print "       (Input is not case or ordering sensitive.)\n";
    unless($^O =~ /win/i){    print color 'bright_yellow';}
    print "    PENDING:<possible hole cards> <n>\n";
    unless($^O =~ /win/i){    print color 'reset';}
    print "      Gives ranking information for input cards, as above.\n";
    print "      Additionally, gives naive odds of those cards being the best\n";
    print "         in a game of <n> players (count yourself).\n";
}

sub is_a_card{
    if($_[0] ~~ ['2','3','4','5','6','7','8','9','t','j','q','k','a']) {return 1;}
    else{ return 0;}
}

sub print_top(\$\@\%){
    my ($top) = @_;
    print " Top 1/$top of possible hole cards:\n\n  ";
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
	    if( $weighted{$hand.$suits} <= 325.0 / $top){
		print color get_color_i($hand.$suits,$top);
		printf( "%-4s", (uc $hand) . $suits);
		print color 'reset';
	    }
	    else{ printf "%-4s", " . "; }
	}
	print "\n  ";
    }
    print "\n";
}

# odds_to_win(hand,weight,players)
sub odds_to_win{
    my ($hand,$players) = @_;
    $players--; # don't play against yourself.
    my $beat_by = $weighted{$hand} - 1;
    my $beat_per= $beat_by / 325.0;
    #                   I am not beat ** by anyone
    my $likelihood = (1.0 - $beat_per)**$players;
    return (100*$likelihood);
}
