#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Tower;

  sub balanced {
    my ($self, $child_weights) = @_;
    my $count = {}; 
    for (my $i = 0; $i < @{ $child_weights }; $i++) {
      my $weight = $child_weights->[$i][1];
      push @{ $count->{ $weight } }, $i;
     }

    # If there is only one weight, we are balanced!
    return if (keys %{ $count } == 1);

    my $balanced_wt = 0;
    my $unbalanced_wt = 0;
    for my $weight (keys %{ $count }) {
      if (@{ $count->{ $weight } } == 1) {
        $unbalanced_wt = $weight;
       }
      else {
        $balanced_wt = $weight;
       }
     }

    die unless ($balanced_wt && $unbalanced_wt);

    my $unbalanced_child = $child_weights->[ $count->{ $unbalanced_wt }[0] ][0];
    my $new_weight = $self->{ subs }{ $unbalanced_child }{ weight } + ($balanced_wt - $unbalanced_wt); 
    return [ $unbalanced_child, $new_weight ];
  }

  sub calc_weight {
   my ($self, $name) = @_;
   my $weight = $self->{ subs }{ $name }{ weight };
   for my $child (@{ $self->{ subs }{ $name }{ above } }) {
	 $weight += $self->calc_weight( $child );
    }

   return $weight;
  }

  sub get_below {
   my ($self, $nodes) = @_;

   my $below = {};
   for my $name (keys $self->{ subs }) {
     my $sub = $self->{ subs }{ $name };
     if (@{ $nodes } == 0) {
       $below->{ $name } = 1 if (@{ $sub->{ above } } == 0);
      }
     else {
       for my $n (@{ $nodes }) {
         $below->{ $name } = 1 if ($name eq $self->{ subs }{ $n }{ below });
        }
      }
    }

   return [ keys $below ];
  }

  #
  # check_weight() - Need to start at the top and work *down*
  #
  sub check_weight {
   my $self = shift;
   my $nodes = [];
   do {
     $nodes = $self->get_below( $nodes );
     for my $name (@{ $nodes }) {
       next unless (@{ $self->{ subs }{ $name }{ above } } > 1);
       my $child_weights = [];
       for my $child (@{ $self->{ subs }{ $name }{ above } }) {
         push @{ $child_weights }, [ $child, $self->calc_weight( $child ) ];
        }
       if (my $unbalanced = $self->balanced( $child_weights )) {
         return $unbalanced;
        }
      }
    } while (@{ $nodes });

   return;
  }

  sub find_bottom {
   my $self = shift;

   for my $name (keys $self->{ subs }) {
     return $name if (!$self->{ subs }{ $name }{ below });
    }

   return;
  }

  sub parse_sub {
    my ($self, $line) = @_;
    my $above = [];
    my ($name, $weight, $children) = $line =~ /^(\S+)\s+\((\d+)\)(?:\s+->\s+(.*$))?/;
    if ($children) {
      $above = [ split /\s*,\s*/, $children ];
     }

   return ($name, $weight, $above);
  }
   
  sub new {
   my ($class, @lines) = @_;
   my $self = {};

   bless $self, $class;
   for my $sub (@lines) {
     my ($name, $weight, $above) = $self->parse_sub( $sub );
     $self->{ subs }{ $name }{ weight } = $weight;
     $self->{ subs }{ $name }{ above } = $above;
     for my $child (@{ $above }) {
       $self->{ subs }{ $child }{ below } = $name;
      }
    }

   return $self;
  }
}

my $input_file = $ARGV[0] || 'input07.txt';

my @data = path( $input_file )->lines_utf8();

my $tower = new Tower( @data );

print "The bottom of the tower is ", $tower->find_bottom(), "\n";

my $unbalanced = $tower->check_weight();

print "The weight of the bad program should be ", $unbalanced->[1], "\n" if ($unbalanced);

