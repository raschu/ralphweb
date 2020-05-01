package tools;
use Dancer ':syntax';

get '/tools' => sub {
    template 'tools', {found => 0};
};

post '/dws' => sub {
	my $dwsurl = params->{dwsurl};
	#my $data = "bla";
	my $data = qx(curl --head $dwsurl);	
	debug $dwsurl;
    template 'tools', {data => $data, found => 1};
};

true;
