#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Data::Dumper;
use Path::Tiny;

my $queue = [ [], [] ];
my $queue_cnt = [ 0, 0 ];
my $queue_rcv = [ 0, 0 ];

{ package Duet;

  my $cmd_table = {
		'set' => sub { $_[0]->{ regs }{ $_[1] } = $_[2]; return; },
		'sub' => sub { $_[0]->{ regs }{ $_[1] } -= $_[2]; return; },
		'mul' => sub { $_[0]->{ regs }{ $_[1] } *= $_[2]; $_[0]->{ mul }++; return; },
		'jnz' => sub {
            my $var1 = $_[1];
			if ($_[1] =~ /^[a-z]/) {
			  $var1 = $_[0]->{ regs }{ $var1 } || 0;
			}
			if ($var1 != 0) {
			  $_[0]->{ inst } += $_[2];
			  return 1;
			}
			return;
		},
		'pnt' => sub {
          print Data::Dumper::Dumper( $_[0]->{ regs } );
          return;
        }
	};

  sub parse_cmd {
    my ($self, $cmd_line) = @_;

    my ($cmd, $var1, $var2) = ($cmd_line =~ /^(\S+)\s+(\S+)(?:\s+(\S+))/);

    die "Illegal instruction $cmd_line" unless ($cmd_table->{ $cmd });

    return { cmd => $cmd, var1 => $var1, var2 => $var2 };
   }

  sub next {
    my ($self) = @_;

    if ($self->{ inst } >= @{ $self->{ program } }) {
      $self->{ end } = 1;
      return;
     }

    my $line = $self->{ program }[ $self->{ inst } ];
    my $var1 = $line->{ var1 };
    my $var2 = $line->{ var2 } || 0;
#print "Program $self->{ num }: $self->{ inst } ( $line->{ cmd } $var1 $var2 )\n";
    if ($var2 =~ /^[a-z]/) {
      $var2 = $self->{ regs }{ $var2 };
     }
    $self->{ inst }++ unless (&{ $cmd_table->{ $line->{ cmd } } }( $self, $var1, $var2 ));

    return;
   }

  sub run {
    my ($self) = @_;

    while ($self->{ inst } < @{ $self->{ program } }) {
      $self->next();
     }

    return;
   }

  sub new {
    my ($class, $num, @program) = @_;
    my $self = {
      regs => {},
      program => [],
      inst => 0,
      sound => '',
      mul => 0,
      num => $num,
      end => 0,
    };
    bless $self, $class;

    for my $cmd (@program) {
      push @{ $self->{ program } }, $self->parse_cmd( $cmd );
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input23.txt';

my @input = path( $input_file )->lines_utf8( { chomp => 1 } );

my $code = Duet->new( 0, @input );

while (!$code->{ end }) {
  $code->next();
 }

print "The mul instruction was performed $code->{ mul } times.\n";
print "The h register is $code->{ regs }{ h }.\n";

print Dumper( $code->{ regs } );

exit;
