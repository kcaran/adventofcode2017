#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use List::Util qw( max min );

sub read_spreadsheet
 {
  my ($input_file) = @_;
  open my $input_fh, '<', $input_file or die $!; 
  my $spreadsheet = [];

  while (<$input_fh>) {
    chomp;
    push @{ $spreadsheet }, [ split( /\s+/, $_ ) ];
   }

  return $spreadsheet;
 }

sub find_factors
 {
  my ($input_row) = @_;

  # Sort row in reverse order
  my @row = sort { $b <=> $a } @{ $input_row };

  for my $val (@row) {
    # Starting from end of row, test if value is a factor
    my $i = @row - 1;
    my $factor = 0;
    do {
      $factor = $row[$i--];
      if (($val / $factor) == int( $val / $factor )) {
        return ($val / $factor);
       }
    } while ($factor <= $val / 2);
   }

  die "Error: We could not find a factor for row ", @{ $input_row };
 }

sub calc_checksum {
  my ($spreadsheet) = @_;
  my $sum;

  for my $row (@{ $spreadsheet }) {
    $sum += find_factors( $row );
   }

  return $sum;
 }

my $input_file = $ARGV[0] || 'input02.txt';

my $spreadsheet = read_spreadsheet( $input_file );

print "The checksum is ", calc_checksum( $spreadsheet ), "\n";

exit;
