#!/usr/bin/perl

use strict;
use warnings;

use Path::Tiny;

{ package Spinlock;

  sub after_zero {
    my ($self) = @_;

    return $self->{ first_val };
  }

  sub new {
    my ($class, $steps, $values) = @_;
    my $self = {
		buffer_len => 1,
		curr_pos => 0,
        first_val => 0,
    };
    bless $self, $class;

    while ($self->{ buffer_len } <= $values) {
      $self->{ curr_pos } = ($self->{ curr_pos } + $steps) % $self->{ buffer_len };
      $self->{ first_val } = $self->{ buffer_len } if ($self->{ curr_pos } == 0);
      $self->{ curr_pos }++;

      $self->{ buffer_len }++;
     }

    return $self;
  }
}

my ($steps, $values) = @ARGV;

my $spinlock = Spinlock->new( $steps, $values );

print "The value after 0 is @{ [ $spinlock->after_zero() ] }\n";

exit;
