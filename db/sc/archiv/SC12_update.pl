use File::Copy;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $workdir = '/root/www/ralphweb/db/sc';
updatedb();

sub updatedb {
	print "Updating db in $workdir\n";
	open(LOG, "$workdir/sc12data.txt") or die "kann $workdir/sc12data.txt nicht oeffnen";
	my @sqls = <LOG>;
	close(LOG);
	
	print "Making Backup of $workdir/sc12.sqlite\n";
	copy("$workdir/sc12.sqlite", "$workdir/TEMPbackupDB/sc12.$hour") or die "kann nicht von $workdir/sc12.sqlite nach $workdir/TEMPbackupDB/sc12.$hour kopieren ($!)";
	print "putting a copy of sc12.$hour to Dropbox\n";
	system("/usr/bin/dropbox-api put /root/www/ralphweb/db/sc/TEMPbackupDB/sc12.$hour dropbox:/");
	sleep(60);
	print "Piping $workdir/sc12.sqlite\n";
	open(DAT, "|sqlite3 $workdir/sc12.sqlite") or die "kann DB $workdir/sc12.sqlite nicht oeffnen";
	foreach my $sql (@sqls) {
		#print "PIPE DEBUG: $sql\n";
		print DAT "$sql\n";
	}
	print "Vacuumize $workdir/sc12.sqlite\n";
	print DAT "vacuum;\n";
	close(DAT);
}
