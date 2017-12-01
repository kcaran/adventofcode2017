#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

sub calc_sum
 {
  my ($input) = @_;
  my $sum = 0;

  my $len = length( $input );
  for (my $i = 0; $i < $len - 1; $i++ ) {
    my $digit = substr( $input, $i, 1 );
    $sum += $digit if ($digit == substr( $input, $i + 1, 1 ));
   }

  # Last digit - check with first digit
  my $last_digit = substr( $input, $len - 1, 1 );
  $sum += $last_digit if ($last_digit == substr( $input, 0, 1 ));

  return $sum;
 }

my $input_file = $ARGV[0] || 'input01a.txt';

my $raw_input = path( $input_file )->slurp_utf8();
chomp $raw_input;

my $sum = calc_sum( $raw_input );
print "The sum is $sum\n";
