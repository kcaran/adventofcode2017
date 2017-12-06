#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Memory;

  sub find_inf_loop {
    my $self = shift;

    while (1) {
      $self->realloc();
      if (my $prev_seen = $self->snapshot()) {
        $self->{ prev_seen } = $prev_seen;
        return $self->{ steps } 
       }
     }
  }

  sub max_bank {
    my $self = shift;
    my $max = 0;
    my $index = 0;
    for (my $i = 0; $i < $self->{ num_banks }; $i++) {
      if ($self->{ data }[$i] > $max) {
        $max = $self->{ data }[$i];
        $index = $i;
       }
     }

    return $index;
  }

  sub realloc {
    my $self = shift;

    my $idx = $self->max_bank();
    my $num_blocks = $self->{ data }[$idx];
    $self->{ data }[$idx] = 0;
    while ($num_blocks) {
      $idx = ($idx + 1) % $self->{ num_banks };
      $self->{ data }[$idx]++;
      $num_blocks--;
     }

   return;
  }

  sub snapshot {
    my $self = shift;

    my $distribution = join ',', @{ $self->{ data } };
    return $self->{ history }{ $distribution } if ($self->{ history }{ $distribution });
    $self->{ history }{ $distribution } = $self->{ steps }++;

    return 0;
   }

  sub new {
    my $class = shift;
    my $input = shift;
    my $self = {};

    $self->{ history } = {};
    $self->{ steps } = 0;
    $self->{ data } = [ split /\s+/, $input ];
    $self->{ num_banks } = @{ $self->{ data } };

    bless $self, $class;

    $self->snapshot();

    return $self;
  }

}

my $input_file = $ARGV[0] || 'input06.txt';

my $raw_input = path( $input_file )->slurp_utf8();
chomp $raw_input;

my $memory = Memory->new( $raw_input );

my $allocs = $memory->find_inf_loop();
print "The total number of allocations is $allocs.\n";
print "This configuration was seen ", $allocs - $memory->{ prev_seen }, " steps ago.\n";
