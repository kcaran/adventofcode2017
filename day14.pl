#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

{ package Grid;

  my $num_hashes = 128;

  sub count_squares {
    my $self = shift;

    my $count = 0;

    for my $row (@{ $self->{ squares } }) {
      $count += scalar grep { $_ } split '', $row;
     }

    return $count;
   }

  sub squares {
    my ($input) = @_;

    my $binary = '';

    for my $char (split '', $input) {
      $binary .= sprintf "%04b", hex( $char );
     }

    return $binary;
   }

  sub region {
    my ($self, $x, $y) = @_;

    return unless ($self->val( $x, $y ) eq '1');

    substr( $self->{ squares }[ $y ], $x, 1 ) = '0';

    $self->region( $x - 1, $y ) if ($x > 0);
    $self->region( $x + 1, $y ) if ($x < 128 - 1);
    $self->region( $x, $y - 1 ) if ($y > 0);
    $self->region( $x, $y + 1 ) if ($y < $num_hashes - 1);
    
    return;
   }

  sub val {
    my ($self, $x, $y) = @_;
    return substr( $self->{ squares }[ $y ], $x, 1 );
   }
 
  sub num_regions {
    my $self = shift;
    my $regions = 0;

    for (my $x = 0; $x < 128; $x++) {
      for (my $y = 0; $y < $num_hashes; $y++) {
        if ($self->val( $x, $y )) {
          $regions++;
          $self->region( $x, $y );
         } 
       }
     }

    return $regions;
   }

  sub new {
    my ($class, $input) = @_;
    my $self = {
    };
    bless $self, $class;

    for (my $i = 0; $i < $num_hashes; $i++) {
      my $hash = `day10b.pl 256 $input-$i`;
      $self->{ squares }[ $i ] = squares( $hash );
     }

    return $self;
   }
}

sub count_squares
 {
  my ($input) = @_;

  my $binary = '';

  for my $char (split '', $input) {
    $binary .= sprintf "%b", hex( $char );
   }

  return scalar grep { $_ } split '', $binary;
 }

my $input = $ARGV[0] || die "Please enter the input";

my $grid = Grid->new( $input );

print "The number of squares used is ", $grid->count_squares, "\n";

print "The number of regions used is ", $grid->num_regions, "\n";

exit;
