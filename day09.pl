#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
# $ perl day09.pl $(cat input09.txt)
#
use strict;
use warnings;

{ package Stream;

  sub score {
   my $self = shift;

   return $self->{ score };
  }

  sub parse_input {
   my ($self, $input) = @_;

   my $len = length( $input );
   my $i = 0;
   my $curr_score = 0;
   my $in_junk = 0;
   while ($i < $len) {
     my $next_char = substr( $input, $i, 1 );
     $i++;

     # Skip next character
     if ($next_char eq '!') {
       $i++;
       next;
      }

     if ($next_char eq '<') {
       $in_junk = 1;
      }
     elsif ($next_char eq '>') {
       $in_junk = 0;
      }

     next if ($in_junk);

     if ($next_char eq '{') {
       $curr_score++;
      }
     elsif ($next_char eq '}') {
       $self->{ score } += $curr_score;
       $curr_score--;
      }
    } 

   # Finally, we should have a current score of 0
   die "Did not parse correctly" if ($curr_score);

   return;
  }
   
  sub new {
    my $class = shift;
    my $input = shift;
    my $self = {
		score => 0,
    };
    bless $self, $class;

    $self->parse_input( $input );

    return $self;
  }
}

my $input = $ARGV[0] || die "Please enter the input\n";

my $stream = Stream->new( $input );

print "The score for the input is ", $stream->score(), "\n";
