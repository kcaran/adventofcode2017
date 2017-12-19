#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Maze;

  sub curr {
    my $self = shift;

    return $self->{ grid }[ $self->{ row } ][ $self->{ col } ];
  }

  sub shift_ud {
    my ($self) = @_;

    if ($self->{ row } != 0 && $self->{ grid }[$self->{ row } - 1][$self->{ col }] ne ' ') {
      $self->{ dir } = 'u';
     }
    else {
      $self->{ dir } = 'd';
     }
  }

  sub shift_lr {
    my ($self) = @_;

    if ($self->{ col } != 0 && $self->{ grid }[$self->{ row }][$self->{ col } - 1] ne ' ') {
      $self->{ dir } = 'l';
     }
    else {
      $self->{ dir } = 'r';
     }
  }

  sub up {
    my $self = shift;
    $self->{ row }--;
    if ($self->curr() eq '+') {
      $self->shift_lr();
     }

   return $self;
  }

  sub down {
    my $self = shift;
    $self->{ row }++;
    if ($self->curr() eq '+') {
      $self->shift_lr();
     }

   return $self;
  }

  sub left {
    my $self = shift;
    $self->{ col }--;
    if ($self->curr() eq '+') {
      $self->shift_ud();
     }

   return $self;
  }

  sub right {
    my $self = shift;
    $self->{ col }++;
    if ($self->curr() eq '+') {
      $self->shift_ud();
     }

   return $self;
  }

  sub go {
    my $self = shift;
    my %move = (
		'u' => sub { $_[0]->up },
		'd' => sub { $_[0]->down },
		'l' => sub { $_[0]->left },
		'r' => sub { $_[0]->right },
	);

    while ($self->{ dir }) {
      my $curr = $self->curr();
      $self->{ on_letter } = ($curr =~ /[A-Z]/);
      if ($self->{ on_letter }) {
        $self->{ letters } .= $curr;
       }

      &{ $move{ $self->{ dir } } }( $self );
      $self->{ dir } = '' if ($self->{ on_letter } && $self->curr() eq ' ');
     }
  }

  sub new {
    my ($class, @input) = @_;
    my $self = {
      letters => '',
      grid => [],
      row => 0,
      col => '',
      dir => 'd',
      on_letter => 0,
    };
    bless $self, $class;

    $self->{ col } = index( $input[0], '|' );
    for my $line (@input) {
      push @{ $self->{ grid } }, [ split '', $line ];
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input19.txt';

my @input = path( $input_file )->lines_utf8( { chomp => 1 } );

my $maze = Maze->new( @input );

$maze->go();

print "The letters seen are $maze->{ letters }\n";

exit;
