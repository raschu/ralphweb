use Mojo::DOM;
use HTTP::Request::Common;
use LWP::UserAgent;
use Compress::Zlib;
use Modern::Perl;
use Encode;
use File::Copy;
no warnings;

my $VER = "15.02";
print "Starting KRbot $VER\n";

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = '0';

my $all = $ARGV[0];

my $singlenick = $ARGV[1];
#my $workdir = '/Users/ralph/Desktop/sc';
my $workdir = '/root/www/ralphweb/db/sc';
my $now = time();
my $nickstring = "";
my $reccnt = 0;
my $ua = LWP::UserAgent->new( );

if ($all == 1) {
	$reccnt = qx(sqlite3 $workdir/sc15.sqlite "select count(nick) from scranking");
	chomp($reccnt);
	$nickstring = qx(sqlite3 $workdir/sc15.sqlite "select nick from scranking order by nick");
	print "parsing all ($reccnt Records)!\n";
} elsif ($all == 0) {
	if ($singlenick gt "") { #nur einzelnen Nick updaten
		$singlenick = encode("iso-8859-1", $singlenick);
		my $sqlstring = parsedata($singlenick, "single");
		open(DAT, "|sqlite3 $workdir/sc15.sqlite");
		print DAT "$sqlstring\n";
		print DAT "vacuum;\n";
		close(DAT);
		exit;
	} else {
		$reccnt = qx(sqlite3 $workdir/sc15.sqlite "select count(nick) from scranking where updatetime > 1396569600 "); # 1396569600 04.04.2014
		chomp($reccnt);
		$nickstring = qx(sqlite3 $workdir/sc15.sqlite "select nick from scranking where updatetime > 1396569600  order by nick"); # 1396569600 04.04.2014
		print "parsing newest ($reccnt Records)!\n";
	}
} else {
	die "wrong parameter";
}

my @nicks = split(/\n/, $nickstring);
parsedata($_, "all") foreach (@nicks);
updatedb();

#--------------------------------------------------------------------------------------------------------
sub parsedata {
	my $nick = shift;
	$nick = encode("UTF-8", $nick);
	my $mode = shift;
	my $ua = LWP::UserAgent->new;
	my $res = $ua->request(
	POST 'https://www.ski-challenge.com/gm-proxy.php',
	       'Accept' => '*/*',
		   'Accept-Encoding' => 'gzip, deflate',
		   'Accept-Language' => 'de-DE,de;q=0.8,en-US;q=0.6,en;q=0.4',
		   'Host' => 'www.ski-challenge.com',
		   'User-Agent' => 'krbot.pl@ralphschuler.ch',
		   'X-Requested-With' => 'XMLHttpRequest',
	       Content      => [ service => '1',
		   					 function => 'GetPlayerProfileByNick',
							 gameId => '1737',
							 nick => $nick
	                       ]
	);

	my $content = $res->decoded_content;
	#die $content;
	
	$content = modifycontent($content);
	my $dom = Mojo::DOM->new->parse(scalar $content);
	
	my $beaqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.394880');
	my $beaqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.394881');
	my $beaqeis = $dom->find('PlayerProfile playerRankings Ranking p1.394882');
	my $bear = $dom->find('PlayerProfile playerRankings Ranking p1.394883');
	
	my $groqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.396895');
	my $groqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.396896');
	my $groqeis = $dom->find('PlayerProfile playerRankings Ranking p1.396897');
	my $gror = $dom->find('PlayerProfile playerRankings Ranking p1.396898');
	
	my $borqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.398910');
	my $borqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.398911');
	my $borqeis = $dom->find('PlayerProfile playerRankings Ranking p1.398912');
	my $borr = $dom->find('PlayerProfile playerRankings Ranking p1.398913');

	my $wenqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.399920');
	my $wenqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.399921');
	my $wenqeis = $dom->find('PlayerProfile playerRankings Ranking p1.399922');
	my $wenr = $dom->find('PlayerProfile playerRankings Ranking p1.399923');
	
	my $kitqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.400930');
	my $kitqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.400931');
	my $kitqeis = $dom->find('PlayerProfile playerRankings Ranking p1.400932');
	my $kitr = $dom->find('PlayerProfile playerRankings Ranking p1.400933');
	
	my $garqsonne = $dom->find('PlayerProfile playerRankings Ranking p1.401944');
	my $garqschnee = $dom->find('PlayerProfile playerRankings Ranking p1.401945');
	my $garqeis = $dom->find('PlayerProfile playerRankings Ranking p1.401947');
	my $garr = $dom->find('PlayerProfile playerRankings Ranking p1.401948');
	
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
	
	my $beaq = findfastest($beaqsonne, $beaqschnee, $beaqeis);
	my $groq = findfastest($groqsonne, $groqschnee, $groqeis);
	my $borq = findfastest($borqsonne, $borqschnee, $borqeis);
	my $wenq = findfastest($wenqsonne, $wenqschnee, $wenqeis);
	my $kitq = findfastest($kitqsonne, $kitqschnee, $kitqeis);
	my $garq = findfastest($garqsonne, $garqschnee, $garqeis);
	my $sum = $beaq + $bear + $groq + $gror + $borq + $borr + $wenq + $wenr + $kitq + $kitr + $garq + $garr;
	
	return unless $sum > 0; #bringt nichts diesen Record upzudaten...
	
	print "$beaq\t" if $beaq > 0;
	print "$bear\t" if $beaq > 0;
	print "$groq\t" if $groq > 0;
	print "$gror\t" if $gror > 0;
	print "$borq\t" if $borq > 0;
	print "$borr\t" if $borr > 0;
	print "$wenq\t" if $wenq > 0;
	print "$wenr\t" if $wenr > 0;
	print "$kitq\t" if $kitq > 0;
	print "$kitr\t" if $kitr > 0;
	print "$garq\t" if $garq > 0;
	print "$garr\t" if $garr > 0;
	print "$nick\n" if $sum > 0;
	
	$nick = decode("UTF-8", $nick);
	my $nickup = uc($nick);

	my $sql = "UPDATE scranking SET ";
	$sql .= "beaq=$beaq," if $beaq > 0;
	$sql .= "bear=$bear," if $bear > 0;
	$sql .= "groq=$groq," if $groq > 0;
	$sql .= "gror=$gror," if $gror > 0;
	$sql .= "borq=$borq," if $borq > 0;
	$sql .= "borr=$borr," if $borr > 0;
	$sql .= "wenq=$wenq," if $wenq > 0;
	$sql .= "wenr=$wenr," if $wenr > 0;
	$sql .= "kitq=$kitq," if $kitq > 0;
	$sql .= "kitr=$kitr," if $kitr > 0;
	$sql .= "garq=$garq," if $garq > 0;
	$sql .= "garr=$garr," if $garr > 0;
	$sql .= "updatetime=$now WHERE nick='$nick' OR UPPER(nick)='$nickup';";
	
	if ($mode eq "all") {
		#say $sql;
		open(DAT, ">>$workdir/sc15data.$now.txt");
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
	exec("/usr/bin/perl","/root/www/ralphweb/db/sc/krbot_update.pl","$now");
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
