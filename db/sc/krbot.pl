#use Mojo::DOM;
use Data::Dumper;
use HTTP::Request::Common;
use LWP::UserAgent;
use Compress::Zlib;
use Modern::Perl;
use Encode;
use File::Copy;
use XML::XPath;
use XML::XPath::XMLParser;
no warnings;

my $VER = "16.01.2015.12.04";
print "starting krbot $VER\n";

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = '0';

my $all = $ARGV[0];

my $singlenick = $ARGV[1];
#my $workdir = '/Users/ralph/Desktop/sc';
my $workdir = '/root/ralphweb/db/sc';
my @abet = qw(a b c d e f g h i j);
my $now = time();
my $nickstring = "";
my $reccnt = 0;
my $ua = LWP::UserAgent->new( );

if ($all == 1) {
	$reccnt = qx(sqlite3 $workdir/sc16.sqlite "select count(nick) from scranking");
	chomp($reccnt);
	$nickstring = qx(sqlite3 $workdir/sc16.sqlite "select nick from scranking order by nick");
	print "parsing all ($reccnt Records)!\n";
} elsif ($all == 0) {
	if ($singlenick gt "") { #nur einzelnen Nick updaten
		$singlenick = encode("iso-8859-1", $singlenick);
		my $sqlstring = parsedata($singlenick, "single");
		open(DAT, "|sqlite3 $workdir/sc16.sqlite");
		print DAT "$sqlstring\n";
		print DAT "vacuum;\n";
		close(DAT);
		exit;
	} else {
		$reccnt = qx(sqlite3 $workdir/sc16.sqlite "select count(nick) from scranking where updatetime > 1430179200 "); # 1430179200 28.04.2015
		chomp($reccnt);
		$nickstring = qx(sqlite3 $workdir/sc16.sqlite "select nick from scranking where updatetime > 1430179200  order by nick"); # 1430179200 28.04.2015
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
	
	#print "parsing nick $nick\n";
	
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
							 gameId => '3447',
							 nick => $nick
	                       ]
	);

	my $content = $res->decoded_content;

	$content = modifycontent($content);
	
	my $xp = XML::XPath->new($content);

	#print $content;
			
	#my $dom = Mojo::DOM->new->parse(scalar $content);
	
	#Weltcup#########################################################################
	#benutze mod.pl um aus Ziffern Buchstaben umzurechnen
	
	my $beaqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ecdbagc');
	my $beaqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ecdbagd');
	my $beaqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ecdbage');
	my $bear       = $xp->find('/PlayerProfile/playerRankings/Ranking/ecdbagf');
	
    my $groqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ebjbahe');
	my $groqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ebjbahf');
	my $groqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ebjbahg');
	my $gror       = $xp->find('/PlayerProfile/playerRankings/Ranking/ebjbahh');
	
	my $borqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/eccbbbg');
	my $borqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/eccbbbh');
	my $borqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/eccbbbi');
	my $borr       = $xp->find('/PlayerProfile/playerRankings/Ranking/eccbbbj');

	my $wenqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ebibbcc');
	my $wenqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ebibbcd');
	my $wenqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ebibbce');
	my $wenr       = $xp->find('/PlayerProfile/playerRankings/Ranking/ebibbcf');
	
	my $kitqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ecabbci');
	my $kitqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ecabbcj');
	my $kitqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ecabbda');
	my $kitr       = $xp->find('/PlayerProfile/playerRankings/Ranking/ecabbdb');
	
	my $garqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ecbbbde');
	my $garqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ecbbbdf');
	my $garqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ecbbbdg');
	my $garr       = $xp->find('/PlayerProfile/playerRankings/Ranking/ecbbbdh');
	
	#Bonuscup########################################################################
	
	my $vadqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ecgbbha');
	my $vadqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ecgbbhb');
	my $vadqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ecgbbhc');
	my $vadr       = $xp->find('/PlayerProfile/playerRankings/Ranking/ecgbbhd');
	
	my $socqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ecfbbhg');
	my $socqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ecfbbhh');
	my $socqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ecfbbhi');
	my $socr       = $xp->find('/PlayerProfile/playerRankings/Ranking/ecfbbhj');
	
	my $schqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/ecebbic');
	my $schqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/ecebbid');
	my $schqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/ecebbie');
	my $schr       = $xp->find('/PlayerProfile/playerRankings/Ranking/ecebbif');
	
	my $stmqsonne  = $xp->find('/PlayerProfile/playerRankings/Ranking/eeabbea');
	my $stmqschnee = $xp->find('/PlayerProfile/playerRankings/Ranking/eeabbeb');
	my $stmqeis    = $xp->find('/PlayerProfile/playerRankings/Ranking/eeabbec');
	my $stmr       = $xp->find('/PlayerProfile/playerRankings/Ranking/eeabbed');
	
    $beaqsonne = converttime($beaqsonne);	
	$beaqschnee = converttime($beaqschnee);
	$beaqeis = converttime($beaqeis);
	$bear = converttime($bear);
		
    $vadqsonne = converttime($vadqsonne);	
	$vadqschnee = converttime($vadqschnee);
	$vadqeis = converttime($vadqeis);
	$vadr = converttime($vadr);
	
    $socqsonne = converttime($socqsonne);	
	$socqschnee = converttime($socqschnee);
	$socqeis = converttime($socqeis);
	$socr = converttime($socr);
	
    $schqsonne = converttime($schqsonne);	
	$schqschnee = converttime($schqschnee);
	$schqeis = converttime($schqeis);
	$schr = converttime($schr);
	
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
	
    $stmqsonne = converttime($stmqsonne);	
	$stmqschnee = converttime($stmqschnee);
	$stmqeis = converttime($stmqeis);
	$stmr = converttime($stmr);
	
	my $beaq = findfastest($beaqsonne, $beaqschnee, $beaqeis);
	my $vadq = findfastest($vadqsonne, $vadqschnee, $vadqeis);
	my $socq = findfastest($socqsonne, $socqschnee, $socqeis);
	my $schq = findfastest($schqsonne, $schqschnee, $schqeis);
	my $groq = findfastest($groqsonne, $groqschnee, $groqeis);
	my $borq = findfastest($borqsonne, $borqschnee, $borqeis);
	my $wenq = findfastest($wenqsonne, $wenqschnee, $wenqeis);
	my $kitq = findfastest($kitqsonne, $kitqschnee, $kitqeis);
	my $garq = findfastest($garqsonne, $garqschnee, $garqeis);
	my $stmq = findfastest($stmqsonne, $stmqschnee, $stmqeis);
	my $sum = $beaq+$bear+$vadq+$vadr+$socq+$socr+$schq+$schr+$groq+$gror+$borq+$borr+$wenq+$wenr+$kitq+$kitr+$garq+$garr+$stmq+$stmr;
	
	return unless $sum > 0; #bringt nichts diesen Record upzudaten...
	
	#print "$beaq\t" if $beaq > 0;
	#print "$bear\t" if $beaq > 0;
	#print "$groq\t" if $groq > 0;
	#print "$gror\t" if $gror > 0;
	#print "$borq\t" if $borq > 0;
	#print "$borr\t" if $borr > 0;
	#print "$wenq\t" if $wenq > 0;
	#print "$wenr\t" if $wenr > 0;
	#print "$kitq\t" if $kitq > 0;
	#print "$kitr\t" if $kitr > 0;
	#print "$garq\t" if $garq > 0;
	#print "$garr\t" if $garr > 0;
	#print "$nick\n" if $sum > 0;
	
	$nick = decode("UTF-8", $nick);
	my $nickup = uc($nick);

	my $sql = "UPDATE scranking SET ";
	$sql .= "beaq=$beaq," if $beaq > 0;
	$sql .= "bear=$bear," if $bear > 0;
	$sql .= "vadq=$vadq," if $vadq > 0;
	$sql .= "vadr=$vadr," if $vadr > 0;
	$sql .= "socq=$socq," if $socq > 0;
	$sql .= "socr=$socr," if $socr > 0;
	$sql .= "schq=$schq," if $schq > 0;
	$sql .= "schr=$schr," if $schr > 0;
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
	$sql .= "stmq=$stmq," if $stmq > 0;
	$sql .= "stmr=$stmr," if $stmr > 0;
	$sql .= "updatetime=$now WHERE nick='$nick' OR UPPER(nick)='$nickup';";
	
	if ($mode eq "all") {
		#say $sql;
		open(DAT, ">>$workdir/sc16data.$now.txt");
		print DAT "$sql\n";
		close(DAT);
	} elsif ($mode eq "single") {
		say "Single Update: $sql";
		return $sql;
	}
}

sub converttime {
	my $time = shift;
	#print $time . "\n";
	#my ($d, $time) = split(/\>/, $string);
	#my $time =~ s/<\/p1//;
	my $sec = substr($time, 0, -3);
	my $milsec = substr($time, -3);
	my $min = int($sec / 60);
	my $rest = $sec - $min * 60;
	$rest = sprintf ("%02d", $rest);
	return "$min" . "$rest" . "$milsec";
}

sub updatedb {
	exec("/usr/bin/perl","/root/ralphweb/db/sc/krbot_update.pl","$now");
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
			my $bst = modc($class);
			$r =~ s/<p1>/<$bst>/;
			$r =~ s/<\/p1>/<\/$bst>/;
		}

		$new .= $r . "\n";
	}
	return $new;
}

sub modc {
	my $z = shift;
	my $new;
	
	my @zi = split(//, $z);
	
	foreach my $e (@zi) {
		$new .= $abet[$e];
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
