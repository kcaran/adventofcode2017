#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Dance;

  my $num_dancers = 16;

  sub dance {
    my ($self, $num_dances) = @_;

    my $dance = ($num_dances - 1) % @{ $self->{ dances } };

    return $self->{ dances }[ $dance ];
   }

  sub iterate {
    my ($self, @steps) = @_;

    my %seen;
    $self->{ dances } = [];
    my $max = 100;
    my $num_dances = 0;
    while ($num_dances < $max) {
      for my $s (@steps) {
        $self->step( $s );
       }
      my $order = $self->order();
      if ($seen{ $order }) {
        return $self;
       }
      # We can't start at 0!
      $seen{ $order } = $num_dances + 1;
      $self->{ dances }[$num_dances] = $order;
      $num_dances++;
     }

    die "We've exceeded the maximum number of dances";
  }

  sub step {
    my ($self, $step) = @_;

    my ($cmd, $val1, $val2) = ($step =~ /^([sxp])(\w+)(?:\/(\w+))*/);

    if ($cmd eq 's') {
      $self->{ programs } = substr( $self->{ programs }, -$val1 ) 
		. substr( $self->{ programs }, 0, length( $self->{ programs } ) - $val1 );
     }

    if ($cmd eq 'x') {
      my $tmp = substr( $self->{ programs }, $val1, 1 );
      substr( $self->{ programs }, $val1, 1 ) = substr( $self->{ programs }, $val2, 1 );
      substr( $self->{ programs }, $val2, 1 ) = $tmp;
     }

    if ($cmd eq 'p') {
      #
      # To use tr with variables, we need eval. Don't forget to escape the
      # variable's sigil!
      #
      eval "\$self->{ programs } =~ tr/${val1}${val2}/${val2}${val1}/";
     }
   }

  sub order {
    my $self = shift;

    return $self->{ programs };
   }

  sub new {
    my ($class) = @_;
    my $self = {
		programs => '',
    };
    bless $self, $class;

    my $x = 'a';
    my $cnt = $num_dancers; 
    while ($cnt) { 
      $self->{ programs } .= $x++;
      $cnt--;
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input16.txt';
my $num_dances = $ARGV[1] || 1;

my $dance = Dance->new();

my $step_input = path( $input_file )->slurp_utf8();
chomp $step_input;

my @steps = split /\s*,\s*/, $step_input;

# Iterate through all of the possible combinations of dances
$dance->iterate( @steps );

print "The order of the programs is @{[ $dance->dance( $num_dances ) ]}\n";
