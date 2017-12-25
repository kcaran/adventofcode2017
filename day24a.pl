#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use List::MoreUtils qw( distinct );
use Path::Tiny;

my $bridges = [];

{ package Components;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

  sub next {
    my ($self, $used) = @_;
    my $link = $used->{ next };
    return grep { !$used->{ $_ } } List::MoreUtils::distinct @{ $self->{ links }{ $link } };
  }

  sub bridges {
    my ($self, $bridges) = @_;

    if (!$bridges) {
      $bridges = [];
      my @next = $self->next( { next => 0 } );
      for my $l (@next) {
        my $link = 0;
        my $ports = $self->{ comp }[$l];
        my $unused_port = $link eq $ports->[0] ? $ports->[1] : $ports->[0];
        push @{ $bridges }, { next => $unused_port, $l => 1 };
       }
     }

    my $new_bridges = [];
    for my $b (@{ $bridges }) {
      my $link = $b->{ next };
      my @next = $self->next( $b );
      return $bridges unless (@next);
      for my $l (@next) {
        my $ports = $self->{ comp }[$l];
        my $unused_port = $link eq $ports->[0] ? $ports->[1] : $ports->[0];
        my $new_used = { %{ $b } };
        $new_used->{ $l } = 1;
        $new_used->{ next } = $unused_port;
        push @{ $new_bridges }, @{ $self->bridges( [ $new_used ] ) };
       }
     }
    
    return $new_bridges;
  }

  sub score {
    my ($self, $bridge) = @_;

    my $score = 0;
    for my $l (keys %{ $bridge }) {
      next if ($l eq 'next');
      my $ports = $self->{ comp }[$l];
      $score += $ports->[0] + $ports->[1];
     }

    return $score;
  }

  sub strongest {
    my ($self) = @_;
    my $top_score = 0;

    my $bridges = $self->bridges();

    for my $b (@{ $bridges }) {
      my $score = $self->score( $b );
      if ($score > $top_score) {
        $top_score = $score;
       }
     }

    return $top_score;
   }

  sub new {
    my ($class, @input) = @_;
    my $self = {
      comp => [],
      links => {},
    };
    bless $self, $class;

    my $cnt = 0;
    for my $line (@input) {
      my $ports = [ sort $line =~ /^(\d+)\/(\d+)/ ];
      $self->{ comp }[$cnt] = $ports;
      push @{ $self->{ links }{ $ports->[0] } }, $cnt;
      push @{ $self->{ links }{ $ports->[1] } }, $cnt;
      $cnt++;
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input24.txt';

my @input = path( $input_file )->lines_utf8( { chomp => 1 } );

my $components = Components->new( @input );

print "The strongest bridge is ", $components->strongest(), "\n";

exit;
