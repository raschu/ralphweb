use Mojo::DOM;
use LWP::Simple;
use Modern::Perl;
use Encode;
use File::Copy;
no warnings;

my $VER = "0.13";
print "Starting KRbot $VER\n";

#0.04: falsche Zeiten auf Greentube Webseite. muss von anderer Seite geparst werden. (Workaround)
#0.05: einzelner Nick aktualisieren (perl KRbot.pl 0 4mon4marth)
#0.06: Greentube Workaround deaktiviert
#0.07: Fucking Umlautz....
#0.08: Nick in Upper Case...
#0.09: FindBin eingebaut
#0.10: FindBin wieder entfernt
#0.11: Debug bei sqlite pipe Update
#0.12: File::Copy eingebaut, da Probleme mit system("cp...") aufgetaucht sind
#0.13: Update extern, da zuwenig Haupstpeicher verfügbar

my $all = $ARGV[0];
my $singlenick = $ARGV[1];
my $workdir = '/root/www/ralphweb/db/sc';
my $now = time();
my $nickstring = "";
my $reccnt = 0;

if ($all == 1) {
	$reccnt = qx(sqlite3 $workdir/sc12.sqlite "select count(nick) from scranking");
	chomp($reccnt);
	$nickstring = qx(sqlite3 $workdir/sc12.sqlite "select nick from scranking order by nick");
	print "parsing all ($reccnt Records)!\n";
} elsif ($all == 0) {
	if ($singlenick gt "") { #nur einzelnen Nick updaten
		$singlenick = encode("iso-8859-1", $singlenick);
		my $sqlstring = parsedata($singlenick, "single");
		open(DAT, "|sqlite3 $workdir/sc12.sqlite");
		print DAT "$sqlstring\n";
		print DAT "vacuum;\n";
		close(DAT);
		exit;
	} else {
		$reccnt = qx(sqlite3 $workdir/sc12.sqlite "select count(nick) from scranking where updatetime > 1000");
		chomp($reccnt);
		$nickstring = qx(sqlite3 $workdir/sc12.sqlite "select nick from scranking where updatetime > 1000 order by nick");
		print "parsing newest ($reccnt Records)!\n";
	}
} else {
	die "wrong parameter";
}

my @nicks = split(/\n/, $nickstring);
unlink("$workdir/sc12data.txt");

foreach (@nicks) {
	print "$_\n";
	parsedata($_, "all");
}

updatedb();

sub parsedata {
	my $nick = shift;
	$nick = encode("UTF-8", $nick);
	my $mode = shift;
	#my $site = "http://sf.sc12.greentube.com/webmagic/PlayerProfile?nick=$nick";
	my $site = "http://ftv.sc12.greentube.com/webmagic/PlayerProfile?nick=$nick"; #Hier gehts ohne Javascript
	my $content = get($site);

	return if $content =~ m/konnte nicht gefunden werden/;

	$content =~ s/averageQualificationRow row_297 light/averageQualificationRow!row_297!light/g;
	$content =~ s/row_297 light/row_297!light/g;
	$content =~ s/averageQualificationRow row_298 dark/averageQualificationRow!row_298!dark/g;
	$content =~ s/row_298 dark/row_298!dark/g;
	$content =~ s/averageQualificationRow row_299 light/averageQualificationRow!row_299!light/g;
	$content =~ s/row_299 light/row_299!light/g;
	$content =~ s/averageQualificationRow row_300 dark/averageQualificationRow!row_300!dark/g;
	$content =~ s/row_300 dark/row_300!dark/g;
	$content =~ s/averageQualificationRow row_301 light/averageQualificationRow!row_301!light/g;
	$content =~ s/row_301 light/row_301!light/g;
	$content =~ s/averageQualificationRow row_288 light/averageQualificationRow!row_288!dark/g;
	$content =~ s/row_288 light/row_288!light/g;	

	my $dom = Mojo::DOM->new->parse(scalar $content);

	my $edstring = $dom->find('h3 img');
	my ($ch, $edition) = split(/\"/, $edstring);
	
	unless($edition eq "CH") {
		say "Wrong Edition: $nick -> $edition";
		#return;
	}

	my ($beaq, $bear, $vadq, $vadr, $groq, $gror, $borq, $borr, $wenq, $wenr, $kitq, $kitr, $sum) = 0;

	$beaq = $dom->find('tr.averageQualificationRow!row_297!light td.time');
	$bear = $dom->find('tr.row_297!light td.time');
	$vadq = $dom->find('tr.averageQualificationRow!row_298!dark td.time');
	$vadr = $dom->find('tr.row_298!dark td.time');
	$groq = $dom->find('tr.averageQualificationRow!row_299!light td.time');
	$gror = $dom->find('tr.row_299!light td.time');
	$borq = $dom->find('tr.averageQualificationRow!row_300!dark td.time');
	$borr = $dom->find('tr.row_300!dark td.time');
	$wenq = $dom->find('tr.averageQualificationRow!row_301!light td.time');
	$wenr = $dom->find('tr.row_301!light td.time');
	$kitq = $dom->find('tr.averageQualificationRow!row_288!dark td.time');
	$kitr = $dom->find('tr.row_288!light td.time');
	
	$beaq = striptime($beaq);
	$bear = striptime($bear);
	$vadq = striptime($vadq);
	$vadr = striptime($vadr);
	$groq = striptime($groq);
	$gror = striptime($gror);
	$borq = striptime($borq);
	$borr = striptime($borr);
	$wenq = striptime($wenq);
	$wenr = striptime($wenr);
	$kitq = striptime($kitq);
	$kitr = striptime($kitr);
	
	$sum = $beaq + $bear + $vadq + $vadr + $groq + $gror + $borq + $borr + $wenq + $wenr + $kitq + $kitr;
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
	
	$sql .= "updatetime=$now WHERE nick='$nick' OR UPPER(nick)='$nickup';";
	
	if ($mode eq "all") {
		#say $sql;
		open(DAT, ">>$workdir/sc12data.txt");
		print DAT "$sql\n";
		close(DAT);
	} elsif ($mode eq "single") {
		say "Single Update: $sql";
		return $sql;
	}
}

sub updatedb {
	#print "Updating db in $workdir\n";
	#open(LOG, "$workdir/sc12data.txt") or die "kann $workdir/sc12data.txt nicht oeffnen";
	#my @sqls = <LOG>;
	#close(LOG);
	
	#print "Making Backup of $workdir/sc12.sqlite\n";
	#copy("$workdir/sc12.sqlite", "$workdir/TEMPbackupDB/sc12.$hour") or die "kann nicht von $workdir/sc12.sqlite nach $workdir/TEMPbackupDB/sc12.$hour kopieren ($!)";
	
	#print "Piping $workdir/sc12.sqlite\n";
	#open(DAT, "|sqlite3 $workdir/sc12.sqlite") or die "kann DB $workdir/sc12.sqlite nicht oeffnen ERROR: -> $! <-";
	#foreach my $sql (@sqls) {
		#print "PIPE DEBUG: $sql\n";
	#	print DAT "$sql\n";
	#}
	#print "Vacuumize $workdir/sc12.sqlite\n";
	#print DAT "vacuum;\n";
	#close(DAT);
	exec("/usr/bin/perl","/root/www/ralphweb/db/sc/update.pl");
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
#	my $site = "http://ftv.sc12.greentube.com/webmagic/Ranking?competitionId=456&levelId=0&nick=$nick";
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
