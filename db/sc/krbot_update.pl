my $now = $ARGV[0];

use File::Copy;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $workdir = '/root/ralphweb/db/sc';
updatedb();

unlink("$workdir/sc16data.$now.txt");

sub updatedb {
	print "Updating db in $workdir\n";
	open(LOG, "$workdir/sc16data.$now.txt") or die "kann $workdir/sc16data.txt nicht oeffnen";
	my @sqls = <LOG>;
	close(LOG);
	
	copy("$workdir/sc16data.$now.txt", "$workdir/last_krbot_run.txt") or die;
	
	my $updatecnt = @sqls;
	
	my $now = localtime(time);
	open(DAT1, ">>$workdir/krbot_countlog.txt");
	print DAT1 "$now: $updatecnt\n";
	close(DAT1);
	
	print "Making Backup of $workdir/sc16.sqlite\n";
	copy("$workdir/sc16.sqlite", "$workdir/temp/sc16.$hour") or die "kann nicht von $workdir/sc16.sqlite nach $workdir/temp/sc16.$hour kopieren ($!)";
	print "putting a copy of sc16.$hour to Dropbox\n";
	system("/usr/local/bin/dropbox-api sync /root/ralphweb/db/sc/temp/ dropbox:/to_backup_later/sc/ -d");
	
	sleep(20);
	print "Piping $workdir/sc16.sqlite with $updatecnt Records\n";
	open(DAT, "|sqlite3 $workdir/sc16.sqlite") or die "kann DB $workdir/sc16.sqlite nicht oeffnen";
	foreach my $sql (@sqls) {
		#print "PIPE DEBUG: $sql\n";
		print DAT "$sql\n";
	}
	print "Vacuumize $workdir/sc16.sqlite\n";
	print DAT "vacuum;\n";
	close(DAT);
}
