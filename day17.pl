#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Spinlock;

  sub after_2017 {
    my ($self) = @_;

    return $self->{ buffer }[0] if ($self->{ buffer }[-1] == 2017);
    my $count = 0;
    while ($count < @{ $self->{ buffer } } - 1) {
      return $self->{ buffer }[$count+1] if ($self->{ buffer }[$count] == 2017);
      $count++;
     }

    die "We didn't find 2017";
  }

  sub new {
    my ($class, $steps) = @_;
    my $self = {
		buffer => [0],
		curr_pos => 0,
    };
    bless $self, $class;

    my $count = 1;
    while ($count <= 2017) {
      $self->{ curr_pos } = ($self->{ curr_pos } + $steps) % @{ $self->{ buffer } };
      splice( @{ $self->{ buffer } }, $self->{ curr_pos } + 1, 0, $count );
      $self->{ curr_pos }++;

      $count++;
     }

    return $self;
  }
}

my $input = $ARGV[0];

my $spinlock = Spinlock->new( $input );

print "The value after 2017 is @{ [ $spinlock->after_2017() ] }\n";
exit;
