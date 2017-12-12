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

print "Testing ($p1, $p2)...\n";
    return 1 if ($p1 == $p2);

    return 1 if ($self->{ program }[$p1]{ $p2 });

    $tested->{ $p1 } = 1;
    for my $i (keys %{ $self->{ program }[$p1] }) {
      next if ($tested->{ $i });
      $tested->{ $i } = 1;
      return 1 if ($self->is_connected( $i, $p2, $tested ));
     }

print "($p1, $p2) is not connected\n";
    return 0;
   }

  sub num_connected {
    my ($self, $program) = @_;

    my $num = 0;
    for (my $i = $program; $i < @{ $self->{ program } }; $i++) {
      $num++ if ($self->is_connected( $program, $i ));
print "\n";
     }

    return $num;
   }

  sub parse_connection {
    my ($self, $connect) = @_;

print "Parsing $connect\n";
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
my $connections = $pipes->num_connected( 0 );

print "The number of programs connected to 0 is ", $connections, "\n";

exit;
