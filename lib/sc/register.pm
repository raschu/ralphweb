package register;
use Dancer ':syntax';
use Encode;

our $VERSION = '0.1';

get '/scregister' => sub {
	template 'sc/register';
};
#############################################################################################
post '/scregister2' => sub {
		
	my $ip = $ENV{'HTTP_X_FORWARDED_FOR'};
	my $nick = params->{nick};
	my $ktn = params->{ktn};
	my $sex = params->{sex};
	my $bday = params->{bday};
	my $bmonth = params->{bmonth};
	my $byear = params->{byear};
	my $error = 0;
	my $errorstring = "";
	
	if ($bday eq "") {
		$error = 1;
		$errorstring = "Fehler im Geburtsdatum.<br>Bitte zurück Button klicken.";
	} else {
		$bday = sprintf("%02d", $bday);
	}
	
	if ($bmonth eq "") {
		$error = 1;
		$errorstring = "Fehler im Geburtsdatum.<br>Bitte zurück Button klicken.";
	} else {
		$bmonth = sprintf("%02d", $bmonth);
	}
	
	if ($byear eq "") {
		$error = 1;
		$errorstring = "Fehler im Geburtsdatum.<br>Bitte zurück Button klicken.";
	}
	
	if (!$sex) {
		$error = 1;
		$errorstring = "Kein Geschlecht angegeben.<br>Bitte zurück Button klicken.";
	}
	
	if ($ktn eq "") {
		$error = 1;
		$errorstring = "Kein Kanton angegeben.<br>Bitte zurück Button klicken.";
	}
	
	if ($nick eq "") {
		$error = 1;
		$errorstring = "Kein Nick angegeben.<br>Bitte zurück Button klicken.";
	}
	
	if ($error == 1) {
		template 'sc/register_error', {errorstring => $errorstring};
	} else {
		my $gebdatum = "$bday.$bmonth.$byear";
		my $birthday = "$byear-$bmonth-$bday";
		
		my $nicktocheck = $nick;
		$nicktocheck = encode("iso-8859-1", $nicktocheck);
		my $uppernick = uc($nicktocheck);
		my $exists = 0;
		$exists = qx(sqlite3 /root/ralphweb/db/sc/sc16.sqlite "SELECT COUNT(*) FROM scranking where upper(nick) = '$uppernick'");
				
		if ($exists > 0) {
			my $errorstring;
			my $facebookid = "";			
			$facebookid = qx(sqlite3 /root/ralphweb/db/sc/sc16.sqlite "SELECT facebookid FROM scranking where nick = '$nicktocheck'");
			$facebookid =~ s/\n//g;
			
			if ($facebookid gt "") {
				$errorstring = "<b>$nick</b> wurde schon in der Datenbank eingetragen. Vermutlich bei einer früheren Ausgabe des Kantonsrankings. Bitte beachte, dass es bis zu 6 Stunden dauern kann, bis der Nick zum ersten mal aktualisiert wird. Bei Unklarheiten bitte eine Email an sc16\@ralphschuler.ch senden.<br><br><a href=\"http://ralphschuler.ch/profile/16/$nick\">Profil von $nick</a><p>";
			} else {
				$errorstring = "<b>$nick</b> wurde schon in der Datenbank eingetragen. Vermutlich bei einer früheren Ausgabe des Kantonsrankings. Bitte beachte, dass es bis zu 6 Stunden dauern kann, bis der Nick zum ersten mal aktualisiert wird. Bei Unklarheiten bitte eine Email an sc16\@ralphschuler.ch senden.<p><a href=\"/scfb/$nick\">Hier klicken</a>, wenn du deinen Facebook Account mit <b>$nick</b> verknüpfen möchtest.<br><br><a href=\"http://ralphschuler.ch/profile/16/$nick\">Profil von $nick</a></p>";
			}			
			system("echo \"$ip http://ralphschuler.ch/profile/16/$nick $sex $birthday $ktn\" \| mail -s \"[$ip] SC Register already in DB\" sc16\@ralphschuler.ch");
			system("/usr/bin/perl /root/ralphweb/db/sc/krbot.pl 0 $nick");
			template 'sc/register_error', {errorstring => $errorstring};
		} else {
			my $now = time();
			system("echo \"$ip http://ralphschuler.ch/profile/16/$nick $sex $birthday $ktn\" \| mail -s \"[$ip] SC Register new entry\" sc16\@ralphschuler.ch");
			
			open(DB, "|/usr/bin/sqlite3 /root/ralphweb/db/sc/sc16.sqlite");
			print DB "INSERT into scranking ('nick', 'sex', 'birthday','kanton','updatetime') VALUES ('$nick', '$sex', '$birthday', '$ktn', '$now');";
			close(DB);
			system("/usr/bin/perl /root/ralphweb/db/sc/krbot.pl 0 $nick");
			template 'sc/register2', {nick => $nick, ktn => $ktn, sex => $sex, gebdatum => $gebdatum};	
		}
	}
};
#############################################################################################
