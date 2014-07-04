This is a Perl script.
If you are using a Windows machine, you will need to download Perl.
It should be standard on any *nix or Mac machine.

Downloading Perl for Windows:
  I personally use Strawberry, which is available as a free download at strawberryperl.com.
  ( If you have any interest in programming, I would recommending getting the Padre.
    It runs off Strawberry, but provides a good Perl editor and allows easy execution of your scripts.
    It is available at padre.perlide.org. )

Running this script:
  This script requires a terminal interface.
  Windows users can likely achieve this my running win_poker.bat once Perl is installed.
  This should open a terminal (cmd.exe) window and prompt for input.
  *nix and Mac users should may navigate to the script in the shell and run from the command line.
  Any may, depending on operating system, run the script by bringing up the menu and selecting "Run in Terminal."
  Additional information can be found within the program using `help` or `info` commands, which are also present at the bottom of this Readme.

  The file `Ranking` must be in active directory for the program to execute correctly.

  *nix users and (possibly) Mac users will enjoy additional coloring of reported data.
  If a Windows user wishes to have color, they will likely need a console emulator to do so.
  I recommend ConEmu, as I know that the ANSI coloring used works with it.
  Full monochrome functionality exists regardless.
  
  Color options (that is, whether color is used in Windows and what colors are used) are editable in the beginning of the source script poker.pl
  
  Enjoy.



Help:
  Valid commands, listed in parse order:
    exit
       Exit this program.
    help
       Print this.
    info
       Print information regarding this program.
    list top <n>
       List the top 1/<n> ranked hole cards, in order.
       Example: `list top 5` lists the top 20% of hole cards.
    top <n>
       Gives `list top <n>` information in visual format.
         Coloring can be changed by a simple source edit.
       Example: `top 5` shows the top 20% of hole cards.
    list play <n> <r=50>
       Gives hands to play in a game of <n> people,
         where you have at least <r>% chance to have the best cards.
       Computation is naive and does **not** consider
         the your hand when deciding an opponent's hand.
       If <r> is not provided, uses 50% as the threshold.
       Example: `list play 5` lists the hands that have even odds
           of being the best hole cards in a 5 player game (counting yourself).
       Example: `list play 6 75` lists the hands that have 75% chance
           of being the best hole cards in a 6 player game (counting yourself).
    play <n> <f=0.5>
       As with `top <n>`, gives the `list play` information visually.
    <possible hole cards>
       Gives ranking information for input cards.
       Example: `ak`  gives information about Ace-King suited and offsuit.
                `t9o` gives information about Ten-Nine offsuit.
       (Input is not case or ordering sensitive.)
    <possible hole cards> <n>
      Gives ranking information for input cards, as above.
      Additionally, gives naive odds of those cards being the best
         in a game of <n> players (count yourself).

Info:
  This program relies on weighted rankings of Texas Hold'em hole cards.
  Static card ranking of 169 possible combinations taken from www.cardfight.com
  Off-suit hole cards are weighed by a factor of three to adjust for their likelihood.

  This program is to be used only as a reference.
  The creator assumes no responsibility for its usage,
    actions based on reported information, et cetera.

  This program is inaccurate.
  Both `play` commands report % chance of holding the best hand naively.
  In effect, every player is given a number of 1-325, corresponding to some hand (off-suits weighted)
  It does *not* take into consideration the reduced likelihood of an opponent receiving, for instance, an ace, given the fact that you have one.

  And as always, poker is a game of chance.
  Remember that the best cards don't always win.
  If they did, it wouldn't be called `gambling.`

  Use at your own risk.

  (And while I feel obligated to put the above... it's a Perl script.
   You can look at the source.
   Learn how to read some code.
   Make sure I'm not ruining your computer.
   That's cyber-responsibility in this day and age.)

