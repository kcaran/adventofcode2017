#!/usr/bin/perl
#
# $Id: pl.template,v 1.2 2014/07/18 15:01:38 caran Exp $
#
use strict;
use warnings;

sub test_anagram
 {
  my ($word_a, $word_b) = @_;

  # No need to check if words are equal or are different lengths
  return 1 if ($word_a eq $word_b);
  return if (length( $word_a ) != length( $word_b ));

  # Check if sorted characters are the same
  my (@chars_a) = sort split '', $word_a;
  my (@chars_b) = sort split '', $word_b;
  for (my $i = 0; $i < @chars_a; $i++) {
    return if ($chars_a[$i] ne $chars_b[$i]);
   }

  return 1;
 }

sub anagram_free
 {
  my ($phrase) = @_;
  my %test;
  for my $word (split /\s+/, $phrase) {
    for my $prev (keys %test) {
      return 0 if (test_anagram( $word, $prev ));
     }
    $test{ $word } = 1;
   }
  return 1;
 }

sub valid_passphrase
 {
  my ($phrase) = @_;
  my %test;

  for my $word (split /\s+/, $phrase) {
    return 0 if ($test{ $word });
    $test{ $word } = 1;
   }

  return 1;
 }

my $input_file = $ARGV[0] || 'input04.txt';

my $num_valid = 0;
my $no_anagrams = 0;
open my $input_fh, '<', $input_file or die $!; 
while (<$input_fh>) {
  chomp;
  $num_valid++ if (valid_passphrase( $_ ));
  $no_anagrams++ if (anagram_free( $_ ));
 }

print "The number of valid passphrases is $num_valid\n";
print "The number of part two valid passphrases is $no_anagrams\n";
