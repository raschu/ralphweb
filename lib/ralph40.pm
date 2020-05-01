package ralph40;

use Dancer ':syntax';
our $VERSION = '0.1';

get '/wird40' => sub {
		#set layout => 'ralph40';
		#template 'ralph40_main';
		template 'ralph40_main', {}, { layout => 'ralph40' };
		#set layout => 'main';
};

post '/ralph40anmeldung' => sub { #Dieser Code kann nach dem Geburtstag wieder deaktiviert werden
	my $vorname = params->{vona123};
	my $nachname = params->{nana123};
	my $teilnahme = params->{tn123};
	my $anzahl = params->{ap123};
	my $comment = params->{c123};
	my $now = time();
	my $spruch = "";
	
	unless ($teilnahme eq "nein") {
		$spruch = "$vorname, vielen Dank für die Anmeldung. Ich freue mich.<br>Gruss und bis bald, Ralph";
	} else {
		$spruch = "Oh schade $vorname, Du kannst nicht teilnehmen.<br>Ich hoffe wir sehen uns trotzdem bald mal wieder. Gruss, Ralph";
	}

	
	$comment =~ s/\n/<br>/g;
	
	

	#open DAT CSV DATA!!!!!!!!!!!!
	open(DAT, ">>/root/ralph40.csv");
	print DAT "$now;$vorname;$nachname;$teilnahme;$anzahl;$comment\n";
	close(DAT);
		
	system("echo \"siehe /root/ralph40.csv\" \| mail -s \"Neue Anmeldung 40. Geburtstag\" ralph.schuler\@gmail.com");
	
	template 'ralph40_confirm', {vorname => $vorname, nachname => $nachname, teilnahme => $teilnahme,spruch => $spruch, anzahl => $anzahl, comment => $comment}, { layout => 'ralph40' };
};

true;
