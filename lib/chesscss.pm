package chesscss;

use Dancer ':syntax';

get '/chesscss' => sub {
	open(DAT, "/root/www/ralphweb/public/chesscss.txt");
	my $iframe = <DAT>;
	close(DAT);
	
	"
	<html>
	<head>
	<title>Chess Match Ralph vs. TEAQ</title>
	</head>
	<body bgcolor='#ffffff'>
	" . $iframe .
	"
	<p><pre>
	<b>hotkeys:</b>
	j, k	previous move, next move
	h, l	start of game, end of game
	f	flip board
	a, 0	start autoplay, stop autoplay
	1, 2, 3 ...	change autoplay speed delay
	</pre></p>
	</body>
	</html>
	"	
};

get '/cssinput' => sub {
	open (DAT, "/root/www/ralphweb/public/pgn4web-2.81/template.txt");
	my $link = <DAT>;
	close(DAT);
	
	"<form action='/pgnstring' method='post'>
						<br/>
						<textarea name='cssinputstring' cols='50' rows='10'></textarea><br/>
						<input class='button' type='submit'>
						</form>
						<a href='$link'>http://ralphschuler.ch/pgn4web-2.81/board-generator.html</a>
						<br><a href='http://ralphschuler.ch/chesscss'>http://ralphschuler.ch/chesscss</a>
						"
};

post '/pgnstring' => sub {
	my $cssinputstring = params->{cssinputstring};
	open(DAT, ">/root/www/ralphweb/public/chesscss.txt");
	print DAT "$cssinputstring";
	close(DAT);
	redirect '/chesscss';
};

true;