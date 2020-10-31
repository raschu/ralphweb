use strict;
use warnings;
use Data::Dumper;

chdir('/root/www/ralphweb/public/lichess/userstyles/boards/');
	
	open(DAT, "nrs.txt");
	my @r = <DAT>;
	close(DAT);

	my %nrs;

	for my $z (@r) {
		chomp $z;
	
		my ($nr, $usnr) = split(/\:/, $z);
		$nrs{$nr} = $usnr;
	}
	
	my $htbl = "";
	my @boards;
	for my $png (<tn*.png>) {
		my $nr = $png;
		$nr =~ s/tn_//;
		$nr =~ s/\.png//;
		push(@boards, $nr);
	}
    
    	
	my $cnttbls = int(@boards / 4) + 1;
    
    print "cnt: $cnttbls\n";
    

	for (1..$cnttbls) {
		
		#last if $_ == $cnttbls; #wenn Anzahl Boards / 4 aufgehen, sonst auskommentieren...
		
		my $b1 = shift @boards;
		my $b2 = shift @boards;
		my $b3 = shift @boards;
		my $b4 = shift @boards;
		
		$htbl .= "<table border=\"0\" cellpadding=\"0\" cellspacing=\"1\">\n";
		$htbl .= "	<tbody>\n";
		$htbl .= "		<tr>\n";
		$htbl .= "			<td><a href=\"/lichess/userstyles/boards/$b1.png\"><img src=\"/lichess/userstyles/boards/tn_$b1.png\"/></a></td>\n";
	
		if (not defined $b2) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"/lichess/userstyles/boards/$b2.png\"><img src=\"/lichess/userstyles/boards/tn_$b2.png\"/></a></td>\n";
		}
		if (not defined $b3) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"/lichess/userstyles/boards/$b3.png\"><img src=\"/lichess/userstyles/boards/tn_$b3.png\"/></a></td>\n";
		}
		if (not defined $b4) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"/lichess/userstyles/boards/$b4.png\"><img src=\"/lichess/userstyles/boards/tn_$b4.png\"/></a></td>\n";
		}
		$htbl .= "		</tr>\n";
		$htbl .= "		<tr>\n";
		$htbl .= "			<td><a href=\"/downloads/jinstuff/boards/$b1.zip\">Jin</a></td>\n";
		if (not defined $b2) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"/downloads/jinstuff/boards/$b2.zip\">Jin</a></td>\n";
		}
		if (not defined $b3) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"/downloads/jinstuff/boards/$b3.zip\">Jin</a></td>\n";
		}
		if (not defined $b4) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"/downloads/jinstuff/boards/$b4.zip\">Jin</a></td>\n";
		}	
		$htbl .= "		</tr>\n";
		$htbl .= "		<tr>\n";
		$htbl .= "			<td><a href=\"https://userstyles.org/styles/$nrs{$b1}/lichess-board-ralphschuler-ch-$b1\">Lichess</a></td>\n";
		if (not defined $b2) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"https://userstyles.org/styles/$nrs{$b2}/lichess-board-ralphschuler-ch-$b2\">Lichess</a></td>\n";
		}
		if (not defined $b3) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"https://userstyles.org/styles/$nrs{$b3}/lichess-board-ralphschuler-ch-$b3\">Lichess</a></td>\n";
		}
		if (not defined $b4) {
			$htbl .= "			<td>&nbsp;</td>\n";
		} else {
			$htbl .= "			<td><a href=\"https://userstyles.org/styles/$nrs{$b4}/lichess-board-ralphschuler-ch-$b4\">Lichess</a></td>\n";
		}		
		$htbl .= "		</tr>\n";
		$htbl .= "	</tbody>\n";
		$htbl .= "</table>\n";
		
}

print $htbl;	
