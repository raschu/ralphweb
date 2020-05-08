package sc;
use Dancer ':syntax';
use List::Util qw(shuffle);

our $VERSION = '0.1';

#############################################################################################
get '/hoefli' => sub {
	
	chdir('/root/www/ralphweb/public/images/hoefli');
	my @images;
	for my $img (<*.jpg>) {
		next if $img =~ m/20130428_131131/ or $img =~ m/20140601_173728/ or $img =~ m/20140601_171350/;
		push(@images, $img);
	}
	
	my @randimg = shuffle(@images);
	my @sevenimg;
	
	for (1..6) {
		push(@sevenimg, $randimg[$_]);
	}

	my $imgdata;
	
	for my $i (@sevenimg) {
		my ($date, $dummy) = split(/_/, $i);
		$imgdata .= "<a href=\"/hoefli/$date\"><img width=\"200\" src=\"/images/hoefli/$i\" alt=\"\"></a><br><br>";
	}
	template 'hoefli/hoefli',{'imgdata' => $imgdata,};
};
#############################################################################################
get '/hoefli/:date' => sub {
	my $date = params->{date};
	template "hoefli/$date";
};

true;
