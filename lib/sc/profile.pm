package profile;
use Dancer ':syntax';
use Encode;

our $VERSION = '0.1';
our %rennen = (
    vadq => "Val d'Isère Quali",
    vadr => "Val d'Isère Rennen",    
    groq => "Gröden Quali", 
    gror => "Gröden Rennen",
    borq => "Bormio Quali",
    borr => "Bormio Rennen",
    wenq => "Wengen Quali",
    wenr => "Wengen Rennen",
    kitq => "Kitzbühel Quali",
    kitr => "Kitzbühel Rennen",
    garq => "Garmisch Quali",
    garr => "Garmisch Rennen",
    beaq => "Beaver Creek Quali",
    bear => "Beaver Creek Rennen",
    schq => "Schladming Quali",
    schr => "Schladmin Rennen",
	socq => "Sochi Quali",
    socr => "Sochi Rennen",
	stmq => "St. Moritz Quali",
    stmr => "St. Moritz Rennen",   	
    wcpos => "Weltcup"
);

get '/textmarker/:nick/:toggle/:edition' => sub {
	my $edition = params->{edition};
	my $nickstomark = "";
	$nickstomark = cookie "__scnickstomark";
	my $nick = params->{nick};
	my $toggle = params->{toggle};
	$nickstomark .= "*$nick" if $toggle == 0;
	$nickstomark =~ s/\*$nick// if $toggle == 1;
	
	my @nickstm = split(/\*/, $nickstomark) if $nickstomark;
	
	my $sessionid = session('id');
	
	open(DAT, ">/root/www/ralphweb/db/sc/siddata/$sessionid.txt");
	
	foreach my $n (@nickstm) {
		print DAT "$n\n" if $n gt "";
	}
	close(DAT);
	
	
	set_cookie __scnickstomark => $nickstomark, expires => (time + 630720000);
	redirect "/sc/$edition";
};
#############################################################################################
get '/profile/:edition/:nick/fromrss/:hash' => sub {
	my $edition = params->{edition};
	my $nick = params->{nick};
	redirect "/profile/$edition/$nick";
};	
#############################################################################################
get '/profile/:edition/:nick/:cat' => sub {
	my $edition = params->{edition};
	my $nick = params->{nick};
	my $cat = params->{cat};
        my $catbez = $rennen{$cat};
        my $url = qx (/usr/bin/php /root/www/ralphweb/bin/scstats_$edition/stats.php time_difference_per_race_and_player $cat $nick);
	
	template 'sc/profile_chart', {nick => $nick, catbez => $catbez, edition => $edition, url => $url};
};
#############################################################################################
get '/profile/:edition/:nick' => sub {
	
	my $edition = params->{edition};
	my $nick = params->{nick};
	my $scdb;	
	$scdb = "/root/www/ralphweb/db/sc/sc11.sqlite" if $edition == 11;
	$scdb = "/root/www/ralphweb/db/sc/sc12.sqlite" if $edition == 12;
	$scdb = "/root/www/ralphweb/db/sc/sc13.sqlite" if $edition == 13;
	$scdb = "/root/www/ralphweb/db/sc/sc14.sqlite" if $edition == 14;
	$scdb = "/root/www/ralphweb/db/sc/sc15.sqlite" if $edition == 15;
	$scdb = "/root/www/ralphweb/db/sc/sc16.sqlite" if $edition == 16;
	$nick = encode("iso-8859-1", $nick);
	my $uppernick = uc($nick);
	
	my $exists = 0;
	$exists = qx(sqlite3 $scdb "SELECT COUNT(*) FROM scranking where upper(nick) = '$uppernick'");
	if ($exists == 0) {
		redirect '/404';
		return;
	}
	
	my $nickstomark = "";
	$nickstomark = cookie "__scnickstomark";
	my @nickstm = split(/\*/, $nickstomark) if $nickstomark;
	my $toggletextmark = "";
	my %nickstm;
	
	foreach (@nickstm) {
		$nickstm{$_} = $_;
	}
		
	if (exists($nickstm{$nick})) {
		$toggletextmark = "<strong><a href=\"/textmarker/$nick/1/$edition\" title=\"hier klicken um auszuschalten\">ausschalten</a></strong>";
	} else {
		$toggletextmark = "<strong><a href=\"/textmarker/$nick/0/$edition\" title=\"hier klicken um einzuschalten\">einschalten</a></strong>";
	}
		
	my $sql = "select * from scranking where upper(nick)='$uppernick';";
	my $scdata = qx(sqlite3 $scdb "$sql");
	my $cnt = 0;	
	my ($nickdb, $ktn, $updatetime, $groq, $gror, $borq, $borr, $wenq, $wenr, $kitq, $kitr, $garq, $garr, $vadq, $vadr, $wcpos, $wcpts, $sex, $birthday, $ip, $kilometers, $racesFinished, $crashes, $quota, $wcptsperkm, $gdeid, $fbid, $fbname, $beaq, $bear, $schr, $schq,$socq,$socr,$stmq,$stmr) = split(/\|/, $scdata);
	
	
	if (!$fbid) {
		#$fbid = "&nbsp;";
		$fbid = "<a href=\"/scfb/$nick\" title=\"hier klicken um $nick mit dem Facebook-Profil zu verbinden\">verbinden</a>";
	} else {
		
		
		
		$fbid = "<a href=\"http://facebook.com/profile.php?id=$fbid\" title=\"Facebook Seite von $nick besuchen\"><img src=\"http://graph.facebook.com/$fbid/picture\" border=\"0\"></a>";
	}
	
	my ($rkvadq, $ravadq) = calcrang($nick, "vadq", $ktn, $edition);
	my ($rkvadr, $ravadr) = calcrang($nick, "vadr", $ktn, $edition);
	my ($rkgroq, $ragroq) = calcrang($nick, "groq", $ktn, $edition);
	my ($rkgror, $ragror) = calcrang($nick, "gror", $ktn, $edition);
	my ($rkborq, $raborq) = calcrang($nick, "borq", $ktn, $edition);
	my ($rkborr, $raborr) = calcrang($nick, "borr", $ktn, $edition);
	my ($rkwenq, $rawenq) = calcrang($nick, "wenq", $ktn, $edition);
	my ($rkwenr, $rawenr) = calcrang($nick, "wenr", $ktn, $edition);
	my ($rkkitq, $rakitq) = calcrang($nick, "kitq", $ktn, $edition);
	my ($rkkitr, $rakitr) = calcrang($nick, "kitr", $ktn, $edition);
	my ($rkgarq, $ragarq) = calcrang($nick, "garq", $ktn, $edition);
	my ($rkgarr, $ragarr) = calcrang($nick, "garr", $ktn, $edition);
	my ($rkbeaq, $rabeaq) = calcrang($nick, "beaq", $ktn, $edition);
	my ($rkbear, $rabear) = calcrang($nick, "bear", $ktn, $edition);
	my ($rkschq, $raschq) = calcrang($nick, "schq", $ktn, $edition);
	my ($rkschr, $raschr) = calcrang($nick, "schr", $ktn, $edition);
	my ($rksocq, $rasocq) = calcrang($nick, "socq", $ktn, $edition);
	my ($rksocr, $rasocr) = calcrang($nick, "socr", $ktn, $edition);
	my ($rkstmq, $rastmq) = calcrang($nick, "stmq", $ktn, $edition);
	my ($rkstmr, $rastmr) = calcrang($nick, "stmr", $ktn, $edition);	
	
	my @gefschweiz;
	my @gefkanton;
	my @geflabel;
	
	@gefschweiz = ($ravadq,$ravadr,$ragroq,$ragror,$raborq,$raborr,$rawenq,$rawenr,$rakitq,$rakitr,$ragarq,$ragarr,$rabeaq,$rabear,) if $edition == 11;
	@gefkanton =  ($rkvadq,$rkvadr,$rkgroq,$rkgror,$rkborq,$rkborr,$rkwenq,$rkwenr,$rkkitq,$rkkitr,$rkgarq,$rkgarr,$rkbeaq,$rkbear,) if $edition == 11;
	@geflabel = ('vadq','vadr','groq','gror','borq','borr','wenq','wenr','kitq','kitr','garq','garr') if $edition == 11;
	
	@gefschweiz = ($rabeaq,$rabear,$ravadq,$ravadr,$ragroq,$ragror,$raborq,$raborr,$rawenq,$rawenr,$rakitq,$rakitr) if $edition == 12;
	@gefkanton =  ($rkbeaq,$rkbear,$rkvadq,$rkvadr,$rkgroq,$rkgror,$rkborq,$rkborr,$rkwenq,$rkwenr,$rkkitq,$rkkitr) if $edition == 12;	
	@geflabel = ('beaq','bear','vadq','vadr','groq','gror','borq','borr','wenq','wenr','kitq','kitr') if $edition == 12;
	
	@gefschweiz = ($ragroq,$ragror,$raborq,$raborr,$rawenq,$rawenr,$rakitq,$rakitr,$raschq,$raschr) if $edition == 13;
	@gefkanton =  ($rkgroq,$rkgror,$rkgroq,$rkborr,$rkwenq,$rkwenr,$rkkitq,$rkkitr,$rkschq,$rkschr) if $edition == 13;	
	@geflabel = ('groq','gror','borq','borr','wenq','wenr','kitq','kitr','schq','schr') if $edition == 13;
	
	@gefschweiz = ($rabeaq,$rabear,$ragroq,$ragror,$raborq,$raborr,$rawenq,$rawenr,$rakitq,$rakitr,$ragarq,$ragarr,$rasocq,$rasocr) if $edition == 14;
	@gefkanton =  ($rkbeaq,$rkbear,$rkgroq,$rkgror,$rkborq,$rkborr,$rkwenq,$rkwenr,$rkkitq,$rkkitr,$rkgarq,$rkgarr,$rksocq,$rksocr) if $edition == 14;	
	@geflabel = ('beaq','bear','groq','gror','borq','borr','wenq','wenr','kitq','kitr','garq','garr','socq','socr') if $edition == 14;
	
	@gefschweiz = ($rabeaq,$rabear,$ragroq,$ragror,$raborq,$raborr,$rawenq,$rawenr,$rakitq,$rakitr,$ragarq,$ragarr) if $edition == 15;
	@gefkanton =  ($rkbeaq,$rkbear,$rkgroq,$rkgror,$rkborq,$rkborr,$rkwenq,$rkwenr,$rkkitq,$rkkitr,$rkgarq,$rkgarr) if $edition == 15;	
	@geflabel = qw(beaq bear groq gror borq borr wenq wenr kitq kitr garq garr) if $edition == 15;
	
	@gefschweiz = ($rabeaq,$rabear,$ravadq,$ravadr,$rasocq,$rasocr,$raschq,$raschr,$ragroq,$ragror,$raborq,$raborr,$rawenq,$rawenr,$rakitq,$rakitr,$ragarq,$ragarr,$rastmq,$rastmr) if $edition == 16;
	@gefkanton =  ($rkbeaq,$rkbear,$rkvadq,$rkvadr,$rksocq,$rksocr,$rkschq,$rkschr,$rkgroq,$rkgror,$rkborq,$rkborr,$rkwenq,$rkwenr,$rkkitq,$rkkitr,$rkgarq,$rkgarr,$rkstmq,$rkstmr) if $edition == 16;	
	@geflabel = ('beaq','bear','vadq','vadr','socq','socr','schq','schr','groq','gror','borq','borr','wenq','wenr','kitq','kitr','garq','garq','stmq','stmr') if $edition == 16;
	
	my $kantonstring = chartstring (@gefkanton);
	my $schweizstring = chartstring (@gefschweiz);
	my $labels = labelstring (@geflabel);
	
	#debug(@gefkanton);

	my $charturl = mkchart("$kantonstring", "$schweizstring", "$labels", "$nick", "$ktn");

	
	template "sc/profile.$edition", {
		edition => $edition,
		nick => $nickdb,
		ktn => $ktn,
		groq => $groq, 
		gror => $gror,
		borq => $borq,
		borr => $borr,
		wenq => $wenq,
		wenr => $wenr,
		kitq => $kitq,
		kitr => $kitr,
		garq => $garq,
		garr => $garr,
		vadq => $vadq,
		vadr => $vadr,
		beaq => $beaq,
		bear => $bear,
		schq => $schq,
		schr => $schr,
		socq => $socq,
		socr => $socr,
		stmq => $stmq,
		stmr => $stmr,		
		wcpos => $wcpos,
		wcpts => $wcpts,
		kilometers => $kilometers,
		racesFinished => $racesFinished,
		crashes => $crashes,
		quota => $quota,
		sex => $sex,
		birthday => $birthday,
		rkgroq => $rkgroq, 
		rkgror => $rkgror,	
		rkborq => $rkborq,
		rkborr => $rkborr,
		rkwenq => $rkwenq,
		rkwenr => $rkwenr,
		rkkitq => $rkkitq,
		rkkitr => $rkkitr,
		rkgarq => $rkgarq,
		rkgarr => $rkgarr,
		rkvadq => $rkvadq,
		rkvadr => $rkvadr,
		rkbeaq => $rkbeaq, 
		rkbear => $rkbear,
		rkschq => $rkschq, 
		rkschr => $rkschr,
		rkstmq => $rkstmq, 
		rkstmr => $rkstmr,		
		rksocq => $rksocq, 
		rksocr => $rksocr,
		ragroq => $ragroq, 
		ragror => $ragror,
		raborq => $raborq,
		raborr => $raborr,
		rawenq => $rawenq,
		rawenr => $rawenr,
		rakitq => $rakitq,
		rakitr => $rakitr,
		ragarq => $ragarq,
		ragarr => $ragarr,
		ravadq => $ravadq,
		ravadr => $ravadr,
		rabeaq => $rabeaq,
		rabear => $rabear,
		raschq => $raschq,
		raschr => $raschr,
		rasocq => $rasocq,
		rasocr => $rasocr,
		rastmq => $rastmq,
		rastmr => $rastmr,		
		charturl => $charturl,
		toggletextmark => $toggletextmark,
		fbid => $fbid
	};
};

sub calcrang {
	my $nick = shift;
	my $uppernick = uc($nick);
	my $cat = shift;
	my $kanton = shift;
	my $edition = shift;
	my $scdb;
	
	$scdb = "/root/www/ralphweb/db/sc/sc11.sqlite" if $edition == 11;
	$scdb = "/root/www/ralphweb/db/sc/sc12.sqlite" if $edition == 12;
	$scdb = "/root/www/ralphweb/db/sc/sc13.sqlite" if $edition == 13;
	$scdb = "/root/www/ralphweb/db/sc/sc14.sqlite" if $edition == 14;
	$scdb = "/root/www/ralphweb/db/sc/sc15.sqlite" if $edition == 15;
	$scdb = "/root/www/ralphweb/db/sc/sc16.sqlite" if $edition == 16;
		
	my $sql = "
	select count(*) as rank from 
	    (select $cat from scranking where kanton='$kanton' and $cat <
	       (select $cat from scranking where upper(nick)='$uppernick')
		and $cat > 100000
	 order by $cat asc)as s;
	";
	my $rwert1 = qx(sqlite3 $scdb "$sql");
	$rwert1++;
	
	my $sql2 = "
	select count(*) as rank from 
	    (select $cat from scranking where $cat <
	       (select $cat from scranking where upper(nick)='$uppernick')
		and $cat > 100000
	 order by $cat asc)as s;
	";
	my $rwert2 = qx(sqlite3 $scdb "$sql2");
	$rwert2++;
	
	return $rwert1, $rwert2;
}

sub mkchart {
#--------------------------------
	my $kantondata = shift;
	my $schweizdata = shift;
	my $labels = shift;
	my $nick = shift;
	my $kanton = shift;
	
	my $highest = 0;
	my $kstring = "";
	my $sstring = "";
	my @kdata = split (/\,/, $kantondata);
	my @sdata = split (/\,/, $schweizdata);
	my @diff;
	my $cnt = 0;
	my $faktor = 1;
	
	foreach (@sdata) {
		$highest = $_ if $_ > $highest;
		push (@diff, $sdata[$cnt] - $kdata[$cnt]);
   		$cnt++;
	}
	
	$faktor = 1;
	
	foreach (@diff) { #glaube Diff nicht nötig
		#print "diff $_\n";
		my $sw = $_ / $faktor;
		$sstring .= "$sw,";
	}
	chop ($sstring);

	foreach (@kdata) {
		my $kw = $_ / $faktor;
		$kstring .= "$kw,";
	}
	chop ($kstring);
	
	
	my $url = "";	
	my $u1 = "http://chart.apis.google.com/chart";
	my $u2 = "?cht=bvs";
	my $u3 = "&chs=600x200";
	my $u4 = "&chxt=y,x";
	my $u5 = "&chxl=1:|$labels|";
	my $u6 = "&chxr=0,0,$highest";
	my $u7 = "&chxs=0,000000,8,-1|1,000000,8,0";
	my $u8 = "&chdl=$kanton|CH";
	my $u9 = "&chco=88ac0b,237fbe";
	my $u10 = "&chd=t:$kstring|$sstring";
	#my $u11 = "&chtt=Ranking+Chart%20f%C3%BCr%20$nick";
	my $u11 = "";
	my $u12 = "&chts=000000,12&chf=bg,s,FFFFFF|c,s,FFFFFF";
	#my $u13 = "&chg=100,20,1,0";
	my $u14 = "&chds=0,$highest";
	my $u13 = "";
	
	$url = "$u1"."$u2"."$u3"."$u4"."$u5"."$u6"."$u7"."$u8"."$u9"."$u10"."$u11"."$u12"."$u13"."$u14";
	
	return ("$url");

}

sub chartstring {
	my @string = @_;
	my $newstring;
	foreach (@string) {
		$newstring .= "$_,";
	}
	chop ($newstring);
	return ($newstring);
}
sub labelstring {
	my @string = @_;
	my $newstring;
	
	foreach (@string) {
		$newstring .= "$_|";
	}
	
	chop ($newstring);
	return ($newstring);
}

true;
