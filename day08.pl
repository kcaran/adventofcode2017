#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Program;

  sub add_inst {
    my ($self, $inst) = @_;

    my ($reg, $cmd, $val, $test) = $inst =~ /^(\S+)\s+(inc|dec)\s+(\S+)\s+if\s+(.*)$/;

    $val = -$val if ($cmd eq 'dec');
    $self->{ reg }{ $reg } ||= 0;

    # Create a perl command from test
    $test =~ s/^(\S+)/\(\$self->{ reg }{ $1 } || 0\)/;
    if (eval( $test )) {
      $self->{ reg }{ $reg } += $val;
      if ($self->{ reg }{ $reg } > $self->{ max_val }) {
        $self->{ max_val } = $self->{ reg }{ $reg };
       }
     }
   }
   
  sub max_reg {
    my $self = shift;

    my $max = 0;
    for my $reg (keys %{ $self->{ reg } }) {
      if ($self->{ reg }{ $reg } > $max) {
        $max = $self->{ reg }{ $reg };
       }
     }

    return $max;
   }

  sub max_val {
    my $self = shift;

    return $self->{ max_val };
   }

  sub new {
    my $class = shift;
    my $instructions = shift;
    my $self = {
		reg => {},
        max_val => 0,
    };
    bless $self, $class;

    for my $inst (@{ $instructions }) {
      $self->add_inst( $inst );
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input08.txt';

my @instructions = path( $input_file )->lines_utf8();

my $program = Program->new( \@instructions );

print "The largest value of any register is ", $program->max_reg(), "\n";
print "The highest value ever was ", $program->max_val(), "\n";
