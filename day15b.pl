#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Generator;

  sub to_match {
    my ($self) = @_;
 
    return $self->{ value } & 0xffff;
   }

  sub next {
    my $self = shift;

    my $criteria = $self->{ criteria } - 1;
    my $not_ok = 1;
    while ($not_ok) {
      $self->{ value } = $self->{ value } * $self->{ factor };
      $self->{ value } = $self->{ value } % 2147483647;
      $not_ok = $self->{ value } & $criteria;
    }

    return $self;
  }

  sub new {
    my ($class, $start, $factor, $criteria) = @_;
    my $self = {
		value => $start,
		factor => $factor,
        criteria => $criteria,
    };
    bless $self, $class;

    return $self;
  }
}

my ($start_a, $start_b) = @ARGV;

my $gen_a = Generator->new( $start_a, 16807, 4 );
my $gen_b = Generator->new( $start_b, 48271, 8 );

my $num_tries = 5000000;
my $matches = 0;
my $count = $num_tries;

while ($count) {
  $gen_a->next();
  $gen_b->next();

  $matches++ if ($gen_a->to_match() == $gen_b->to_match());
  $count--;
  print "The count is $count\n" if ($count % 1000000 == 0);
 }

print "There are $matches matches in $num_tries\n";

exit;
