use strict;
use warnings;
use Data::Dumper;

my @abet = qw(a b c d e f g h i j);


print "4231062 " . modc(4231062) . "\n";
print "4231063 " . modc(4231063) . "\n";
print "4231064 " . modc(4231064) . "\n";
print "4231065 " . modc(4231065) . "\n";

print "4191074 " . modc(4191074) . "\n";
print "4191075 " . modc(4191075) . "\n";
print "4191076 " . modc(4191076) . "\n";
print "4191077 " . modc(4191077) . "\n";

print "4221116 " . modc(4221116) . "\n";
print "4221117 " . modc(4221117) . "\n";
print "4221118 " . modc(4221118) . "\n";
print "4221119 " . modc(4221119) . "\n";

print "4181122 " . modc(4181122) . "\n";
print "4181123 " . modc(4181123) . "\n";
print "4181124 " . modc(4181124) . "\n";
print "4181125 " . modc(4181125) . "\n";

print "4201128 " . modc(4201128) . "\n";
print "4201129 " . modc(4201129) . "\n";
print "4201130 " . modc(4201130) . "\n";
print "4201131 " . modc(4201131) . "\n";

print "4211134 " . modc(4211134) . "\n";
print "4211135 " . modc(4211135) . "\n";
print "4211136 " . modc(4211136) . "\n";
print "4211137 " . modc(4211137) . "\n";

print "4261170 " . modc(4261170) . "\n";
print "4261171 " . modc(4261171) . "\n";
print "4261172 " . modc(4261172) . "\n";
print "4261173 " . modc(4261173) . "\n";

print "4251176 " . modc(4251176) . "\n";
print "4251177 " . modc(4251177) . "\n";
print "4251178 " . modc(4251178) . "\n";
print "4251179 " . modc(4251179) . "\n";

print "4241182 " . modc(4241182) . "\n";
print "4241183 " . modc(4241183) . "\n";
print "4241184 " . modc(4241184) . "\n";
print "4241185 " . modc(4241185) . "\n";

print "4401140 " . modc(4401140) . "\n";
print "4401141 " . modc(4401141) . "\n";
print "4401142 " . modc(4401142) . "\n";
print "4401143 " . modc(4401143) . "\n";

sub modc {
	my $z = shift;
	my $new;
	
	my @zi = split(//, $z);
	
	foreach my $e (@zi) {
		$new .= $abet[$e];
	}
	return $new;
}
