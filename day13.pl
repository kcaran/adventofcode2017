#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Scanner;

  sub reset {
    my $self = shift;

    $self->{ pos } = 0;
    $self->{ step } = 1;

    return $self;
   }

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

  sub clone {
    my $self = shift;
    my $copy = bless { %{ $self } }, ref $self;
    return $copy;
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

  sub reset {
    my ($self) = @_;
    for my $s (@{ $self->{ levels } }) {
      $s->reset() if ($s);
     }
   }

  sub next_pico {
    my ($self) = @_;
    for my $s (@{ $self->{ levels } }) {
      next unless $s;
      $s->scan();
     }
   }

  sub is_caught {
    my ($self) = @_;

    my $pos = 0;
    while ($pos < @{ $self->{ levels } }) {
      my $scanner = $self->{ levels }[$pos];
      return 1 if ($scanner && $scanner->caught());
      $self->next_pico();
      $pos++;
     }

    return 0;
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

  sub escape {
    my ($self) = @_;

    my $delay = 0;
    while (1) {
     $self->reset();
     my $wait = $delay;
     $self->next_pico() while ($wait--);

     return $delay if (!$self->is_caught());
     $delay++;
    };

   return;
  }

  sub clone {
    my $self = shift;
    my $copy = {
      levels => [],
    };
    bless $copy, ref $self;

    for (my $i = 0; $i < @{ $self->{ levels } }; $i++) {
      my $scanner = $self->{ levels }[$i];
      $copy->{ levels }[$i] = $scanner->clone() if ($scanner);
     }

    return $copy;
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

sub escape
 {
  my $firewall = shift;
  
  $firewall->reset();

  my $delay = 0;
  while (1) {
    if ($firewall->{ levels }[0]{ pos } != 0 && $firewall->{ levels }[1]{ pos } != 1) {
      my $orig = $firewall->clone();
      return $delay if (!$firewall->is_caught());
      $firewall = $orig;
     }
    $firewall->next_pico();
    $delay++;
  };

  return;
 }

my $input_file = $ARGV[0] || 'input13.txt';

my @input = path( $input_file )->lines_utf8();

my $firewall = Firewall->new( \@input );

print "The score is ", $firewall->traverse(), "\n";

print "The minimum delay is ", escape( $firewall ), "\n";

exit;
