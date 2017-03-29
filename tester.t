#!/usr/bin/env perl
use strict;
use warnings FATAL => qw/all/;
use FindBin;
use File::Basename;
use File::Spec;
use Encode;

use YAML::Syck;
use Test::More;

use Getopt::Long;

GetOptions("q|quiet", \ (my $o_quiet))
  or exit 1;

my $target_program = do {
  if (@ARGV) {
    my ($targ) = map {File::Spec->rel2abs($_)} shift @ARGV;
    -x $targ
      or BAIL_OUT("Can't exec specified executable: $targ");
    $targ;
  } else {
    $ENV{TARGET} || "$FindBin::Bin/expected/xhf2yaml.pl";
  }
};

my $run_prefix = "";
if ($target_program =~ /\.exe$/) {
  $run_prefix = "mono ";
}

my @tests = <$FindBin::Bin/inputs/*.xhf>;

plan tests => scalar @tests;

foreach my $fn (@tests) {
  my $title = substr($fn, length($FindBin::Bin) + 1);
  local $@;
  eval {
    my $expected = do {
      my $expFn = "$FindBin::Bin/expected/".basename($fn);
      $expFn =~ s/\.xhf$/\.yaml/;
      YAML::Syck::LoadFile($expFn);
    };

    my $got = do {
      my $cmd = qq($run_prefix$target_program $fn);
      print "# Running $cmd...\n" unless $o_quiet;
      my $yaml = qx($cmd);
      YAML::Syck::Load($yaml);
    };

    is_deeply $got, $expected, $title;
  };

  if ($@) {
    BAIL_OUT("Test $fn died with error! Reason: $@");
  }
}

