#!/usr/bin/env perl
use strict;
use warnings FATAL => qw/all/;
use FindBin;
use File::Basename;
use Encode;

use YAML::Tiny;
use Test::More;

my $target_program = $ENV{TARGET} || "$FindBin::Bin/expected/xhf2yaml.pl";

my @tests = <inputs/*.xhf>;

plan tests => scalar @tests;

foreach my $fn (@tests) {
  local $@;
  eval {
    my $expected = do {
      my $expFn = "expected/".basename($fn);
      $expFn =~ s/\.xhf$/\.yaml/;
      YAML::Tiny->read($expFn);
    };

    my $got = do {
      my $yaml = qx($target_program $fn);
      YAML::Tiny->read_string(decode_utf8 $yaml);
    };

    is_deeply $got, $expected, $fn;
  };

  if ($@) {
    BAIL_OUT("Test $fn died with error! Reason: $@");
  }
}

