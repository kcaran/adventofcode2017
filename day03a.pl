#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub calc_neighbors
 {
 }

sub calc_grid
 {
  my ($val) = @_;

  my ($min_y, $min_x, $max_y, $max_x) = (0, 0, 0, 0);
  my $dir = 'r';

  my $coords = [ 0, 0 ];
  $val--;
  while ($val) {
    if ($dir eq 'r') {
      $coords->[1]++;
      if ($max_x < $coords->[1]) {
        $max_x = $coords->[1];
        $dir = 'u';
       }
     }
    elsif ($dir eq 'u') {
      $coords->[0]++;
      if ($max_y < $coords->[0]) {
        $max_y = $coords->[0];
        $dir = 'l';
       }
     }
    elsif ($dir eq 'l') {
      $coords->[1]--;
      if ($min_x > $coords->[1]) {
        $min_x = $coords->[1];
        $dir = 'd';
       }
     }
    elsif ($dir eq 'd') {
      $coords->[0]--;
      if ($min_y > $coords->[0]) {
        $min_y = $coords->[0];
        $dir = 'r';
       }
     }

    $val--;
   }

  return $coords;
 }

my $val = $ARGV[0];
my $coord = calc_grid( $val );
my $steps = abs( $coord->[0] ) + abs( $coord->[1] );
print "The grid coordinates for $val are ( $coord->[0], $coord->[1] ) which take $steps steps.\n";


