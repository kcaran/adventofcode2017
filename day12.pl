#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Pipes;

  sub connect {
    my ($self, $p1, $p2) = @_;
 
    return if ($p1 == $p2);

    $self->{ program }[$p1]{ $p2 } = 1 ;
    $self->{ program }[$p2]{ $p1 } = 1 ;

    return $self;
   }

  sub is_connected {
    my ($self, $p1, $p2, $tested) = @_;

    return 1 if ($p1 == $p2);

    return 1 if ($self->{ program }[$p1]{ $p2 });

    $tested->{ $p1 } = 1;
    for my $i (keys %{ $self->{ program }[$p1] }) {
      next if ($tested->{ $i });
      $tested->{ $i } = 1;
      return 1 if ($self->is_connected( $i, $p2, $tested ));
     }

    return 0;
   }

  sub connected {
    my ($self, $program) = @_;

    my $connections = {};
    for (my $i = $program; $i < @{ $self->{ program } }; $i++) {
      $connections->{ $i } = 1 if ($self->is_connected( $program, $i ));
     }

    return $connections
   }

  sub num_groups {
    my ($self) = @_;
    my $groups = [];

    for (my $i = 0; $i < @{ $self->{ program } }; $i++) {
      # Check if in any groups
      my $in_group = 0;
      for my $g (@{ $groups }) {
        if ($g->{ $i }) {
          $in_group = 1;
          last;
         }
       }
      next if ($in_group);
      push @{ $groups }, $self->connected( $i );
     }

    return scalar @{ $groups };
   }

  sub parse_connection {
    my ($self, $connect) = @_;

    my ($program, $others) = $connect =~ /^(\d+)\s+<->\s*(.*)$/;

    for my $other ( split /\s*,\s*/, $others ) {
      $self->connect( $program, $other );
     }

    return $self;
   }
   
  sub new {
    my $class = shift;
    my $connections = shift;
    my $self = {
      program => [],
    };
    bless $self, $class;

    for my $connect (@{ $connections }) {
      $self->parse_connection( $connect );
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input12.txt';

my @input = path( $input_file )->lines_utf8();

my $pipes = Pipes->new( \@input );
my $connections = $pipes->connected( 0 );

print "The number of programs connected to 0 is ", scalar keys %{ $connections }, "\n";

print "The number of groups is ", $pipes->num_groups(), "\n";
exit;
