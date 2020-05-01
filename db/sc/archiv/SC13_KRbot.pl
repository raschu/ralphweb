use Mojo::DOM;
use LWP::UserAgent;
use Modern::Perl;
use Encode;
use File::Copy;
no warnings;

my $VER = "13.01";
print "Starting KRbot $VER\n";

#VSC12
#0.04: falsche Zeiten auf Greentube Webseite. muss von anderer Seite geparst werden. (Workaround)
#0.05: einzelner Nick aktualisieren (perl KRbot.pl 0 4mon4marth)
#0.06: Greentube Workaround deaktiviert
#0.07: Fucking Umlautz....
#0.08: Nick in Upper Case...
#0.09: FindBin eingebaut
#0.10: FindBin wieder entfernt
#0.11: Debug bei sqlite pipe Update
#0.12: File::Copy eingebaut, da Probleme mit system("cp...") aufgetaucht sind
#0.14: Update extern, da zuwenig Haupstpeicher verfügbar
#VSC13
#13.01: alles auf SC14 angepasst, von LWP::Simple auf LWP::UserAgent gewechselt wegen Authentifizierung

my $all = $ARGV[0];
my $singlenick = $ARGV[1];
my $workdir = '/root/ralphweb/db/sc';
my $now = time();
my $nickstring = "";
my $reccnt = 0;
my $ua = LWP::UserAgent->new( );
authenticate();

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
		$reccnt = qx(sqlite3 $workdir/sc14.sqlite "select count(nick) from scranking where updatetime > 1433515600 "); # 1433515600 04.04.2012
		chomp($reccnt);
		$nickstring = qx(sqlite3 $workdir/sc14.sqlite "select nick from scranking where updatetime > 1433515600  order by nick"); # 1433515600 04.04.2012
		print "parsing newest ($reccnt Records)!\n";
	}
} else {
	die "wrong parameter";
}

my @nicks = split(/\n/, $nickstring);
unlink("$workdir/sc14data.txt");

foreach (@nicks) {
	print "$_\n";
	parsedata($_, "all");
}

updatedb();

sub authenticate {
	#Ab SC14, vielleicht braucht es dies später nicht mehr, Workaround
	$ua->cookie_jar( {} );
	my $URL = 'http://ch.sc13.greentube.com/webmagic/Authentication?nick=krbot&password=blabla2014';
	my $req =  HTTP::Request->new( GET => $URL);
	my $res = $ua->request( $req);
}

sub parsedata {
	my $nick = shift;
	$nick = encode("UTF-8", $nick);
	my $mode = shift;
	my $URL2 = "http://ch.sc13.greentube.com/webmagic/PlayerProfile?nick=$nick";
	my $req2 =  HTTP::Request->new( GET => $URL2);
	my $res = $ua->request( $req2);
	my $content = $res->content;
		
	return if $content =~ m/konnte nicht gefunden werden/;

	$content =~ s/averageQualificationRow row_326 light/averageQualificationRow!row_326!light/g;
	$content =~ s/row_326 light/row_326!light/g;
	$content =~ s/averageQualificationRow row_327 dark/averageQualificationRow!row_327!dark/g;
	$content =~ s/row_327 dark/row_327!dark/g;
	$content =~ s/averageQualificationRow row_328 light/averageQualificationRow!row_328!light/g;
	$content =~ s/row_328 light/row_328!light/g;
	$content =~ s/averageQualificationRow row_329 dark/averageQualificationRow!row_329!dark/g;
	$content =~ s/row_329 dark/row_329!dark/g;
	$content =~ s/averageQualificationRow row_330 light/averageQualificationRow!row_330!light/g;
	$content =~ s/row_330 light/row_330!light/g;

	
	my $dom = Mojo::DOM->new->parse(scalar $content);

	my $edstring = $dom->find('h3');
	unless ($edstring =~ m/flagCH/) {
		say "Wrong Edition: $edstring";
	}

	my ($beaq, $bear, $vadq, $vadr, $groq, $gror, $borq, $borr, $wenq, $wenr, $kitq, $kitr, $schq, $schr, $sum) = 0;

	$groq = $dom->find('tr.averageQualificationRow!row_326!light td.time');
	$gror = $dom->find('tr.row_326!light td.time');
	$borq = $dom->find('tr.averageQualificationRow!row_327!dark td.time');
	$borr = $dom->find('tr.row_327!dark td.time');
	$wenq = $dom->find('tr.averageQualificationRow!row_328!light td.time');
	$wenr = $dom->find('tr.row_328!light td.time');
	$kitq = $dom->find('tr.averageQualificationRow!row_329!dark td.time');
	$kitr = $dom->find('tr.row_329!dark td.time');
	$schq = $dom->find('tr.averageQualificationRow!row_330!light td.time');
	$schr = $dom->find('tr.row_330!light td.time');	
	#-----------------------------------------------------------------------
	$beaq = striptime($beaq);
	$bear = striptime($bear);
	$vadq = striptime($vadq);
	$vadr = striptime($vadr);
	$wenq = striptime($wenq);
	$wenr = striptime($wenr);
	$groq = striptime($groq);
	$gror = striptime($gror);
	$borq = striptime($borq);
	$borr = striptime($borr);
	$kitq = striptime($kitq);
	$kitr = striptime($kitr);
	$schq = striptime($schq);
	$schr = striptime($schr);
	
	$sum = $beaq + $bear + $vadq + $vadr + $groq + $gror + $borq + $borr + $wenq + $wenr + $kitq + $kitr + $schq + $schr;
	return unless $sum > 0; #bringt nichts diesen Record upzudaten...
	
	#if ($bear - $beaq > 10000) { #Greentube Fehler Workaround (0.04), Wenn Differenz bear zu beaq grösser als 10 Sekunden...
	#	$bear = parsebearfromranking($nick);
	#}
	
	$nick = decode("UTF-8", $nick);
	my $nickup = uc($nick);

	my $sql = "UPDATE scranking SET ";
	$sql .= "beaq=$beaq," if $beaq > 0;
	$sql .= "bear=$bear," if $bear > 0;
	$sql .= "vadq=$vadq," if $vadq > 0;
	$sql .= "vadr=$vadr," if $vadr > 0;
	$sql .= "groq=$groq," if $groq > 0;
	$sql .= "gror=$gror," if $gror > 0;
	$sql .= "borq=$borq," if $borq > 0;
	$sql .= "borr=$borr," if $borr > 0;
	$sql .= "wenq=$wenq," if $wenq > 0;
	$sql .= "wenr=$wenr," if $wenr > 0;
	$sql .= "kitq=$kitq," if $kitq > 0;
	$sql .= "kitr=$kitr," if $kitr > 0;
	$sql .= "schq=$schq," if $schq > 0;
	$sql .= "schr=$schr," if $schr > 0;
	
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
	exec("/usr/bin/perl","/root/ralphweb/db/sc/update.pl");
}

sub striptime {
	my $c = shift;
	$c =~ s/<td class="time">//;
	$c =~ s/<\/td>//;
	$c =~ s/\://;
	$c =~ s/\,//;
	return $c;
}

#sub parsebearfromranking {
#	my $nick = shift;
#	my $site = "http://ftv.sc14.greentube.com/webmagic/Ranking?competitionId=456&levelId=0&nick=$nick";
#	my $content = get($site);
#	my $dom = Mojo::DOM->new->parse(scalar $content);
#	my $bear = 0;
#	
#	for my $e ($dom->find('tr.target strong')->each) {
#		$bear = $e->text;
#		$bear =~ s/\://;
#		$bear =~ s/\,//;
#	}
#	return $bear;
#}
