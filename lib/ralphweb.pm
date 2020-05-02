package ralphweb;

use rss;
use sc::sc;
use icc;
use guestbook;
use hoefli;
use icc_interfaces;
use chesscss;
use pgn2lichess;
use Dancer ':syntax';
use Dancer::Plugin::DirectoryView;
use HTML::ParseBrowser;

our $VERSION = '0.1';

our $ua;

my $cntd = 0;
my $cnth = 0;


open (DAT, "/root/ralphweb/db/stoicquotes.txt");
my @quotes = <DAT>;
close (DAT);

get '/' => sub {
	my $uastring = request->user_agent;
	my $ua = HTML::ParseBrowser->new($uastring);
	my $useragent = $ua->name . " " . $ua->v;
	my $sessid = session 'id';
    my $rand = int(rand(@quotes));
    my $quote = $quotes[$rand];
	my @fortune = qx(echo '$quote' | /usr/bin/cowsay);
	my $fortunestring;
	foreach (@fortune) {
		$fortunestring .= $_ . "<br>";
	}
	$fortunestring =~ s/ /&nbsp/g;
	$fortunestring = substr($fortunestring, 0, -4);
	my $sesstatd = calcSessionStats('d');
	my $sesstath = calcSessionStats('h');
	
	
	my $ut = qx(uptime);
	chdir('/root/ralphweb/sessions');

	my $now = time();
	template 'homepage', {
		uaname => $useragent, 
		ut => $ut, 
		cntd => $cntd, 
		cnth => $cnth, 
		sessid => $sessid, 
		fortunestring => $fortunestring, 
		sstatstringd => $sesstatd,
		sstatstringh => $sesstath
	};
};
get '/about' => sub {
	template 'about';
};

get '/gcc' => sub {
	template 'gcc';
};

get '/sdg' => sub {
	redirect '/chess/sdg2.0/sdg_2016.html';
};

#get '/512KB' => sub {

#	open(my $f, '<', '/root/ralphweb/logs/uastrings.txt');
#	my $string = do { local($/); <$f> };
#	close($f);

	
#	template '512', {log => $string}, { layout => '512log' };
#};
get '/utube' => sub {
	template 'utube';
};
get '/trophyroom' => sub {
	template 'icc_trophyroom';
};
get '/icc_social_network' => sub {
	template 'icc_social';
};
get '/lastgame' => sub {
	open(DAT, "/root/ralphweb/public/chess/icc/lastgame.pgn");
	my @pgn = <DAT>;
	close(DAT);
	my $pgn;
	$pgn .= $_ foreach(@pgn);
	template 'icc_lastgame', {pgn => $pgn};
};
get '/download' => sub {
	chdir('/root/ralphweb/public/lichess/userstyles/boards/');
	
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

	for (1..$cnttbls) {
		
		last if $_ == $cnttbls; #wenn Anzahl Boards / 4 aufgehen, sonst auskommentieren...
		
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
	
	template 'download', {htbl => $htbl};
};
get '/download/:dlfile' => sub {
	my $dlfile = params->{dlfile};
	template "download-$dlfile";
};
get '/links' => sub {
	template 'links';
};

sub calcSessionStats {
	my $type = shift;
	
	chdir('/root/ralphweb/sessions');
	my $cnt00 = 0;
	my $cnt01 = 0;
	my $cnt011 = 0;
	my $cnt012 = 0;
	my $cnt013 = 0;
	my $cnt02 = 0;
	my $cnt03 = 0;
	my $cnt04 = 0;
	my $cnt05 = 0;
	my $cnt06 = 0;
	my $cnt07 = 0;
	my $cnt08 = 0;
	my $cnt09 = 0;
	my $cnt10 = 0;
	my $cnt11 = 0;
	my $cnt12 = 0;
	my $cnt13 = 0;
	my $cnt14 = 0;
	my $cnt15 = 0;
	my $cnt16 = 0;
	my $cnt17 = 0;
	my $cnt18 = 0;
	my $cnt19 = 0;
	my $cnt20 = 0;
	my $cnt21 = 0;
	my $cnt22 = 0;
	my $cnt23 = 0;

	my $now = time();
	foreach (<*.yml>) {
	    my $file = $_;
	    my $ts = (stat($file))[9];
	    $cnt23++ if ($now - $ts < 86400);
	    $cnt22++ if ($now - $ts < 82800);
		$cnt21++ if ($now - $ts < 79200);
		$cnt20++ if ($now - $ts < 75600);
		$cnt19++ if ($now - $ts < 72000);
		$cnt18++ if ($now - $ts < 68400);
		$cnt17++ if ($now - $ts < 61200);
		$cnt16++ if ($now - $ts < 57600);
		$cnt15++ if ($now - $ts < 54000);
		$cnt14++ if ($now - $ts < 50400);
		$cnt13++ if ($now - $ts < 46800);
		$cnt12++ if ($now - $ts < 43200);
		$cnt11++ if ($now - $ts < 39600);
		$cnt10++ if ($now - $ts < 36000);
		$cnt09++ if ($now - $ts < 32400);
		$cnt08++ if ($now - $ts < 28800);
		$cnt07++ if ($now - $ts < 25200);
		$cnt06++ if ($now - $ts < 21600);
		$cnt05++ if ($now - $ts < 18000);
		$cnt04++ if ($now - $ts < 14400);
		$cnt03++ if ($now - $ts < 10800);
		$cnt02++ if ($now - $ts < 7200);
		$cnt01++ if ($now - $ts < 3600);
		$cnt011++ if ($now - $ts < 2700);
		$cnt012++ if ($now - $ts < 1800);
		$cnt013++ if ($now - $ts < 900);
		$cnt00++ if ($now - $ts < 0);
	}
	
	$cntd = $cnt23;
	$cnth = $cnt01;

	my @diff;

	$diff[0] = $cnt01 - $cnt00;
	$diff[1] = $cnt02 - $cnt01;
	$diff[2] = $cnt03 - $cnt02;
	$diff[3] = $cnt04 - $cnt03;
	$diff[4] = $cnt05 - $cnt04;
	$diff[5] = $cnt06 - $cnt05;
	$diff[6] = $cnt07 - $cnt06;
	$diff[7] = $cnt08 - $cnt07;
	$diff[8] = $cnt09 - $cnt08;
	$diff[9] = $cnt10 - $cnt09;
	$diff[10] = $cnt11 - $cnt10;
	$diff[11] = $cnt12 - $cnt11;
	$diff[12] = $cnt13 - $cnt12;
	$diff[13] = $cnt14 - $cnt13;
	$diff[14] = $cnt15 - $cnt14;
	$diff[15] = $cnt16 - $cnt15;
	$diff[16] = $cnt17 - $cnt16;
	$diff[17] = $cnt18 - $cnt17;
	$diff[18] = $cnt19 - $cnt18;
	$diff[19] = $cnt20 - $cnt19;
	$diff[20] = $cnt21 - $cnt20;
	$diff[21] = $cnt22 - $cnt21;
	$diff[22] = $cnt23 - $cnt22;
	
	my @diff2;

	$diff2[0] = $cnt013 - $cnt00;
	$diff2[1] = $cnt012 - $cnt013;
	$diff2[2] = $cnt011 - $cnt012;
	$diff2[3] = $cnt01 - $cnt011;
	
	my $sstringd = "data : [";
	
	for (reverse @diff) {
		$sstringd .= $_ . ",";
	}
	$sstringd .= "]";
	
	my $sstringh = "data : [$diff2[3], $diff2[2], $diff2[1],$diff2[0] ]";
	
	return $sstringd if $type eq 'd';
	return $sstringh if $type eq 'h';

}

true;
