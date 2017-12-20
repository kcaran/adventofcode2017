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

    return $self;
  }

  sub new {
    my ($class, $num, $input) = @_;
    my $self = {
      num => $num,
      pos => [],
      vel => [],
      acc => [],
      dist => 0,
    };
    bless $self, $class;

    my (@vals) = ($input =~ /<([^,]+),([^,]+),([^>]+)>.*<([^,]+),([^,]+),([^>]+).*<([^,]+),([^,]+),([^>]+)>/);

    $self->{ pos } = [ @vals[ 0 .. 2 ] ];
    $self->{ vel } = [ @vals[ 3 .. 5 ] ];
    $self->{ acc } = [ @vals[ 6 .. 8 ] ];

    $self->{ dist } = abs( $self->{ pos }[0] )
		+ abs( $self->{ pos }[1] ) + abs( $self->{ pos }[2] );

    return $self;
  }
}

sub find_closest
 {
  my ($particles) = @_;

  $particles->[0]->move();
  my $closest = 0;
  my $distance = $particles->[0]{ dist };

  for (my $i = 0; $i < @{ $particles }; $i++) {
    $particles->[$i]->move();
    if ($particles->[$i]{ dist } < $distance) {
      $closest = $i;
      $distance = $particles->[$i]{ dist };
     }
   }

  return $closest;
 }

my $input_file = $ARGV[0] || 'input20.txt';
my $particles = [];

my $cnt = 0;
for my $line (path( $input_file )->lines_utf8( { chomp => 1 } )) {
  push @{ $particles }, Particle->new( $cnt, $line );
  $cnt++;
 }

for (my $i = 0; $i < 1000; $i++) {
  my $idx = find_closest( $particles );
  print "The closest is $idx ($particles->[$idx]{ dist })\n";
 }

exit;
