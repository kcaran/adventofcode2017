#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub count_squares
 {
  my ($input) = @_;

  my $count = 0;

  for my $char (split '', $input) {
    my $binary = sprintf "%b", hex( $char );
    $count += scalar grep { $_ } split '', $binary;
   }

  return $count;
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
