package cli;
use Dancer ':syntax';
use POSIX;
use Text::Table;

our $VERSION = '0.1';

#############################################################################################
get '/cli/:edition/:cat/:sid' => sub {
	my $edition = params->{edition};
	my $scdb;
	$scdb = "/root/www/ralphweb/db/sc/sc16.sqlite";		
	my $cat = params->{cat};
	my $sid = params->{sid};
	my $ktn = params->{ktn};
	
	my $tb = Text::Table->new(
	    "---", "---------------", "-----", "---", "--", "---------", "------", "------"
	);
	
	my %ktnbez = (
		'TC'=>'Team CH','LA'=>'Ladies','OL'=>'Oldies','MA'=>'Markierte','FB'=>'Facebook','CH'=>'Schweiz','ZH'=>'Zürich','BE'=>'Bern','LU'=>'Luzern','UR'=>'Uri','SZ'=>'Schwyz','OW'=>'Obwalden','NW'=>'Nidwalden','GL'=>'Glarus','ZG'=>'Zug','FR'=>'Freiburg','SO'=>'Solothurn','BS'=>'Basel-Stadt','BL'=>'Basel-Landschaft','SH'=>'Schaffhausen','AR'=>'Appenzell Ausserhoden','AI'=>'Appenzell Innerhoden','SG'=>'St. Gallen','GR'=>'Graubünden','AG'=>'Aargau','TG'=>'Thurgau','TI'=>'Tessin','VD'=>'Waadt','VS'=>'Wallis','NE'=>'Neuenburg','GE'=>'Genf','JU'=>'Jura'
	);
	my %catbez = (
		'beaq'=>'Beaver Creek Quali','bear'=>'Beaver Creek Rennen','vadq'=>'Val d\'Isère Quali','vadr'=>'Val d\'Isère Rennen','groq'=>'Gröden Quali','gror'=>'Gröden Rennen','borq'=>'Bormio Quali','borr'=>'Bormio Rennen','wenq'=>'Wengen Quali','wenr'=>'Wengen Rennen','kitq'=>'Kitzbühel Quali','kitr'=>'Kitzbühel Rennen','garq'=>'Garmisch Quali','garr'=>'Garmisch Rennen','schq'=>'Schladming Quali','schr'=>'Schladming Rennen','socq'=>'Sochi Quali','socr'=>'Sochi Rennen'
	);
	
	open(DAT, "/root/www/ralphweb/db/sc/siddata/$sid.txt");
	my @nickscmd = <DAT>;
	close(DAT);
		
	my $sortdir = "ASC";
	my $sql;
	my $bestzeit;
	my $avgzeit;
	my $nickssql; 

	my $cntcmd;
	foreach my $n (@nickscmd) {
		chomp $n;
		if (++$cntcmd == scalar(@nickscmd)) {
			$nickssql .= " (nick = '$n' and $cat > 0)" if $n gt '';
		} else {
			$nickssql .= " (nick = '$n' and $cat > 0) or" if $n gt '';
		}
	}
	$sql = "SELECT nick, kanton, $cat, sex, birthday, facebookid FROM scranking where $nickssql order by $cat $sortdir limit 0, 50";
	$bestzeit = "SELECT $cat FROM scranking  where $nickssql order by $cat limit 0, 1";
	$avgzeit = "SELECT AVG(SUBSTR(\"$cat\", 1, LENGTH(\"$cat\") - 5) * 60000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 4, 2) * 1000 + SUBSTR(\"$cat\", LENGTH(\"$cat\") - 2, 3)) FROM scranking where $nickssql;";

	my $bzres = qx(sqlite3 $scdb "$bestzeit");
	chomp($bzres);
	my $bestinsec = calcsec($bzres);
	my $avg = qx(sqlite3 $scdb "$avgzeit");
	chomp($avg);
	my $avginsec = floor($avg);
	
	my @scdata = qx(sqlite3 $scdb "$sql");
	my $cnt = 0;
	my $rank = 0;
	for my $r (@scdata) {
		
		$cnt++;
		chomp($r);
		my ($nick, $ktn, $time, $sex, $birthday, $facebookid) = split(/\|/, $r);
		my $t1 = substr($time, 0, 1);
		my $t2 = substr($time, 1, 2);
		my $t3 = substr($time, 3, 3);
		my $times = $t1. ":" . $t2. "." . $t3;
		
		my $timeinsec = calcsec($time);		
		my $diff = sprintf ("%.3f" ,($timeinsec  - $bestinsec) / 1000);
		my $diffavg = sprintf ("%.3f" ,($timeinsec  - $avginsec) / 1000);
		
		my $byear = substr($birthday, 0, 4);
				
		if ($diffavg <= 0) {
			$diffavg = "\033[32m$diffavg\033[0m";
		} else {
			$diffavg = "\033[31m$diffavg\033[0m";
		}
		
		$tb->load(
		    [ $cnt, $nick, $byear, $ktn, $sex, $times, "$diff", "\033[31m$diffavg\033[0m" ],
		);
	}
	
	my $timestring = strftime "%A,%e. %B %Y %H:%M", localtime;
		
	template "sc/marklist", {tb => $tb, catbez => $catbez{$cat}, ts => $timestring}, {layout => 0};
};

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
