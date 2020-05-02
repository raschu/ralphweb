package icc;
use Dancer ':syntax';
use DBI;

our $VERSION = '0.1';
our $dbfile = config->{maindir} . config->{channeldb};
#############################################################################################
get '/icc' => sub {
	my $path = "";
	$path = cookie "__iccpath";
		
	if (!$path) {
		redirect '/channel/97/month'
	} else {
		redirect $path;
	}
	
};
#############################################################################################
get '/channel/:channel/:time' => sub {
	my $ch = params->{channel};
	my $t = params->{time};
	my $intervall;
	my $fromtime;
	my $totime;
	my $anztage;
	my $tstring = "";
	
	set_cookie __iccpath => "/channel/$ch/$t", expires => (time + 630720000);
	
	my $now = time();
	my @monatstage = (31,28,31,30,31,30,31,31,30,31,30,31);
	
	if ($ch eq "") {
		$ch = 97;
	}
	if ($t eq "") {
		$t = "hour";
	}


    if ($t eq "hour"){
	    $intervall=3600;
	    $fromtime = $now - $intervall - 21600;  #zeitdifferenz zum ICC server time 6h in sommerzeit
	    $totime = $now - 21600;
	    $fromtime = localtime($fromtime);
	    $totime = localtime($totime);
		$tstring = "60 minutes";
    }
    elsif ($t eq "day"){
	    $intervall=86400;
	    $fromtime = $now - $intervall - 21600;  #zeitdifferenz zum ICC server time 6h in sommerzeit
	    $totime = $now - 21600;
	    $fromtime = localtime($fromtime);
	    $totime = localtime($totime);
		$tstring = "24 hours";
    }
    elsif ($t eq "week"){
	    $intervall=604800;
	    $fromtime = $now - $intervall - 21600;  #zeitdifferenz zum ICC server time 6h in sommerzeit
	    $totime = $now - 21600;
	    $fromtime = localtime($fromtime);
	    $totime = localtime($totime);
		$tstring = "7 days";
    }
    elsif ($t eq "month"){
	    my ($sec,$min,$hr,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($now);
		$anztage = $monatstage[$mon]; #hier wird berechnet wieviel tage der aktuelle monat hat
	    $intervall=86400 * $anztage; # 30 Tage
	    $fromtime = $now - $intervall - 21600;  #zeitdifferenz zum ICC server time 6h in sommerzeit
	    $totime = $now - 21600;
	    $fromtime = localtime($fromtime);
	    $totime = localtime($totime);
		$tstring = "30 days";
    }
    else {
	    $t = "month";
	    my ($sec,$min,$hr,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($now);
		$anztage = $monatstage[$mon]; #hier wird berechnet wieviel tage der aktuelle monat hat
	    $intervall=86400 * $anztage; # 30 Tage
	    $fromtime = $now - $intervall - 21600;  #zeitdifferenz zum ICC server time 6h in sommerzeit
	    $totime = $now - 21600;
	    $fromtime = localtime($fromtime);
	    $totime = localtime($totime);
		$tstring = "30 days";
    }

    my $zeitspanne = $now - $intervall;
    my $delzeit = $now - 2592000;
    my $ru = $ENV{'REQUEST_URI'};


	my $dbargs = {AutoCommit => 1, PrintError => 1};
	my $db = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "", $dbargs);

	my $sth = $db->prepare ("SELECT COUNT(*) FROM channels where timestamp >= $zeitspanne and channel = $ch");
	$sth->execute ();
	my $total = $sth->fetchrow_array ();
	
	my $breitefaktor = 1;	
	$breitefaktor = qx(sqlite3 $dbfile 'SELECT COUNT(*) AS Anzahl FROM channels where timestamp >= $zeitspanne and channel = $ch GROUP BY handle ORDER BY Anzahl DESC LIMIT 1;');

	unless ($total == 0) {
		$breitefaktor = 300 / ($breitefaktor / $total * 100);
	}
	my @chdata;
	if ($total > 0) { #Daten müssen nur abgefragt werden, wenn das Total grösser 0 ist.
		while(1) {
			@chdata = qx(sqlite3 $dbfile 'SELECT COUNT(*) AS Anzahl, handle, CAST(COUNT(*) * 100.00 / $total * 1.00 AS FLOAT(2)) AS Perc, COUNT(*) * 100.00 / $total * $breitefaktor AS Chart FROM channels where timestamp >= $zeitspanne and channel = $ch GROUP BY handle ORDER BY Anzahl DESC LIMIT 50');
			my $temp = @chdata;
			last if $temp > 0; #Irgend ein Timeout Problem verursacht, dass keine Daten von sqlite3 erhalten werden?? Erst weiter gehen, wenn Daten da sind (bei $total > 0);
		}
	}
	
	my $json = '{}';
	my $data = from_json $json;
	my $cnt = 0;
	for my $r (@chdata) {
		$cnt++;
		chomp($r);
		my ($anz, $han, $per, $car) = split(/\|/, $r);
		my $index = sprintf("%02d", $cnt);
		$per = sprintf("%.2f", $per);
		$car = sprintf("%.0f", $car);
		#print DAT "$anz $han $per $car\n";
		
		$data->{$index} = {
			anz => $anz,
			han => $han,
			per => $per,
			car => $car,
		};
	}
	
	template 'channel', {zeitspanne => $zeitspanne, channel => $ch, t => $t, tstring => $tstring, totaltells => $total, breitefaktor => $breitefaktor, data => $data, ru => $ru};
};

get '/icc_trends' => sub {
		
	template 'icc_trends', {
        five => calcpoolratings(5),
        three => calcpoolratings(3),
        one => calcpoolratings(1)
    };
};

get '/channel/:handle/:channel/:time' => sub {
	my $ch = params->{channel};
	my $chstring = $ch;
	$chstring = "shouts" if $ch eq "932";
	my $handle = params->{handle};
	my $sql = "";
	my $t = params->{time};
	my $skala = "";
	my $valstring = "";
	my $title = "";
	my $timestring = "";
	my $twidth = 0;

	if ($t eq "hour") {
		$twidth = '116';
		$timestring = "60 minutes";
		$skala = "45,30,15,0";
		$sql = "
		SELECT count(*) as total,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -3599) and (strftime('%s','now') -2700)) as c1,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2699) and (strftime('%s','now') -1800)) as c2,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1799) and (strftime('%s','now') -900)) as c3,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -899) and (strftime('%s','now') -0)) as c4
		FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -3599) and (strftime('%s','now') -0);
		";
	}
	if ($t eq "day") {
		$twidth = '596';
		$timestring = "24 hours";
		$skala = "23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0";
		$sql = "
		SELECT count(*) as total,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -86399) and (strftime('%s','now') -82800)) as c1,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -82799) and (strftime('%s','now') -79200)) as c2,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -79199) and (strftime('%s','now') -75600)) as c3,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -75599) and (strftime('%s','now') -72000)) as c4,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -71999) and (strftime('%s','now') -68400)) as c5,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -68399) and (strftime('%s','now') -64800)) as c6,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -63799) and (strftime('%s','now') -61200)) as c7,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -61199) and (strftime('%s','now') -57600)) as c8,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -57599) and (strftime('%s','now') -54000)) as c9,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -53999) and (strftime('%s','now') -50400)) as c10,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -50399) and (strftime('%s','now') -46800)) as c11,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -46799) and (strftime('%s','now') -43200)) as c12,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -43199) and (strftime('%s','now') -39600)) as c13,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -39599) and (strftime('%s','now') -36000)) as c14,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -35999) and (strftime('%s','now') -32400)) as c15,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -31399) and (strftime('%s','now') -28800)) as c16,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -28799) and (strftime('%s','now') -25200)) as c17,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -25199) and (strftime('%s','now') -21600)) as c18,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -21599) and (strftime('%s','now') -18000)) as c19,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -17999) and (strftime('%s','now') -14400)) as c20,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -14399) and (strftime('%s','now') -10800)) as c21,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -10799) and (strftime('%s','now') -7200)) as c22,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -7199) and (strftime('%s','now') -3600)) as c23,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -3599) and (strftime('%s','now') -0)) as c24
		FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -86399) and (strftime('%s','now') -0);
		";
	}
	if ($t eq "week") {
		$twidth = '188';
		$timestring = "7 days";
		$title = "Count+distribution+of+$handle+in+channel+$ch+in+the+last+7+days";
		$skala = "6,5,4,3,2,1,0";
		$sql = "
		SELECT count(*) as total,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -604799) and (strftime('%s','now') -518400)) as c1,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -518399) and (strftime('%s','now') -432000)) as c2,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -431999) and (strftime('%s','now') -345600)) as c3,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -345599) and (strftime('%s','now') -259200)) as c4,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -259199) and (strftime('%s','now') -172800)) as c5,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -172799) and (strftime('%s','now') -86400)) as c6,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -86399) and (strftime('%s','now') -0)) as c7
		FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -604799) and (strftime('%s','now') -0);
		";
	}
	if ($t eq "month") {
		$twidth = '740';
		$timestring = "30 days";
		$title = "Count+distribution+of+$handle+in+channel+$ch+in+the+last+7+days";
		$skala = "29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0";
		$sql = "
		SELECT count(*) as total,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2591999) and (strftime('%s','now') -2505600)) as c1,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2505599) and (strftime('%s','now') -2419200)) as c2,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2419199) and (strftime('%s','now') -2332800)) as c3,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2332799) and (strftime('%s','now') -2246400)) as c4,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2246399) and (strftime('%s','now') -2160000)) as c5,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2159999) and (strftime('%s','now') -2073600)) as c6,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2073599) and (strftime('%s','now') -1987200)) as c7,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1987199) and (strftime('%s','now') -1900800)) as c8,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1900799) and (strftime('%s','now') -1814400)) as c9,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1814399) and (strftime('%s','now') -1728000)) as c10,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1727999) and (strftime('%s','now') -1641600)) as c11,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1641599) and (strftime('%s','now') -1555200)) as c12,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1555199) and (strftime('%s','now') -1468800)) as c13,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1468799) and (strftime('%s','now') -1382400)) as c14,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1382399) and (strftime('%s','now') -1296000)) as c15,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1295999) and (strftime('%s','now') -1209600)) as c16,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1209599) and (strftime('%s','now') -1123200)) as c17,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1123199) and (strftime('%s','now') -1036800)) as c18,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -1036799) and (strftime('%s','now') -950400)) as c19,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -950399) and (strftime('%s','now') -864000)) as c20,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -863999) and (strftime('%s','now') -777600)) as c21,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -777599) and (strftime('%s','now') -691200)) as c22,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -691199) and (strftime('%s','now') -604800)) as c23,	
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -604799) and (strftime('%s','now') -518400)) as c24,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -518399) and (strftime('%s','now') -432000)) as c25,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -431999) and (strftime('%s','now') -345600)) as c26,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -345599) and (strftime('%s','now') -259200)) as c27,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -259199) and (strftime('%s','now') -172800)) as c28,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -172799) and (strftime('%s','now') -86400)) as c29,
		(SELECT COUNT(*) FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -86399) and (strftime('%s','now') -0)) as c30
		FROM channels WHERE channel='$ch' and handle='$handle' and timestamp BETWEEN (strftime('%s','now') -2591999) and (strftime('%s','now') -0);
		";
	}

	my $resstring = qx(sqlite3 $dbfile "$sql");
	chomp($resstring);
	my @zahlen = split(/\|/, $resstring);
	my $total = shift(@zahlen);
	my $max = 0;
	foreach (@zahlen) {
		$valstring .= "$_,";
		$max = $_ if $_ > $max;
	}
	chop $valstring;
	template 'channel_handle', {
		skala => $skala,
		timestring => $timestring,
		valstring => $valstring,
		icchandle => $handle,
		chstring => $chstring,
		twidth => $twidth,
	};
};

sub calcpoolratings {
    my $pool = shift;
    my $last;
    
	open(DAT, "/root/www/chartbot/ratingcharts/current_finger_of_PerlHackr.txt");
	my @z = <DAT>;
	close(DAT);
	
	foreach my $r (@z) {
		if ($r =~ m/^$pool-minute/) {
			my ($d1, $lastr) = split(/ +/, $r);
			$last = $lastr;
		}
	}
    
	open(DAT, "/root/www/chartbot/ratingcharts/$pool-minute.txt");
	my @fm = <DAT>;
	close(DAT);
	
	@fm = reverse @fm;
	my $fm = "[";
	
	for (0..18) {
		my $i = ($_ - 18) * - 1;
		my $last = $fm[$i];
		my ($d1, $rating, $d2) = split(/;/, $last);
		$fm .= $rating . ",";
	}
	$fm .= "$last]";
    
    return $fm;
}

true;
