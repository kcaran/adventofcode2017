#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub count_squares
 {
  my ($input) = @_;

  my $binary = '';

  for my $char (split '', $input) {
    $binary .= sprintf "%b", hex( $char );
   }

  return scalar grep { $_ } split '', $binary;
 }

my $num_hashes = 128;

my $input = $ARGV[0] || die "Please enter the input";

my $squares = 0;
for (my $i = 0; $i < $num_hashes; $i++) {
  my $hash = `day10b.pl 256 $input-$i`;
  $squares += count_squares( $hash );
 }

print "The number of squares used is $squares\n";

exit;
