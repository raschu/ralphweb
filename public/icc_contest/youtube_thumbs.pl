use strict;
use warnings;
use Data::Dumper;
use LWP::Simple;

my $youtubechannel = 'schura';
my $content;
my @nodownload = qw(
D1O2LblOVwY
A-S4bIFZu28
Aw77iflyhPY
EiQIfGgCJHs
F_bKkbomwjQ
LkQE4VKktns
c9sV7ybjLsQ
cKes4UFJ2UQ
cw2PvzOvXWM
eM-p08LIxrY
hBGICgjbKhg
jS5Tc263M8g
nPTWoNym_yY
s21GfmOX8xY
t-PCp5GsBQw
zEjmjCBbgt4
wDscV8J7uJU
DFfzyV2TIEo
5g5E4YPiwJA
CCsh4UqHIlI
e1da3SUvKpg
jy03GqPpj4k
KRi8T3bCkzM
oKs9foErM9Q
refiIjgmbfI
A-v0txLyPjU
1bmQ2aHWuVw
);

mkdir("utubethumbs") if (!-e "utubethumbs");
mkdir("utubethumbs/default") if (!-e "utubethumbs/default");
mkdir("utubethumbs/hqdefault") if (!-e "utubethumbs/hqdefault");
unlink "./utubethumbs/ytschura.txt" if (-e "./utubethumgs/ytschura.txt");

open(DAT, ">>./utubethumbs/ytschura.txt");
$content = get("https://gdata.youtube.com/feeds/api/users/$youtubechannel/uploads?start-index=1&max-results=50");
print DAT "$content";

$content = get("https://gdata.youtube.com/feeds/api/users/$youtubechannel/uploads?start-index=51&max-results=50");
print DAT "$content";

$content = get("https://gdata.youtube.com/feeds/api/users/$youtubechannel/uploads?start-index=101&max-results=50");
print DAT "$content";

$content = get("https://gdata.youtube.com/feeds/api/users/$youtubechannel/uploads?start-index=151&max-results=50");
print DAT "$content";

$content = get("https://gdata.youtube.com/feeds/api/users/$youtubechannel/uploads?start-index=201&max-results=50");
print DAT "$content";

close(DAT);

open(DAT, "./utubethumbs/ytschura.txt");

my @allmatches;
my %allmatches;

while(my $w = <DAT>) {
    my @matches = $w =~ m/watch\?v=([\w-]{11})/g;
    my $count = scalar(@matches);
    #print "$count\t$w\n";
    
    foreach my $match (@matches) {
        push(@allmatches, $match);
        $allmatches{$match} = 1;
    }
}
close(DAT);

print Dumper(\%allmatches);

foreach my $key (keys(%allmatches)) {
    next if (grep( /^$key/, @nodownload ) );
    if (!-e "./utubethumbs/default/$key.jpg") {
        my $rc = getstore("http://img.youtube.com/vi/$key/default.jpg", "./utubethumbs/default/$key.jpg");
        print "downloading http://img.youtube.com/vi/$key/default.jpg ...\n";
        my $rc2 = getstore("http://img.youtube.com/vi/$key/hqdefault.jpg", "./utubethumbs/hqdefault/$key.jpg");
        print "downloading http://img.youtube.com/vi/$key/hqdefault.jpg ...\n";
        
        open(DB, "|/usr/bin/sqlite3 /root/ralphweb/db/icc/ICC_interfaces.db") or die $!;
        print DB "INSERT into interfaceranking ('ID', 'rating', 'ratingcnt') VALUES ('$key','1600','0');";
        close(DB);
        
    } else {
        #print "$key is already downloaded...\n";
    }
}
unlink "./utubethumbs/ytschura.txt";
