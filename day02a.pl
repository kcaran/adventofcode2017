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

sub calc_checksum {
  my ($spreadsheet) = @_;
  my $sum;

  for my $row (@{ $spreadsheet }) {
    my $max = max( @{ $row } );
    my $min = min( @{ $row } );
    $sum += ($max - $min);
   }

  return $sum;
 }

my $input_file = $ARGV[0] || 'input02.txt';

my $spreadsheet = read_spreadsheet( $input_file );

print "The checksum is ", calc_checksum( $spreadsheet ), "\n";

exit;
