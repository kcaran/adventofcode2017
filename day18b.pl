#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

my $queue = [ [], [] ];
my $queue_cnt = [ 0, 0 ];
my $queue_rcv = [ 0, 0 ];

{ package Duet;

  my $cmd_table = {
		'snd' => sub {
            my $var1 = $_[1];
			if ($_[1] =~ /^[a-z]/) {
			  $var1 = $_[0]->{ regs }{ $var1 };
			}
			#print "KAC: Send from $_[0]->{ num }: $_[1] = $var1\n";
			push @{ $queue->[ $_[0]->{ num } ] }, $var1;
			$queue_cnt->[ $_[0]->{ num } ]++;
			return;
		},
		'set' => sub { $_[0]->{ regs }{ $_[1] } = $_[2]; return; },
		'add' => sub { $_[0]->{ regs }{ $_[1] } += $_[2]; return; },
		'mul' => sub { $_[0]->{ regs }{ $_[1] } *= $_[2]; return; },
		'mod' => sub { $_[0]->{ regs }{ $_[1] } %= $_[2]; return; },
		'rcv' => sub { 
            my $num = $_[0]->{ num };
			#print "Receiving ${ num } ($queue_rcv->[$num])\n";
            $queue_rcv->[$num] = 1;
            my $other_prog = $num ? 0 : 1;

            if (@{ $queue->[$other_prog] }) {
              my $val = shift @{ $queue->[$other_prog] };
              $queue_rcv->[$num] = 0;
			  $_[0]->{ regs }{ $_[1] } = $val;
			  #print "KAC: $_[0]->{ num } ( $_[1] ) received $val\n";
             }
            else {
			  die "Program 1 sent $queue_cnt->[1] values" if ($queue_rcv->[$other_prog] && !@{ $queue->[$num] } && !@{ $queue->[$other_prog] });
              return 1;
             }
			return;
		},
		'jgz' => sub {
            my $var1 = $_[1];
			if ($_[1] =~ /^[a-z]/) {
			  $var1 = $_[0]->{ regs }{ $var1 };
			}
			if ($var1 > 0) {
			  $_[0]->{ inst } += $_[2];
			  return 1;
			}
			return;
		},
	};

  sub parse_cmd {
    my ($self, $cmd_line) = @_;

    my ($cmd, $var1, $var2) = ($cmd_line =~ /^(\S+)\s+(\S+)(?:\s+(\S+))?$/);

    die "Illegal instruction $cmd" unless ($cmd_table->{ $cmd });

    return { cmd => $cmd, var1 => $var1, var2 => $var2 };
   }

  sub next {
    my ($self) = @_;

    return unless ($self->{ inst } < @{ $self->{ program } });
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
      recovered => '',
      num => $num,
    };
    bless $self, $class;

    $self->{ regs }{ p } = $num;
    for my $cmd (@program) {
      push @{ $self->{ program } }, $self->parse_cmd( $cmd );
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input18.txt';

my @input = path( $input_file )->lines_utf8( { chomp => 1 } );

my $duet0 = Duet->new( 0, @input );
my $duet1 = Duet->new( 1, @input );

while (1) {
    do {
      $duet0->next();
    } until ($queue_rcv->[0]);
    do {
      $duet1->next();
    } until ($queue_rcv->[1]);
 }

print "Both programs terminated\n";
exit;
