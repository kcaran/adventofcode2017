#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Rules;

  sub v_flip {
    my ($self, $rule_a) = @_;
    my $flipped = [];
    my $len = @{ $rule_a };
    for (my $row = 0; $row < $len; $row++) {
      for (my $i = 0; $i < $len; $i++) {
        my $new = $len - $i - 1;
        $flipped->[$row][$new] = $rule_a->[$row][$i];
       }
     }

    return $flipped;
  }

  sub h_flip {
    my ($self, $rule_a) = @_;
    my $flipped = [];
    my $len = @{ $rule_a };
    for (my $row = 0; $row < $len; $row++) {
      my $new = $len - $row - 1;
        $flipped->[$new] = $rule_a->[$row];
     }

    return $flipped;
  }

  sub rotate {
    my ($self, $rule_a) = @_;

    my $rotated = [];

    my $len = @{ $rule_a };
    for (my $row = 0; $row < $len; $row++) {
      my $col = $len - $row - 1;
      for (my $i = 0; $i < $len; $i++) {
        $rotated->[$i][$col] = $rule_a->[$row][$i];
      }
     }

    return $rotated;
  }

  sub to_rule {
    my ($self, $rule_a) = @_;

    return join( '/', map { join( '', @{ $_ } ) } @{ $rule_a } );
  }

  sub to_array {
    my ($self, $rule) = @_;
    my $array = [];

    my $cnt = 0;
    for (split( '/', $rule )) {
      $array->[$cnt++] = [ split( '' ) ];
     }

    return $array;
  }

  sub add_rule {
    my ($self, $rule, $output) = @_;

    my $rule_a = $self->to_array( $rule );

    my $bin = (length( $rule ) == 5) ? 'rules_2' : 'rules_3';

    my $cnt = 0;

    do {
      $self->{ $bin }{ $self->to_rule( $rule_a ) } = $output;
      $self->{ $bin }{ $self->to_rule( $self->h_flip( $rule_a ) ) } = $output;
      $self->{ $bin }{ $self->to_rule( $self->v_flip( $rule_a ) ) } = $output;
      $rule_a = $self->rotate( $rule_a );
      $cnt++;
    } until ($cnt == 4);

    return $self;
  }

  sub add_grid {
    my ($self, $grid, $new, $x, $y) = @_;

    my $len = @{ $new };
    for (my $i = 0; $i < $len; $i++) {
      for (my $j = 0; $j < $len; $j++) {
        $grid->[$x * $len + $i][$y * $len + $j] = $new->[$i][$j];
       }
     }

    return $self;
   }

  sub split_2 {
    my ($self, $len) = @_;

    my $grid_a = $self->to_array( $self->{ grid } );
    my $new_grid = [];

    for (my $x = 0; $x < ($len / 2); $x++) {
      for (my $y = 0; $y < ($len / 2); $y++) {
        my $new_piece = [];
        for (my $row = 0; $row < 2; $row++) {
          for (my $col = 0; $col < 2; $col++) {
            $new_piece->[$row][$col] = $grid_a->[ $x * 2 + $row ][ $y * 2 + $col ];
           }
         }

        my $next = $self->{ rules_2 }{ $self->to_rule( $new_piece ) };
        die "Can't find rule" unless ($next);
        $self->add_grid( $new_grid, $self->to_array( $next ), $x, $y );
       }
     }
    $self->{ grid } = $self->to_rule( $new_grid );

    return $self;
   }

  sub split_3 {
    my ($self, $len) = @_;

    my $grid_a = $self->to_array( $self->{ grid } );
    my $new_grid = [];

    for (my $x = 0; $x < ($len / 3); $x++) {
      for (my $y = 0; $y < ($len / 3); $y++) {
        my $new_piece = [];
        for (my $row = 0; $row < 3; $row++) {
          for (my $col = 0; $col < 3; $col++) {
            $new_piece->[$row][$col] = $grid_a->[ $x * 3 + $row ][ $y * 3 + $col ];
           }
         }

        my $next = $self->{ rules_3 }{ $self->to_rule( $new_piece ) };
        die "Can't find rule" unless ($next);
        $self->add_grid( $new_grid, $self->to_array( $next ), $x, $y );
       }
     }
    $self->{ grid } = $self->to_rule( $new_grid );

    return $self;
   }

  sub go {
    my ($self) = @_;

    my ($first_row) = $self->{ grid } =~ /^(.*?)\//;
    my $len = length( $first_row );

    if ($len % 2 == 0) {
      $self->split_2( $len );
     }
    else {
      $self->split_3( $len );
     }

   return $self;
  }

  sub new {
    my ($class, @input) = @_;
    my $self = {
      rules_2 => {},
      rules_3 => {},
      grid => '.#./..#/###',
    };
    bless $self, $class;

    for my $line (@input) {
      my ($rule, $output) = ($line =~ /^(.*)\s+=>\s+(.*)$/);
      $self->add_rule( $rule, $output );
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input21.txt';
my $iterations = $ARGV[1] || 5;
my @input = path( $input_file )->lines_utf8( { chomp => 1 } );

my $rules = Rules->new( @input );

for (my $i = 0; $i < $iterations; $i++) {
  $rules->go();
 }

print "The number on is ", scalar ( () = $rules->{ grid } =~ /(\#)/g ), "\n";
exit;
