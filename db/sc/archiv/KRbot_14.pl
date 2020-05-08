use Mojo::DOM;
use LWP::UserAgent;
use Modern::Perl;
use Encode;
use File::Copy;
#use URI::Escape;
no warnings;

my $VER = "14.01";
print "Starting KRbot $VER\n";

my $all = $ARGV[0];
my $singlenick = $ARGV[1];
my $workdir = '/root/www/ralphweb/db/sc';
my $now = time();
my $nickstring = "";
my $reccnt = 0;
my $ua = LWP::UserAgent->new( );

if ($all == 1) {
	$reccnt = qx(sqlite3 $workdir/sc14.sqlite "select count(nick) from scranking");
	chomp($reccnt);
	$nickstring = qx(sqlite3 $workdir/sc14.sqlite "select nick from scranking order by nick");
	print "parsing all ($reccnt Records)!\n";
} elsif ($all == 0) {
	if ($singlenick gt "") { #nur einzelnen Nick updaten
		$singlenick = encode("iso-8859-1", $singlenick);
		my $sqlstring = parsedata($singlenick, "single");
		open(DAT, "|sqlite3 $workdir/sc14.sqlite");
		print DAT "$sqlstring\n";
		print DAT "vacuum;\n";
		close(DAT);
		exit;
	} else {
		$reccnt = qx(sqlite3 $workdir/sc14.sqlite "select count(nick) from scranking where updatetime > 1365033600 "); # 1433515600 04.04.2013
		chomp($reccnt);
		$nickstring = qx(sqlite3 $workdir/sc14.sqlite "select nick from scranking where updatetime > 1365033600  order by nick"); # 1433515600 04.04.2013
		print "parsing newest ($reccnt Records)!\n";
	}
} else {
	die "wrong parameter";
}

my @nicks = split(/\n/, $nickstring);
unlink("$workdir/sc14data.txt");

foreach (@nicks) {
	#print "$_\n";
	parsedata($_, "all");
}

updatedb();

sub parsedata {
	my $nick = shift;
	$nick = encode("UTF-8", $nick);
	my $mode = shift;

	#my $url = sprintf('http://www.ski-challenge.com/gm-proxy.php?url=%s', uri_escape(sprintf('https://magic-service.greentube.com/service/v161/Greentube.asmx/GetPlayerProfileByNick?gameId=950&nick=%s', uri_escape($nick)))); 
	#my $url = sprintf('http://www.ski-challenge.com/gm-proxy.php?parameters=%s&service=1', uri_escape('GetPlayerProfileByNick?gameId=950&nick='.lc($nick))); 
	my $url = "http://sc-2014-web.greentube.com/gm-proxy.php?service=1&function=GetPlayerProfileByNick&gameId=950&nick=$nick";
	my $r =  HTTP::Request->new( GET => $url);

	#$r->header('Accept' => '*/*');
	#$r->header('Accept-Encoding' => 'gzip, deflate');
	#$r->header('Accept-Language' => 'de-DE,de,q=0.5');
	#$r->header('Host' => 'www.ski-challenge.com');
	$r->header('User-Agent' => 'KantonsrankingBot ralphschuler.ch');
	$r->header('X-Requested-With' => 'XMLHttpRequest');

	my $ua = LWP::UserAgent->new();
	my $res = $ua->request($r);
	my $content = $res->content;
	$content = modifycontent($content);
	my $dom = Mojo::DOM->new->parse(scalar $content);
	
	my $beaqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.356655');
	my $beaqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.356656');
	my $beaqeis = $dom->find('PlayerProfile playerRankings Ranking p1.356657');
	my $bear = $dom->find('PlayerProfile playerRankings Ranking p1.356658');
	
	my $groqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.357659');
	my $groqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.357660');
	my $groqeis = $dom->find('PlayerProfile playerRankings Ranking p1.357661');
	my $gror = $dom->find('PlayerProfile playerRankings Ranking p1.357662');
	
	my $borqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.358663');
	my $borqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.358664');
	my $borqeis = $dom->find('PlayerProfile playerRankings Ranking p1.358665');
	my $borr = $dom->find('PlayerProfile playerRankings Ranking p1.358666');
	
	my $wenqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.359667');
	my $wenqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.359668');
	my $wenqeis = $dom->find('PlayerProfile playerRankings Ranking p1.359669');
	my $wenr = $dom->find('PlayerProfile playerRankings Ranking p1.359670');
	
	my $kitqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.360671');
	my $kitqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.360672');
	my $kitqeis = $dom->find('PlayerProfile playerRankings Ranking p1.360673');
	my $kitr = $dom->find('PlayerProfile playerRankings Ranking p1.360674');
	
	my $garqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.361675');
	my $garqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.361676');
	my $garqeis = $dom->find('PlayerProfile playerRankings Ranking p1.361677');
	my $garr = $dom->find('PlayerProfile playerRankings Ranking p1.361678');
	
	my $socqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.362679');
	my $socqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.362680');
	my $socqeis = $dom->find('PlayerProfile playerRankings Ranking p1.362681');
	my $socr = $dom->find('PlayerProfile playerRankings Ranking p1.362682');
	
	$beaqsonne = converttime($beaqsonne);
	$beaqschnee = converttime($beaqschnee);
	$beaqeis = converttime($beaqeis);
	$bear = converttime($bear);
	
	$groqsonne = converttime($groqsonne);
	$groqschnee = converttime($groqschnee);
	$groqeis = converttime($groqeis);
	$gror = converttime($gror);
	
	$borqsonne = converttime($borqsonne);
	$borqschnee = converttime($borqschnee);
	$borqeis = converttime($borqeis);
	$borr = converttime($borr);
	
	$wenqsonne = converttime($wenqsonne);
	$wenqschnee = converttime($wenqschnee);
	$wenqeis = converttime($wenqeis);
	$wenr = converttime($wenr);
	
	$kitqsonne = converttime($kitqsonne);
	$kitqschnee = converttime($kitqschnee);
	$kitqeis = converttime($kitqeis);
	$kitr = converttime($kitr);
	
	$garqsonne = converttime($garqsonne);
	$garqschnee = converttime($garqschnee);
	$garqeis = converttime($garqeis);
	$garr = converttime($garr);
	
	$socqsonne = converttime($socqsonne);
	$socqschnee = converttime($socqschnee);
	$socqeis = converttime($socqeis);
	$socr = converttime($socr);
	
	my $beaq = findfastest($beaqsonne, $beaqschnee, $beaqeis);
	my $groq = findfastest($groqsonne, $groqschnee, $groqeis);
	my $borq = findfastest($borqsonne, $borqschnee, $borqeis);
	my $wenq = findfastest($wenqsonne, $wenqschnee, $wenqeis);
	my $kitq = findfastest($kitqsonne, $kitqschnee, $kitqeis);
	my $garq = findfastest($garqsonne, $garqschnee, $garqeis);
	my $socq = findfastest($socqsonne, $socqschnee, $socqeis);
	
	my $sum = $beaq + $groq + $borq + $wenq + $kitq + $garq + $socq;
	
	return unless $sum > 0; #bringt nichts diesen Record upzudaten...
	
	print "$beaq\t" if $beaq > 0;
	print "$groq\t" if $groq > 0;
	print "$borq\t" if $borq > 0;
	print "$wenq\t" if $wenq > 0;
	print "$kitq\t" if $kitq > 0;
	print "$garq\t" if $garq > 0;
	print "$socq\t" if $socq > 0;
	print "$nick\n" if $sum > 0;
	
	$nick = decode("UTF-8", $nick);
	my $nickup = uc($nick);

	my $sql = "UPDATE scranking SET ";
	$sql .= "beaq=$beaq," if $beaq > 0;
	#$sql .= "bear=$bear," if $bear > 0;
	$sql .= "groq=$groq," if $groq > 0;
	#$sql .= "gror=$gror," if $gror > 0;
	$sql .= "borq=$borq," if $borq > 0;
	#$sql .= "borr=$borr," if $borr > 0;
	$sql .= "wenq=$wenq," if $wenq > 0;
	#$sql .= "wenr=$wenr," if $wenr > 0;
	$sql .= "kitq=$kitq," if $kitq > 0;
	#$sql .= "kitr=$kitr," if $kitr > 0;
	$sql .= "garq=$garq," if $garq > 0;
	#$sql .= "garr=$garr," if $garr > 0;
	$sql .= "socq=$socq," if $socq > 0;
	#$sql .= "socr=$socr," if $socr > 0;
	$sql .= "updatetime=$now WHERE nick='$nick' OR UPPER(nick)='$nickup';";
	
	if ($mode eq "all") {
		#say $sql;
		open(DAT, ">>$workdir/sc14data.txt");
		print DAT "$sql\n";
		close(DAT);
	} elsif ($mode eq "single") {
		say "Single Update: $sql";
		return $sql;
	}
}

sub converttime {
	my $string = shift;
	my ($d, $time) = split(/\>/, $string);
	#print "timehere: $time\n";
	$time =~ s/<\/p1//;
	my $sec = substr($time, 0, -3);
	my $milsec = substr($time, -3);
	my $min = int($sec / 60);
	my $rest = $sec - $min * 60;
	$rest = sprintf ("%02d", $rest);
	return "$min" . "$rest" . "$milsec";
}

sub updatedb {
	#print "Updating db in $workdir\n";
	#open(LOG, "$workdir/sc14data.txt") or die "kann $workdir/sc14data.txt nicht oeffnen";
	#my @sqls = <LOG>;
	#close(LOG);
	
	#print "Making Backup of $workdir/sc14.sqlite\n";
	#copy("$workdir/sc14.sqlite", "$workdir/TEMPbackupDB/sc14.$hour") or die "kann nicht von $workdir/sc14.sqlite nach $workdir/TEMPbackupDB/sc14.$hour kopieren ($!)";
	
	#print "Piping $workdir/sc14.sqlite\n";
	#open(DAT, "|sqlite3 $workdir/sc14.sqlite") or die "kann DB $workdir/sc14.sqlite nicht oeffnen ERROR: -> $! <-";
	#foreach my $sql (@sqls) {
		#print "PIPE DEBUG: $sql\n";
	#	print DAT "$sql\n";
	#}
	#print "Vacuumize $workdir/sc14.sqlite\n";
	#print DAT "vacuum;\n";
	#close(DAT);
	exec("/usr/bin/perl","/root/www/ralphweb/db/sc/update.pl");
}

sub modifycontent {
	my $content = shift;
	my $new;
	my @z = split(/\r\n/, $content);

	my $class1 = "";
	my $class2 = "";
	my $class = "";
	foreach my $r (@z) {
		#chomp($r);
		if ($r =~ m/levelId/) {
			$class1 = $r;
			$class1 =~ s/<levelId>//;
			$class1 =~ s/<\/levelId>//;
			$class1 =~ s/ +//;
		}
		
		if ($r =~ m/competitionId/) {
			$class2 = $r;
			$class2 =~ s/<competitionId>//;
			$class2 =~ s/<\/competitionId>//;
			$class2 =~ s/ +//;
		}

		if ($r =~ m/p1/) {
			$class = $class1 . $class2;
			#print "class: $class\n";
			my $p1= $r;
			$r =~ s/<p1>/<p1 class=$class>/;
		}

		$new .= $r . "\n";
	}
	return $new;
}

sub findfastest {
	my $sonne = shift;
	my $schnee = shift;
	my $eis = shift;
	
	$sonne = '99999999' if $sonne eq '000';
	$schnee = '99999999' if $schnee eq '000';
	$eis = '99999999' if $eis eq '000';
	
	return $sonne if $sonne < $schnee and $sonne < $eis;
	return $schnee if $schnee < $sonne and $schnee < $eis;
	return $eis if $eis < $sonne and $eis < $schnee;
}
