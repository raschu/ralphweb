package ralph40;

use Dancer ':syntax';
use List::Util qw/shuffle/;
use Chess::Elo qw(:all);
use POSIX;
our $VERSION = '0.1';

my $thumbs = config->{iccifthumbs};
my $workdir = config->{maindir};


#----------------------------------------
get '/icc_interfaces/compare' => sub {
	    #damit Dancer als Daemon gestartet werden kann, muss der $dbh Handle in der Sub aufgerufen werden, weil der $dbh beim Fork verloren geht
		#my $dbh = DBI->connect('dbi:Pg:dbname=ralph;host=localhost','rwuser','rwuser',{AutoCommit=>1,RaiseError=>1,PrintError=>0});
        my $dbh = DBI->connect("dbi:SQLite:dbname=/root/www/ralphweb/db/icc/ICC_interfaces.db","","");
		my $oldfirst = session 'first';
		my $oldsecond = session 'second';
		
		
		my $oldratingfirst = $dbh->selectrow_array("select rating from interfaceranking where id = '$oldfirst';");
		my $oldratingsecond = $dbh->selectrow_array("select rating from interfaceranking where id = '$oldsecond';");

		$oldratingfirst -= 1600;
		$oldratingsecond -= 1600;

		my $oldcntfirst = $dbh->selectrow_array("select ratingcnt from interfaceranking where id = '$oldfirst';");
		my $oldcntsecond = $dbh->selectrow_array("select ratingcnt from interfaceranking where id = '$oldsecond';");

		my $cntrecs = $dbh->selectrow_array("select count(*) from interfaceranking;");

		my $limit = $cntrecs - 2;
		my $limit2 = $limit - 3;
		
		my @pool = $dbh->selectrow_array("select id from interfaceranking ORDER BY ratingcnt LIMIT $limit OFFSET $limit2;");
		@pool = shuffle(@pool);
		my $cntpool = @pool;
		my $first = $pool[0];

		my @pool2 = $dbh->selectrow_array("select id from interfaceranking ORDER BY ratingcnt LIMIT 5;");
		@pool2 = shuffle(@pool2);
		my $second = $pool2[0];
		
		chomp($first, $second);

		if ($first eq $second) {
			redirect '/icc_interfaces/compare';
		}
		
		session first => "$first";
		session second => "$second";
		
		$dbh->disconnect;
		
		template 'icc_interfaces_compare', {
			first => $first,
			second => $second,
			oldfirst => $oldfirst,
			oldsecond => $oldsecond,
			oldratingfirst => $oldratingfirst,
			oldratingsecond => $oldratingsecond,
			oldcntfirst => $oldcntfirst,
			oldcntsecond => $oldcntsecond,
			};
		
};
#----------------------------------------
get '/icc_interfaces/ranking/:ix' => sub {
	#damit Dancer als Daemon gestartet werden kann, muss der $dbh Handle in der Sub aufgerufen werden, weil der $dbh beim Fork verloren geht
	#my $dbh = DBI->connect('dbi:Pg:dbname=ralph;host=localhost','rwuser','rwuser',{AutoCommit=>1,RaiseError=>1,PrintError=>0});
    my $dbh = DBI->connect("dbi:SQLite:dbname=/root/www/ralphweb/db/icc/ICC_interfaces.db","","");
	my $allcnt = $dbh->selectrow_array("select count(*) from interfaceranking");
	chomp($allcnt);
	
	my $ix = params->{ix};
	my $sth = $dbh->prepare("select id, ratingcnt, rating from interfaceranking order by rating DESC Limit 10 OFFSET $ix");
	$sth->execute;
	
	my $json = '{}';
	my $data = from_json $json;
	
	my $cnt = $ix;
	while (my @row = $sth->fetchrow_array) {
		$cnt++;

		my $id        = $row[0];
		my $ratingcnt = $row[1];
		my $rating    = $row[2];
		my $index     = sprintf("%02d", $cnt);
		$rating -= 1600;
		$data->{$index} = {
			id => $id,
			cnt => $cnt,
			ratingcnt => $ratingcnt,
			rating => $rating,
			allcnt => $allcnt
		};
	}
	
	$dbh->disconnect;
	
	template 'icc_interfaces_ranking', {
		data => $data,
		};
};
#----------------------------------------
get '/icc_interfaces/result/:winner/:loser' => sub {
	
	#damit Dancer als Daemon gestartet werden kann, muss der $dbh Handle in der Sub aufgerufen werden, weil der $dbh beim Fork verloren geht
	#my $dbh = DBI->connect('dbi:Pg:dbname=ralph;host=localhost','rwuser','rwuser',{AutoCommit=>1,RaiseError=>1,PrintError=>0});
    my $dbh = DBI->connect("dbi:SQLite:dbname=/root/www/ralphweb/db/icc/ICC_interfaces.db","","");
	my $winner = params->{winner};
	my $loser = params->{loser};
	
	my $ratingfirst = $dbh->selectrow_array("select rating from interfaceranking where id = '$winner';");
	my $ratingsecond = $dbh->selectrow_array("select rating from interfaceranking where id = '$loser';");
	chomp($ratingfirst, $ratingsecond);

	my $cntfirst = $dbh->selectrow_array("select ratingcnt from interfaceranking where id = '$winner';");
	my $cntsecond = $dbh->selectrow_array("select ratingcnt from interfaceranking where id = '$loser';");
	chomp($cntfirst, $cntsecond);
	
	$cntfirst++;
	$cntsecond++;
	
	my @new_elo;
	@new_elo = elo($ratingfirst, 1, $ratingsecond);
	my $newelo0 = ceil($new_elo[0]);
	my $newelo1 = ceil($new_elo[1]);
	
	
	$dbh->do("UPDATE interfaceranking set rating = '$newelo0', ratingcnt = '$cntfirst' where id = '$winner';");
	$dbh->do("UPDATE interfaceranking set rating = '$newelo1', ratingcnt = '$cntsecond' where id = '$loser';");
	$dbh->disconnect;
	
	redirect '/icc_interfaces/compare';
};

true;
