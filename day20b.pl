#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Particle;

  sub move {
    my $self = shift;

    $self->{ vel }[0] += $self->{ acc }[0];
    $self->{ vel }[1] += $self->{ acc }[1];
    $self->{ vel }[2] += $self->{ acc }[2];

    $self->{ pos }[0] += $self->{ vel }[0];
    $self->{ pos }[1] += $self->{ vel }[1];
    $self->{ pos }[2] += $self->{ vel }[2];

    $self->{ dist } = abs( $self->{ pos }[0] )
		+ abs( $self->{ pos }[1] ) + abs( $self->{ pos }[2] );

    $self->{ str } = join( ',', @{ $self->{ pos } } );

    return $self;
  }

  sub new {
    my ($class, $input) = @_;
    my $self = {
      pos => [],
      vel => [],
      acc => [],
      dist => 0,
      str => '',
    };
    bless $self, $class;

    my (@vals) = ($input =~ /<([^,]+),([^,]+),([^>]+)>.*<([^,]+),([^,]+),([^>]+).*<([^,]+),([^,]+),([^>]+)>/);

    $self->{ pos } = [ @vals[ 0 .. 2 ] ];
    $self->{ vel } = [ @vals[ 3 .. 5 ] ];
    $self->{ acc } = [ @vals[ 6 .. 8 ] ];

    $self->{ dist } = abs( $self->{ pos }[0] )
		+ abs( $self->{ pos }[1] ) + abs( $self->{ pos }[2] );

    $self->{ str } = join( ',', @{ $self->{ pos } } );
    return $self;
  }
}

sub find_closest
 {
  my ($particles) = @_;

  my $positions = {};

  $particles->[0]->move();
  my $closest = 0;
  my $distance = $particles->[0]{ dist };
  push @{ $positions->{ $particles->[0]{ str } } }, 1;

  for (my $i = 1; $i < @{ $particles }; $i++) {
    $particles->[$i]->move();
    if ($particles->[$i]{ dist } < $distance) {
      $closest = $i;
      $distance = $particles->[$i]{ dist };
     }
    push @{ $positions->{ $particles->[$i]{ str } } }, $i + 1;
   }

  my @to_remove = ();
  for my $pos (keys %{ $positions }) {
    if (@{ $positions->{ $pos } } > 1) {
      for my $p (@{ $positions->{ $pos } }) {
        push @to_remove, $p;
       }
     } 
    }

   for my $p (reverse sort { $a <=> $b } @to_remove) {
     print "Removing particle ", ($p - 1), " from ", scalar @{ $particles }, "\n";
     splice @{ $particles }, $p-1, 1;
    }

  return $closest;
 }

my $input_file = $ARGV[0] || 'input20.txt';
my $particles = [];

for my $line (path( $input_file )->lines_utf8( { chomp => 1 } )) {
  push @{ $particles }, Particle->new( $line );
 }

my $num_particles = 1000;
while (1) {
  for (my $i = 0; $i < 1000000; $i++) {
    my $idx = find_closest( $particles );
# print "The closest is $idx ($particles->[$idx]{ dist })\n";
   }
  my $new = scalar @{ $particles };
  print "There are $new left\n";
  die if ($new eq $num_particles);
  $num_particles = $new;
 }

exit;
