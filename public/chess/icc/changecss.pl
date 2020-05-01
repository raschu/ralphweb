#!/usr/bin/perl
#Hier wird der CSS String ersetzt, damit die Files in ralphschuler.ch Design passen
use strict;
use warnings;

local $/ = undef;

my $cnt = 0;

for my $file (<ICC_*.html>) {
	$cnt++;
	print "count($cnt): $file\n";
	my $string;
	
	
	open(IN, "$file");
	$string = <IN>;
	close IN;

	$string =~ s/\<style\>.*\<\/style\>/\<link rel\=\"stylesheet\" href\=\"\/css\/Envision_pgn.css\" type=\"text\/css\" \/\>/smg;
	
	open(OUT,">$file");
	print OUT ($string);
	close OUT;
		
}

