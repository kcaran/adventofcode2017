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
  for (my $i = 0; $i < $len; $i++ ) {
    my $digit = substr( $input, $i, 1 );
    my $next = next_digit( $i, $len );
    $sum += $digit if ($digit == substr( $input, $next, 1 ));
   }

  return $sum;
 }

sub next_digit
 {
  my ($digit, $len) = @_;

  return ($digit + $len / 2) % $len;
 }

my $input_file = $ARGV[0] || 'input01a.txt';

my $raw_input = path( $input_file )->slurp_utf8();
chomp $raw_input;

my $sum = calc_sum( $raw_input );
print "The sum is $sum\n";
