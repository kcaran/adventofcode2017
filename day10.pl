#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
# $ perl day09.pl $(cat input09.txt)
#
use strict;
use warnings;

use Path::Tiny;

{ package Rope;

  sub result {
    my ($self) = @_;

    return $self->{ knots }[0] * $self->{ knots }[1];
   }

  sub tie {
    my ($self, $len) = @_;

    my @slice;

    # Test if we need to wrap around
    if (($self->{ pos } + $len - 1) < $self->{ num_knots }) {
      my $end = $self->{ pos } + $len - 1;

      @{ $self->{ knots } }[ $self->{ pos } .. $end ]
		= reverse @{ $self->{ knots } }[ $self->{ pos } .. $end ];
     }
    else {
      my $tail_len = $self->{ num_knots } - $self->{ pos };
      my @slice = @{ $self->{ knots } }[ $self->{ pos } .. $self->{ num_knots } - 1 ];
      push @slice, @{ $self->{ knots } }[ 0 .. $len - $tail_len - 1 ];
      @slice = reverse @slice;
      @{ $self->{ knots } }[ $self->{ pos } .. $self->{ num_knots } - 1 ]
			= @slice[ 0 .. $tail_len - 1 ];
      @{ $self->{ knots } }[ 0 .. $len - $tail_len - 1 ]
			= @slice[ $tail_len .. $len - 1 ];
     }

    $self->{ pos } =
		($self->{ pos } + $len + $self->{ skip }) % $self->{ num_knots };
    $self->{ skip }++;

    return $self;
   }

  sub parse_lengths {
    my ($self, $lengths) = @_;
    for my $len (@{ $lengths }) {
      $self->tie( $len );
     }

    return $self;
  }

  sub new {
    my ($class, $knots, $lengths) = @_;
    my $self = {
		num_knots => $knots,
        knots => [],
        pos => 0,
        skip => 0,
    };
    bless $self, $class;

    for (my $i = 0; $i < $self->{ num_knots }; $i++) {
      push @{ $self->{ knots } }, $i;
     }
    
    return $self;
  }
}

my ($knots, $input_file) = @ARGV;

my $lengths = [ split /\s*,\s*/, path( $input_file )->slurp_utf8() ];

my $rope = Rope->new( $knots );

$rope->parse_lengths( $lengths );

print "Multiplying the first two numbers is ", $rope->result(), "\n";

exit;
