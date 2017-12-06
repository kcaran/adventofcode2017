#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

sub find_exit
 {
  my ($offsets) = @_;
  my $steps = 0;
  my $index = 0;

  while ($index >= 0 && $index < @{ $offsets }) {
    my $jump = $offsets->[$index];
    $offsets->[$index] += ($jump >= 3 ? -1 : 1);
    $index += $jump;
    $steps++;
   }

  return $steps;
 }

my $input_file = $ARGV[0] || 'input05.txt';

my @offsets = path( $input_file )->lines_utf8();

my $steps = find_exit( \@offsets );

print "The number of steps is $steps\n";
