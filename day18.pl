#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

use Path::Tiny;

{ package Duet;

  my $cmd_table = {
		'snd' => sub { $_[0]->{ sound } = $_[0]->{ regs }{ $_[1] }; return; },
		'set' => sub { $_[0]->{ regs }{ $_[1] } = $_[2]; return; },
		'add' => sub { $_[0]->{ regs }{ $_[1] } += $_[2]; return; },
		'mul' => sub { $_[0]->{ regs }{ $_[1] } *= $_[2]; return; },
		'mod' => sub { $_[0]->{ regs }{ $_[1] } %= $_[2]; return; },
		'rcv' => sub { 
			if ($_[0]->{ regs }{ $_[1] }) {
			  $_[0]->{ regs }{ $_[1] } = $_[0]->{ sound };
			  $_[0]->{ recovered } = $_[0]->{ sound };
			}
			return;
		},
		'jgz' => sub {
			if ($_[0]->{ regs }{ $_[1] }) {
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

  sub run {
    my ($self) = @_;

    while ($self->{ inst } < @{ $self->{ program } }) {
      my $line = $self->{ program }[ $self->{ inst } ];
      my $var1 = $line->{ var1 };
      my $var2 = $line->{ var2 } || '';
      if ($var2 =~ /^[a-z]/) {
        $var2 = $self->{ regs }{ $var2 };
       }
      $self->{ inst }++ unless (&{ $cmd_table->{ $line->{ cmd } } }( $self, $var1, $var2 ));
      return $self->{ recovered } if ($self->{ recovered });
     }

    return;
   }

  sub new {
    my ($class, @program) = @_;
    my $self = {
      regs => {},
      program => [],
      inst => 0,
      sound => '',
      recovered => '',
    };
    bless $self, $class;

    for my $cmd (@program) {
      push @{ $self->{ program } }, $self->parse_cmd( $cmd );
     }

    return $self;
  }
}

my $input_file = $ARGV[0] || 'input18.txt';

my @input = path( $input_file )->lines_utf8( { chomp => 1 } );

my $duet = Duet->new( @input );

my $recovered = $duet->run();

print "The sound recovered is $recovered\n";

exit;
