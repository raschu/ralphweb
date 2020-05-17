use strict;
use warnings;

print "bitte pgn angeben welches konvertiert werden soll ohne File-ext (Bsp: 00082): ";
my $i = <STDIN>;

#Hinweis noch nicht getetstet mit einzelnem File. Muss das nächste Mal gemacht werden (Stand 17.05.2020)

#for (<*.html>) {
#    unlink($_);
#}
#
#for my $i (1..92) {
#    $i = sprintf("%05d", $i);
#    system("./pgn2web -c yes -p merida -s individual $i.pgn $i.html");
#    system("perl changecss_temp.pl $i");
#}

system("./pgn2web -c yes -p merida -s individual $i.pgn $i.html");
system("perl changecss.pl $i");