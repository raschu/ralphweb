package guestbook;

use Dancer ':syntax';
use Encode;
use Webservice::CaptchasDotNet;

our $VERSION = '0.1';
our $db = config->{maindir} . config->{gbdb};

get '/guestbook' => sub {
		
	my $captchas = WebService::CaptchasDotNet->new(
		client   => 'raschu',
		secret   => 'ZjyxW7lJQKGYboqGTtFfrnoRkjLQA93Ksv2Q5RCD',
		letters => 4,

	);
	my $random     = $captchas->random;
	my $image_url  = $captchas->image_url;
	$image_url = $image_url . "&color=2180BC";
	my $sqlstring = "sqlite3 $db \"SELECT * FROM guestbook where verified = 1 order by id desc\"";
	my @gbdata = qx($sqlstring);
	my $json = '{}';
	my $data = from_json $json;
	my $cnt = 0;
	for my $r (@gbdata) {
		$cnt++;
		chomp($r);
		my ($updatetime, $id, $name, $homepage, $comment) = split(/\|/, $r);
		$updatetime = localtime($updatetime);

		my $index = sprintf("%04d", $cnt);
		$data->{$index} = {
			id => $id,
			name => $name,
			homepage => $homepage,
			comment => $comment,
			updatetime => $updatetime
		};	
	}	
	template 'guestbook', {data => $data, random => $random, image_url => $image_url};
};

post '/gbp' => sub {
	my $captchas = WebService::CaptchasDotNet->new(
                                 client   => 'raschu',
                                 secret   => 'ZjyxW7lJQKGYboqGTtFfrnoRkjLQA93Ksv2Q5RCD',
                                 letters => 4
                                 );
	
	my $password = params->{password};
	my $random = params->{random};
	
	my $homepage = params->{h45999};
	my $name = params->{n88999};
	my $comment = params->{c73999};
	my $now = time();
	my $ip = $ENV{'HTTP_X_FORWARDED_FOR'};
	
	$comment =~ s/\n/<br>/g;
	$homepage = encode("iso-8859-1", $homepage);
	$name = encode("iso-8859-1", $name);
	$comment = encode("iso-8859-1", $comment);
	$comment =~ s/\'/''/g;
	#my $comtolog = $comment;
	#$comtolog = substr($comtolog, 0, 40);
	#open(LOG, ">>/root/gblog_TEMP.txt");
	#print LOG "$now||$random||$password||$name||$homepage||$comtolog;\n###################################################################\n";
	#close(LOG);
		
	if (not $captchas->validate ($random)) {
		return 'Every CAPTCHA can only be used once. The current CAPTCHA has already been used. Try again.';
	}	
	
	if (not $captchas->verify ($password)) {
		return 'You entered the wrong security code. Please use back button and reload. <br><br>Falscher Sicherheits Code eingegeben. Bitte Zurück Button klicken.';
	}
	system("sqlite3 $db \"Insert into guestbook (homepage, name, comment, updatetime) VALUES ('$homepage','$name','$comment','$now')\"");
	system("echo \"homepage: $homepage\nname: $name\ncomment: $comment\nnow: $now\" \| mail -s \"new guestbook entry on ralphschuler.ch from $ip\" ralph.schuler\@gmail.com");
	redirect '/guestbook';
};

true;
