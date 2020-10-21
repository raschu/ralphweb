use strict;
use warnings;

warn "Hinweis: pgn sollte mit vi erstellt worden sein\n";
warn "Zudem nicht vergessen den Titel anzugeben im PGN. Bspw.: (FM)\n";
warn "Anschliessend Link ergänzen in views/icc_trophyroom.tt\n";

print "bitte pgn angeben welches konvertiert werden soll ohne File-ext (Bsp: 00082): ";
chomp (my $i = <STDIN>);

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