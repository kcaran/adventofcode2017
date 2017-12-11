#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
# $ perl day11.pl $(cat input11.txt)
#
use strict;
use warnings;

#
# N and S are twice as far in y-direction as diagonals
#
my $moves = {
	n  => { x =>  0, y =>  2 },
	ne => { x =>  1, y =>  1 },
	e  => { x =>  1, y =>  0 },
	se => { x =>  1, y => -1 },
	s  => { x =>  0, y => -2 },
	sw => { x => -1, y => -1 },
	w  => { x => -1, y =>  0 },
	nw => { x => -1, y =>  1 },
};

{ package Grid;

  #
  # Move as needed in the X direction, then finish in Y
  # 
  sub distance {
    my ($self) = @_;
    my $distance;
    my ($x, $y) = (abs( $self->{ pos_x } ), abs( $self->{ pos_y } ));

    if ($x > $y) {
      $distance = $x;
     }
    else {
      $distance = int($y - $x + .5)/2 + $x;
     }

    return $distance;
   }

  sub farthest {
    my ($self) = @_;

    return $self->{ max };
   }

  sub move {
    my ($self, $dir) = @_;

    my $move = $moves->{ $dir } or die "Illegal direction '$dir'\n";
    $self->{ pos_x } += $move->{ x };
    $self->{ pos_y } += $move->{ y };
    my $dist = $self->distance();
    if ($dist > $self->{ max }) {
      $self->{ max } = $dist;
     }

    return $self;
   }

  sub new {
    my $class = shift;
    my $input = shift;
    my $self = {
		pos_x => 0,
		pos_y => 0,
        max => 0,
    };
    bless $self, $class;

    return $self;
  }
}

my $input = $ARGV[0] || die "Please enter the input\n";

my $grid = Grid->new();

my @moves = split /\s*,\s*/, $input;
for my $move (@moves) {
  $grid->move( $move );
 }

print "The distance is ", $grid->distance(), " away\n";
print "The farthest is ", $grid->farthest(), " away\n";

exit;
