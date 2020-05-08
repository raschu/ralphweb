package rss;
use Dancer ':syntax';
use Digest::MD5 qw(md5_hex);

get '/rss/sc/16/:nick' => sub {
    my $nick = params->{nick};
    my $hash = qx(sqlite3 /root/www/ralphweb/db/sc/sc16.sqlite "select beaq from scranking where nick='$nick';");
    $hash = md5_hex $hash;
    template 'sc/rss_sc_profile', {nick => $nick, hash => $hash}, { layout => 'rss' };
};

true;
