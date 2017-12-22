#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Grid;

  sub move {
    my ($self) = @_;
    # Turn right if infected
    my $pos = "$self->{ pos }[0],$self->{ pos }[1]";
    my $status = $self->{ grid }{ $pos };
    if ($self->{ dir }[0] == 1) {
      $self->{ dir } = $status ? [ 0, 1 ] : [ 0, -1 ];
     }
    elsif ($self->{ dir }[0] == -1) {
      $self->{ dir } = $status ? [ 0, -1 ] : [ 0, 1 ];
     }
    elsif ($self->{ dir }[1] == 1) {
      $self->{ dir } = $status ? [ -1, 0 ] : [ 1, 0 ];
     }
    elsif ($self->{ dir }[1] == -1) {
      $self->{ dir } = $status ? [ 1, 0 ] : [ -1, 0 ];
     }

    $self->{ grid }{ $pos } = $status ? 0 : 1;
    $self->{ infected }++ if (!$status);

    $self->{ pos }[0] += $self->{ dir }[0];
    $self->{ pos }[1] += $self->{ dir }[1];
  }

  sub new {
    my ($class, @input) = @_;
    my $self = {
      grid => {},
	  pos => [0, 0],
	  dir => [1, 0],	# up
      infected => 0,
    };
    bless $self, $class;

    my $mid = (@input - 1)/2;

    my $row = $mid;
    for my $line (@input) {
      my @vals = split( '', $line );
      for (my $i = 0; $i < @vals; $i++) {
        if ($vals[$i] eq '#') {
          my $col = $i - $mid;
          $self->{ grid }{ "$row,$col" } = 1;
         }
       }
      $row--;
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input22.txt';
my $iterations = $ARGV[1] || 5;
my @input = path( $input_file )->lines_utf8( { chomp => 1 } );

my $grid = Grid->new( @input );

for (my $i = 0; $i < $iterations; $i++) {
  $grid->move();
 }

print "The number infected is $grid->{ infected }\n";

exit;
