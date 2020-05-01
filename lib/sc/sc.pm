package sc;
use Dancer ':syntax';
use sc::profile;
use sc::register;
use sc::facebook;
use sc::cli;
use POSIX;
use Crypt::Tea;

our $VERSION = '0.1';

#get '/scbroadcast' => sub {
#	template 'sc/broadcast';
#};
#############################################################################################
get '/scmedia/:edition' => sub {
	my $edition = params->{edition};
	template 'sc/media', {edition => $edition};
};
#############################################################################################
get '/showmedia/:file' => sub {
	my $file = params->{file};
	$file = "/images/media/$file";
	template 'layouts/showmedia', {file => $file};
};
#############################################################################################
get '/sc/:edition' => sub {
	my $edition = params->{edition};
	my $path = "";
	$path = cookie "__scpath";
	
	if (!$path) {
		redirect "/sc/$edition/CH/beaq/0";
	} else {
		redirect "/sc/$edition/$path";
	}
	
};
#############################################################################################
get '/scstats/:edition' => sub {
	my $edition = params->{edition};
	my $path = "";
	$path = cookie "__scstatspath";
	
	if (!$path) {
		redirect "/scstats/$edition/average_time_per_race/beaq";
	} else {
		redirect "/scstats/$edition/$path";
	}
};
#############################################################################################
get '/scstats/:edition/:type/:cat' => sub {
	my $edition = params->{edition};
	my $cat = params->{cat};
	my $type = params->{type};
	my $url = "";
	
	if ($type =~ m/time_distribution_per_race/) {
		my $sec = $type;
		$sec =~ s/time_distribution_per_race_//;
		my $url1 = qx(/usr/bin/php /root/ralphweb/bin/scstats_$edition/stats.php time_distribution_per_race $cat $sec);
		#debug "/usr/bin/php /root/ralphweb/bin/scstats_$edition/stats.php time_distribution_per_race $cat $sec";
		$url = "<img src=\"$url1\"/><br/>\n";
	} else {
		my $url1 = qx(/usr/bin/php /root/ralphweb/bin/scstats_$edition/stats.php $type $cat);
		$url = "<img src=\"$url1\"/><br/>\n";
	}
	
	set_cookie __scstatspath => "$type/$cat", expires => (time + 630720000);
	template 'sc/stats', {url => $url, cat => $cat, edition => $edition, type => $type};
};
#############################################################################################
get '/sc/:edition/:ktn/:cat/:offset' => sub {
	my $edition = params->{edition};
	redirect '/404' unless $edition == 11 or $edition == 12 or $edition == 13 or $edition == 14 or $edition == 15 or $edition == 16;	
	my $scdb;
	$scdb = "/root/ralphweb/db/sc/sc11.sqlite" if $edition == 11;
	$scdb = "/root/ralphweb/db/sc/sc12.sqlite" if $edition == 12;
	$scdb = "/root/ralphweb/db/sc/sc13.sqlite" if $edition == 13;
	$scdb = "/root/ralphweb/db/sc/sc14.sqlite" if $edition == 14;
	$scdb = "/root/ralphweb/db/sc/sc15.sqlite" if $edition == 15;
	$scdb = "/root/ralphweb/db/sc/sc16.sqlite" if $edition == 16;		
	my $cat = params->{cat};
	my $ktn = params->{ktn};
	my $rankingid = params->{ktn};
	my $offset = params->{offset};
	my $sessionid = session('id');
	my $specinc1 = 0; #Include betr curl und wget für http://ralphschuler.ch/cli/15/beaq/954174650735794902966240552596096050
		
	redirect '/404' unless ($offset == 0 or substr($offset, -2) =~ m/50/ or substr($offset, -2) =~ m/00/); #gibt sonst komische Resultate in den Ranglist
	
	my %ktnbez = (
		'TC'=>'Team CH','LA'=>'Ladies','OL'=>'Oldies','MA'=>'Markierte','FB'=>'Facebook','CH'=>'Schweiz','ZH'=>'Zürich','BE'=>'Bern','LU'=>'Luzern','UR'=>'Uri','SZ'=>'Schwyz','OW'=>'Obwalden','NW'=>'Nidwalden','GL'=>'Glarus','ZG'=>'Zug','FR'=>'Freiburg','SO'=>'Solothurn','BS'=>'Basel-Stadt','BL'=>'Basel-Landschaft','SH'=>'Schaffhausen','AR'=>'Appenzell Ausserhoden','AI'=>'Appenzell Innerhoden','SG'=>'St. Gallen','GR'=>'Graubünden','AG'=>'Aargau','TG'=>'Thurgau','TI'=>'Tessin','VD'=>'Waadt','VS'=>'Wallis','NE'=>'Neuenburg','GE'=>'Genf','JU'=>'Jura'
	);
	my %catbez = (
		'beaq'=>'Beaver Creek Quali','bear'=>'Beaver Creek Rennen','vadq'=>'Val d\'Isère Quali','vadr'=>'Val d\'Isère Rennen','groq'=>'Gröden Quali','gror'=>'Gröden Rennen','borq'=>'Bormio Quali','borr'=>'Bormio Rennen','wenq'=>'Wengen Quali','wenr'=>'Wengen Rennen','kitq'=>'Kitzbühel Quali','kitr'=>'Kitzbühel Rennen','garq'=>'Garmisch Quali','garr'=>'Garmisch Rennen','schq'=>'Schladming Quali','schr'=>'Schladming Rennen','socq'=>'Sochi Quali','socr'=>'Sochi Rennen','stmq'=>'St. Moritz Quali','stmr'=>'St. Moritz Rennen'
	);
	
	my $nickstomark = "";
	$nickstomark = cookie "__scnickstomark";
	my @nickstm = split(/\*/, $nickstomark) if $nickstomark;
	
	my %nickstm;
	
	my $n2;
	foreach (@nickstm) {
		$nickstm{$_} = $_;
		$n2 .= $_ . ";";
	}
	my $nicksencrypted = encrypt($n2, '345rf');
	my $sortdir = "ASC";
	
	set_cookie __scpath => "$ktn/$cat/0", expires => (time + 630720000);
	
	my $sql;
	my $bestzeit;
	my $avgzeit;
	if ($ktn eq "CH") {
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $cat > 0 order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking  where $cat > 0 order by $cat limit 0, 1";
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $cat > 0;";
	} elsif ($ktn eq "FB") {
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $cat > 0 and facebookid > 0 order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking  where $cat > 0 and facebookid > 0 order by $cat limit 0, 1";
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $cat > 0 and facebookid > 0;";
	} elsif ($ktn eq "LA") {
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $cat > 0 and sex ='f' order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking  where $cat > 0 and sex ='f' order by $cat limit 0, 1";
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $cat > 0 and sex ='f';";
	} elsif ($ktn eq "OL") {
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $cat > 0 and nick like'old%' order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking  where $cat > 0 and nick like'old%' order by $cat limit 0, 1";
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $cat > 0 and nick like'old%';";
	} elsif ($ktn eq "TC") {
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $cat > 0 and nick like 'tchI%' order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking  where $cat > 0 and nick like 'tchI%' order by $cat limit 0, 1";
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $cat > 0 and nick like 'tchI%';";
	} elsif ($ktn eq "MA") {
		my $nickssql;
		my $cntma;
		$specinc1 = 1;
		
		foreach my $n (@nickstm) {
			#print DAT "$n\n" if $n gt "";
			if (++$cntma == scalar(@nickstm)) {
				$nickssql .= " (nick = '$n' and $cat > 0)" if $n gt '';
			} else {
				$nickssql .= " (nick = '$n' and $cat > 0) or" if $n gt '';
			}
		}
		#close(DAT);
		
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $nickssql order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking  where $nickssql order by $cat limit 0, 1";
		#debug $sql;
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $nickssql;";
	} elsif ($ktn =~ m/JG/) {
		my $jgfrom = $ktn;
		$jgfrom =~ s/JG//;
		my $jgto = $jgfrom + 9;
		my $agefrom = "'$jgfrom-01-01 00:00:00'";
		my $ageto = "'$jgto-12-31 23:59:59'";
		%ktnbez = ($ktn=>"Jahrgang $jgfrom - $jgto");
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $cat > 0 and birthday between $agefrom and $ageto order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking  where $cat > 0 and birthday between $agefrom and $ageto order by $cat limit 0, 1";
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $cat > 0 and birthday between $agefrom and $ageto;";
	}
	else {
		$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where kanton = '$ktn' and $cat > 0 order by $cat $sortdir limit $offset, 50";
		$bestzeit = "SELECT $cat FROM scranking where kanton = '$ktn' and $cat > 0 order by $cat limit 0, 1";
		$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where kanton = '$ktn' and $cat > 0;";	
	}
	
	#debug $avgzeit;
	
	my $bzres = qx(sqlite3 $scdb "$bestzeit");
	chomp($bzres);
	my $bestinsec = calcsec($bzres);
	
	#debug "bzres: $bzres";
	
	my $avg = qx(sqlite3 $scdb "$avgzeit");
	chomp($avg);
	my $avginsec = floor($avg);
	#my $avginsec = calcsec($avg);
	
	#debug "avginsec: $avg";
	
	#debug $avginsec;
	
	my @scdata = qx(sqlite3 $scdb "$sql");
	
	my $json = '{}';
	my $data = from_json $json;
	my $cnt = 0;
	my $rank = 0;
	for my $r (@scdata) {
		$cnt++;
		$rank = $cnt + $offset;
		chomp($r);
		my ($nick, $ktn, $time, $sex, $birthday, $facebookid) = split(/\|/, $r);
		my $t1;
		my $t2;
		my $t3;
		
		my $timeinsec = calcsec($time);		
		my $diff = sprintf ("%.3f" ,($timeinsec  - $bestinsec) / 1000);
		my $diffavg = sprintf ("%.3f" ,($timeinsec  - $avginsec) / 1000);
				
		if ($diffavg <= 0) {
			$diffavg = "<font color=green>$diffavg</font>";
		} else {
			$diffavg = "<font color=red>$diffavg</font>";
		}
		
		if ($sex eq "m") {
			$sex = "<img src=\"/images/sc/14px.jpg\" alt=\"\"/>";
		}
		if ($sex eq "f") {
			$sex = "<img src=\"/images/sc/sex.f.jpg\"  alt=\"\" title=\"female\"/>";
		}
		
		my ($by, $bm, $bd) = split(/\-/, $birthday);
		$birthday = $by;
		
		my $fb = "";
		if ($facebookid gt "") {
			$fb = "<a href=\"http://facebook.com/profile.php?id=$facebookid\"><img src=\"/images/sc/fb.jpg\" alt=\"\"/></a>";
		} else {
			$fb = "<img src=\"/images/sc/14px.jpg\" alt=\"\"/>";
		}
		
		my $icoktn = "<img src=\"/images/sc/ico$ktn.png\" alt=\"\"/>";
		
		my $textmarker = "none";
		
		#debug "ktn: $ktn";
		
		$textmarker = "yellow;color:black" if (exists($nickstm{$nick})) and $rankingid ne "MA";
		my $index = sprintf("%02d", $cnt);
		$data->{$index} = {
			nick => $nick,
			ktn => $ktn,
			time => $time,
			diff => $diff,
			diffavg => $diffavg,
			sex => $sex,
			birthday => $birthday,
			fb => $fb,
			rank => $rank,
			icoktn => $icoktn,
			textmarker => $textmarker
		};
	}
	
	my $navi = "";
	
	if ($rank >= 50 and $offset > 0) {
		my $r1 = $offset - 50;
		my $r2 = $offset - 49;
		$navi = "<strong>&nbsp;&nbsp;<a href=\"/sc/$edition/$ktn/$cat/$r1\">&lt;&lt; $r2-$offset</a></strong>";
	}
	
	if ($rank >= $offset + 50) {
		my $r1 = $offset + 50;
		my $r2 = $r1 + 1;
		my $r3 = $r2 + 49;
		$navi .= "<strong>&nbsp;&nbsp;<a href=\"/sc/$edition/$ktn/$cat/$r1\">$r2-$r3 >></a></strong>";
	}
		
	template "sc/main_$edition", {
		data => $data,
		edition => $edition,
		ktn => $ktn,
		cat => $cat,
		ktnbez => $ktnbez{$ktn},
		catbez => $catbez{$cat},
		offset => $offset,
		navi => $navi,
		sessionid => $sessionid,
		specinc1 => $specinc1
	};
};

#############################################################################################
get '/schelp' => sub {
	template 'sc/help';
};
###

sub calcsec {
	my $v = shift;
	my $totalms = 0;
	my $min = substr($v,0,1);
	my $sec = substr($v,1,2);
	my $ms = substr($v,3,3);
	
	$totalms += $min * 60000;
	$totalms += $sec * 1000;
	$totalms += $ms;
}
#############################################################################################
true;
