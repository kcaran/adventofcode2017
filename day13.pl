#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Scanner;

  sub caught {
    my $self = shift;

    return ($self->{ pos } == 0) ? $self->{ depth } : 0;
   }

  sub scan {
    my $self = shift;
 
    $self->{ pos } += $self->{ step };

    $self->{ step } = 1 if ($self->{ pos } == 0);
    $self->{ step } = -1 if ($self->{ pos } == $self->{ depth } - 1);

    return $self;
   }

  sub new {
    my $class = shift;
    my $depth = shift;
    my $self = {
      depth => $depth,
      pos => 0,
      step => 1,
    };
    bless $self, $class;

    return $self;
  }
}

{ package Firewall;

  sub next_pico {
    my ($self) = @_;
    for my $s (@{ $self->{ levels } }) {
      next unless $s;
      $s->scan();
     }
   }

  sub traverse {
    my ($self) = @_;

    my $score = 0;
    my $pos = 0;
    while ($pos < @{ $self->{ levels } }) {
      my $scanner = $self->{ levels }[$pos];
      $score += $pos * $scanner->caught if ($scanner);
      $self->next_pico();
      $pos++;
     }

    return $score;
   }

  sub new {
    my $class = shift;
    my $scanners = shift;
    my $self = {
      levels => [],
    };
    bless $self, $class;

    for my $s (@{ $scanners }) {
      my ($loc, $depth) = $s =~ /^(\d+)\D*(\d+)/;
      $self->{ levels }[$loc] = Scanner->new( $depth );
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input13.txt';

my @input = path( $input_file )->lines_utf8();

my $firewall = Firewall->new( \@input );

print "The score is ", $firewall->traverse(), "\n";

exit;
