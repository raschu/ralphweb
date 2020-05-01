package ralph40;

use Dancer ':syntax';
use List::Util qw/shuffle/;
use Chess::Elo qw(:all);
use POSIX;
our $VERSION = '0.1';

my $sqlitebin = config->{sqlitebin};
my $thumbs = config->{iccifthumbs};
my $workdir = config->{maindir};
my $db = config->{iccifdb};

#----------------------------------------
get '/icc_interfaces/compare' => sub {	
		my $oldfirst = session 'first';
		my $oldsecond = session 'second';
		
		my $oldratingfirst = qx($sqlitebin $workdir/$db "select rating from interfaceranking where id = '$oldfirst';");
		my $oldratingsecond = qx($sqlitebin $workdir/$db "select rating from interfaceranking where id = '$oldsecond';");
		chomp($oldratingfirst, $oldratingsecond);
		$oldratingfirst -= 1600;
		$oldratingsecond -= 1600;

		my $oldcntfirst = qx($sqlitebin $workdir/$db "select ratingcnt from interfaceranking where id = '$oldfirst';");
		#say "$sqlitebin $workdir/$db \"select ratingcnt from interfaceranking where id = '$first';\"";
		my $oldcntsecond = qx($sqlitebin $workdir/$db "select ratingcnt from interfaceranking where id = '$oldsecond';");
		chomp($oldcntfirst, $oldcntsecond);
		
		my $cntrecs = qx($sqlitebin $workdir/$db "select count(*) from interfaceranking;");
		chomp($cntrecs);
		my $limit = $cntrecs - 2;
		my @pool = qx($sqlitebin $workdir/$db "select id from interfaceranking ORDER BY ratingcnt LIMIT 0, $limit;");
		@pool = shuffle(@pool);
		my $cntpool = @pool;
		#say "cntpool $cntpool";
		#for my $id (@pool) {
		#	chomp($id);
		#	say $id;
		#}
		my $first = $pool[0];
		#my $second = $pool[1];

		my @pool2 = qx($sqlitebin $workdir/$db "select id from interfaceranking ORDER BY ratingcnt LIMIT 5;");
		@pool2 = shuffle(@pool2);
		my $second = $pool2[0];

		chomp($first, $second);

		if ($first eq $second) {
			redirect '/icc_interfaces/compare';
		}
		
		session first => "$first";
		session second => "$second";
		
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
	my $allcnt = qx($sqlitebin $workdir/$db "select count(*) from interfaceranking");
	chomp($allcnt);
	
	my $ix = params->{ix};
	my @iccdata = qx($sqlitebin $workdir/$db "select * from interfaceranking order by rating DESC Limit $ix, 10");
	
	my $json = '{}';
	my $data = from_json $json;
	
	my $cnt = $ix;
	for my $r (@iccdata) {
		$cnt++;

		chomp($r);
		my ($id, $ratingcnt, $rating) = split(/\|/, $r);
		my $index = sprintf("%02d", $cnt);
		$rating -= 1600;
		$data->{$index} = {
			id => $id,
			cnt => $cnt,
			ratingcnt => $ratingcnt,
			rating => $rating,
			allcnt => $allcnt
		};
	}
	
	
	
	template 'icc_interfaces_ranking', {
		data => $data,
		};
};
#----------------------------------------
get '/icc_interfaces/result/:winner/:loser' => sub {
	my $winner = params->{winner};
	my $loser = params->{loser};
	
	my $ratingfirst = qx($sqlitebin $workdir/$db "select rating from interfaceranking where id = '$winner';");
	my $ratingsecond = qx($sqlitebin $workdir/$db "select rating from interfaceranking where id = '$loser';");
	chomp($ratingfirst, $ratingsecond);

	my $cntfirst = qx($sqlitebin $workdir/$db "select ratingcnt from interfaceranking where id = '$winner';");
	#say "$sqlitebin $workdir/$db \"select ratingcnt from interfaceranking where id = '$first';\"";
	my $cntsecond = qx($sqlitebin $workdir/$db "select ratingcnt from interfaceranking where id = '$loser';");
	chomp($cntfirst, $cntsecond);
	
	$cntfirst++;
	$cntsecond++;
	
	my @new_elo;
	@new_elo = elo($ratingfirst, 1, $ratingsecond);
	my $newelo0 = ceil($new_elo[0]);
	my $newelo1 = ceil($new_elo[1]);
	
	#debug "new elo $winner: $new_elo[0]\n";
	#debug "new elo $loser: $new_elo[1]\n";
	
	open(DB, "|$sqlitebin $workdir/$db");
	print DB "UPDATE interfaceranking set rating = '$newelo0', ratingcnt = '$cntfirst' where id = '$winner';";
	print DB "UPDATE interfaceranking set rating = '$newelo1', ratingcnt = '$cntsecond' where id = '$loser';";
	close(DB);
	
	
	redirect '/icc_interfaces/compare';
};

true;
