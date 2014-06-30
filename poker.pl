#!/usr/bin/perl -w
# (c) Patrick Rhomberg, June 2014

use Term::ANSIColor;
sub print_top;

# Change these to different colors, if you prefer.  Order them from "good" to "bad"
#    Valid colors are: black  red  green  yellow  blue  magenta  cyan  white ; any may be prepended with `bright_`

our @color_rankings = (
    'bright_green','green',
    'bright_yellow','yellow',
    'bright_blue','blue',
    'bright_red','red'
    );





# I know I'm overusing global declaration.  But I never really intended anyone else to see this.


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

# get_color_i(hand,top)
sub get_color_i{
    my ($cards,$section) = @_;
    my $wedge_size = 325 / ($section * ($#color_rankings+1) );
    my $color = -1;
    my $tmp = 0;
    while($tmp < $weighted{$cards}){ $color++ ; $tmp += $wedge_size; }
    return $color;
}

hello();
print"\n>> ";
while(<>){
    chomp();
    my $inp = lc $_;
    unless($inp eq ""){
	if($inp =~ /exit/){ print "Goodbye!\n";last;}
	elsif($inp =~ /help/){  help(); }
	elsif($inp =~ /info/i){ info(); }
	elsif($inp =~ /odds (\w\w\w) (\d+)/){odds_against($1,$2);}
	elsif($inp =~ /^list top\s+(\d+)/){
	    my $players = $1;
	    print " Top 1/$players of possible hole cards:\n";
	    lookup_head();
	    foreach $w (sort( { $weighted{$a} <=> $weighted{$b} } keys(%weighted))){
		if( 325.0 / $weighted{$w} < $players){last;}
		else{ 
		    
		    lookup($w); 
		}
	    }
	}
	elsif($inp =~ /^top\s+(\d+)/){
	    my $players = $1;
	    print_top($players);
	}
	elsif($inp =~ /(\w)(\w)(\w?)\s*(\d*)/){
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

sub lookup_head{
    printf( "   hole ; static rank ; weighed rank\n" );
    printf( " -------------------------------------\n" );
}

#sub lookup(cards,sorted,ranks,beat){
sub lookup{
    my ($hand, $beat) = @_;
    printf( "    %-3s ;  %3d of 169 ; %3d of 325\n", f_hand($hand),$ranked{$hand},$weighted{$hand}); 
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
    print color 'bright_yellow';
    print "  Use at your own risk.\n";
    print color 'reset';
    print "\n";
    print "  (And while I feel obligated to put the above... it's a perl script.\n";
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
    print color 'bright_yellow';
    print "    exit\n";
    print color 'reset';
    print "       Exit this program.\n";
    print color 'bright_yellow';
    print "    help\n";
    print color 'reset';
    print "       Print this.\n";
    print color 'bright_yellow';
    print "    info\n";
    print color 'reset';
    print "       Print information regarding this program.\n";
    print color 'bright_yellow';
    print "    list top <n>\n";
    print color 'reset';
    print "       List the top 1/<n> ranked hole cards, in order.\n";
    print "       Example: `list top 5` lists the top 20% of hole cards.\n";
    print color 'bright_yellow';
    print "    top <n>\n";
    print color 'reset';
    print "       Gives `list top <n>` information in visual format.\n";
    print "         Coloring can be changed by a simple source edit.\n";
    print "       Example: `top 5` shows the top 20% of hole cards.\n";
    print color 'bright_yellow';
    print "    PENDING:list play <n> <f=0.5>\n";
    print color 'reset';
    print "       Gives hands to play in a game of <n> people,\n";
    print "         where you have <f> probability of holding the best cards.\n";
    print "       Computation is naive and does **not** consider\n";
    print "         the your hand when deciding an opponent's hand.\n";
    print color 'bright_yellow';
    print "    PENDING:play <n> <f=0.5>\n";
    print color 'reset';
    print "       as list play <n>, in visual format.\n";
    print color 'bright_yellow';
    print "    <possible hole cards>\n";
    print color 'reset';
    print "       Gives ranking information for input cards.\n";
    print "       Example: `ak`  gives information about Ace-King suited and offsuit.\n";
    print "                `t9o` gives information about Ten-Nine offsuit.\n";
    print "       (Input is not case or ordering sensitive.)\n";
    print color 'bright_yellow';
    print "    PENDING:<possible hole cards> <n>\n";
    print color 'reset';
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
		print color $color_rankings[get_color_i($hand.$suits,$top)];
		printf( "%-4s", (uc $hand) . $suits);
		print color 'reset';
	    }
	    else{ printf "%-4s", " . "; }
	}
	print "\n  ";
    }
    print "\n";
}

# odds_against(hand,weight,players)
sub odds_against{
    my ($hand,$players) = @_;
    $players--; # don't play against yourself.
    my $beat_by = $weighted{$hand} - 1;
    my $beat_per= $beat_by / 325.0;
    #                   I am not beat ** by anyone
    my $likelihood = (1.0 - $beat_per)**$players;
    return $likelihood;
}
