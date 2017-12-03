#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub calc_neighbors
 {
  my ($grid, $coords) = @_;
  my $sum = 0;

  for (my $y = -1; $y <= 1; $y++) {
    for (my $x = -1; $x <= 1; $x++) {
       my $key = grid_key( [ $coords->[0] + $y, $coords->[1] + $x ] );
       $sum += ($grid->{ $key } || 0);
      }
    }

  return $sum;
 }

sub grid_key
 {
  my ($coords) = @_;

  return "( $coords->[0], $coords->[1] )";
 }

sub calc_grid
 {
  my ($min_val) = @_;
  my $grid = {};

  my ($min_y, $min_x, $max_y, $max_x) = (0, 0, 0, 0);
  my $dir = 'r';

  my $coords = [ 0, 0 ];
  my $value = 1;
  $grid->{ grid_key( $coords ) } = 1;
  while ($value < $min_val) {
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

    $value = calc_neighbors( $grid, $coords );
    $grid->{ grid_key( $coords ) } = $value;
   }

  return $value;
 }

my $min_val = $ARGV[0];
my $value = calc_grid( $min_val );
print "The first grid value greater than $min_val is $value\n";


