package facebook;

use strict;
use Dancer ':syntax';
use Facebook::Graph;
use Encode;


our $VERSION = '0.1';

get '/scfb/:nick' => sub {
  
  my $nick = params->{nick};
  my $requri = uri_for('/scfb');
   
  unless ($requri eq "http://ralphschuler.ch/scfb") {
    redirect "http://ralphschuler.ch/scfb/$nick"; #facbeook will es so, geht nicht mit z.B. www.ralphschuler.ch
    return;
  }
 
  
  my $fb = Facebook::Graph->new(
    secret      => '937f7957de00e39657ae3208089fe61e',
    app_id      => '103842917201',
    postback    => 'http://ralphschuler.ch/facebook/postback',
 );
    my $uri = $fb->authorize
    ->extend_permissions()
    ->set_display('popup')
    ->uri_as_string;
    
    session scnick => params->{nick};
    redirect $uri;
};

get '/facebook/postback' => sub {
    my $authorization_code = params->{code};
    my $fb                 = Facebook::Graph->new( config->{facebook} );

    $fb->request_access_token($authorization_code);
    my $user = $fb->fetch('me');
    session access_token => $fb->access_token;
    redirect '/fbdata';
};

get '/fbdata' => sub {
  my $fb = Facebook::Graph->new( config->{facebook} );

    $fb->access_token(session->{access_token});

    my $response = $fb->query->find('me')->request;
    my $user     = $response->as_hashref; 
    my $scnick = session 'scnick';
    system("echo \"$scnick ($user->{name}) added his facebook profile http://facebook.com/profile.php?id=$user->{id}\" \| mail -s \"SC Facebook account linked\" sc16\@ralphschuler.ch");
    
    $scnick = encode("iso-8859-1", $scnick);    
    
    my $sql = "
    UPDATE scranking
    SET facebookid = '$user->{id}'
    where nick = '$scnick'
    ";   
    
    system ("sqlite3 /root/ralphweb/db/sc/sc11.sqlite \"$sql\"");
    system ("sqlite3 /root/ralphweb/db/sc/sc12.sqlite \"$sql\"");
	system ("sqlite3 /root/ralphweb/db/sc/sc13.sqlite \"$sql\"");
	system ("sqlite3 /root/ralphweb/db/sc/sc14.sqlite \"$sql\"");
	system ("sqlite3 /root/ralphweb/db/sc/sc15.sqlite \"$sql\"");
	system ("sqlite3 /root/ralphweb/db/sc/sc16.sqlite \"$sql\"");
    redirect '/sc/16';
};

true;
