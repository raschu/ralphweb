#!/usr/bin/perl
#Hier wird der CSS String ersetzt, damit die Files in ralphschuler.ch Design passen
use strict;
use warnings;

local $/ = undef;

my $flipped = 'false';
open(DAT,"/root/ralphweb/public/chess/icc/lastgame.pgn");
my @pgn = <DAT>;
close(DAT);

for (@pgn) {
	next unless $_ =~ m/PerlHackr/;
	if ($_ =~ m/\[Black \"PerlHackr\"\]/) {
		$flipped  = 'true';
	}
}

print "Board flip: $flipped\n";

my $string;

open(DAT, "/root/ralphweb/public/chess/icc/lastflag.txt");
my $data = <DAT>;
close(DAT);

my ($handle, $flag) = split(/;/, $data);
$flag = lc($flag);


open(IN, "lastgame0.html");
$string = <IN>;
close IN;

$string =~ s/\<style\>.*\<\/style\>/\<link rel\=\"stylesheet\" href\=\"\/css\/Envision_pgn.css\" type=\"text\/css\" \/\>/smg;
$string =~ s/Internet Chess Club/<br>Internet Chess Club/;
$string =~ s/PerlHackr/<a href\=\"http:\/\/www\.chessclub\.com\/finger\/PerlHackr\" target\=\"_blank\">PerlHackr<\/a>\&nbsp\;\<img src=\"\/flagicons\/ch.png\" title=\"ch\">/;
$string =~ s/$handle/\&nbsp;<a href\=\"http:\/\/www\.chessclub\.com\/finger\/$handle\" target\=\"_blank\">$handle<\/a>\&nbsp\;\<img src=\"\/flagicons\/$flag.png\" title=\"$flag\">/;
$string =~ s/var flipped \= false\;/var flipped \= true\;/ if $flipped eq 'true';
$string =~ s/Round \-//;

open(OUT,">lastgame0.html");
print OUT ($string);
close OUT;

if ($flipped eq 'true') {
	system("cp /root/www/chartbot/heatmapblack.gif /root/ralphweb/public/chess/icc/heatmap.gif");
} else {
	system("cp /root/www/chartbot/heatmapwhite.gif /root/ralphweb/public/chess/icc/heatmap.gif");
}

