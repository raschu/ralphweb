#!/usr/bin/perl
#Hier wird der CSS String ersetzt, damit die Files in ralphschuler.ch Design passen
use strict;
no warnings;

my $file = $ARGV[0];

my $flipped = 'false';
open(DAT,"$file.pgn");
my @pgn = <DAT>;
close(DAT);

my $opp;
my $handle;
my $title;

for (@pgn) {
	next unless $_ =~ m/PerlHackr/;
	if ($_ =~ m/\[Black \"PerlHackr\"\]/) {
		$flipped  = 'true';
	}
}

for my $r (@pgn) {
    
    chomp $r;
    
    #print "DEBUG: r: $r\n";

    if ($r =~ m/\[Black / and $flipped eq 'false') {
        $opp = $r;
        $opp =~ s/\[Black //;
        $opp =~ s/\]//;
        $opp =~ s/\"//g;
        
    }
    if ($r =~ m/\[White / and $flipped eq 'true') {
        $opp = $r;
        $opp =~ s/\[White //;
        $opp =~ s/\]//;
        $opp =~ s/\"//g;     
    }
    
    ($handle, $title) = split(/ +/, $opp);
}


print "Board flip: $flipped; opp: $opp; title: $title\n";
#print "Board flip: $flipped\n";

my $string;
local $/ = undef;

open(IN, "$file"."0.html");
$string = <IN>;
close IN;

$string =~ s/\<style\>.*\<\/style\>/\<link rel\=\"stylesheet\" href\=\"\/css\/Envision_pgn.css\" type=\"text\/css\" \/\>/smg;
$string =~ s/Internet Chess Club/<br>Internet Chess Club/;
$string =~ s/$title//;
$string =~ s/PerlHackr/<a href=\"http:\/\/www\.chessclub\.com\/finger\/PerlHackr\" target\=\"_blank\">PerlHackr<\/a>/;
$string =~ s/$handle/<a href=\"http:\/\/www\.chessclub\.com\/finger\/$handle\" target\=\"_blank\">$handle<\/a>/;
$string =~ s/var flipped \= false\;/var flipped \= true\;/ if $flipped eq 'true';
$string =~ s/Round \-//;

$string =~ s/<small>This page was created with <a href=\"http:\/\/pgn2web.sourceforge.net\" target=\"\_top\">pgn2web<\/a>\.<\/small>/&nbsp;/;



open(OUT,">$file"."0.html");
print OUT ($string);
close OUT;

