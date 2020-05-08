package tools;
use Dancer ':syntax';
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;

post '/pgn2lichess' => sub {
	my $file = request->upload('pgnfile');
	$file->copy_to('/root/www/ralphweb/upload/');  # or whatever you need
	my $tmpfile = $file->tempname;
	$tmpfile =~ s/\/tmp\///;
	open(DAT, "/root/www/ralphweb/upload/$tmpfile");
	my @z = <DAT>;
	close(DAT);
	my $pgn = join("", @z);
	my $server_endpoint = "https://de.lichess.org/import";
	my $req = HTTP::Request->new(POST => $server_endpoint);
	$req->header('content-type' => 'application/x-www-form-urlencoded');
	my $post_data = "pgn=$pgn&analyse=on";
	$req->content($post_data);
	my $res = $ua->request($req);
	my $url = "http://lichess.org" . $res->header('Location');
	unlink("/root/www/ralphweb/upload/$tmpfile");
	redirect $url;
};

true;
