#!/usr/bin/env perl
use strict;
use warnings FATAL => qw/all/;
use FindBin;
use File::Basename;
use File::Spec;
use Encode;

use JSON;
use YAML::Syck;
use Test::More;

use Try::Tiny;

use Getopt::Long;

GetOptions(
  "q|quiet", \ (my $o_quiet),
  "J|jsonl",  \ (my $o_jsonl),
)
  or exit 1;

my $target_command = do {
  unless (@ARGV) {
    die <<END;
Usage: $0 TARGET_PROGRAM [OPTIONS for TARGET_PROGRAM...]

Try like following:

  $0 $FindBin::Bin/expected/xhf2yaml.pl

END
  }

  my $targ = File::Spec->rel2abs(shift @ARGV);
  -e $targ
    or BAIL_OUT("Can't find target!: $targ");

  join " ", $targ, @ARGV;
};

my $load_expected = __PACKAGE__->can("load_expected_"
                                     . ($o_jsonl ? "jsonl" : "yaml"));
my $parse_got     = __PACKAGE__->can("parse_got_"
                                     . ($o_jsonl ? "jsonl" : "yaml"));

my @tests = <$FindBin::Bin/inputs/*.xhf>;

plan tests => scalar @tests;

foreach my $fn (@tests) {
  my $title = substr($fn, length($FindBin::Bin) + 1);
  print "# testing $fn\n" unless $o_quiet;

  local $@;
  eval {
    my $expected = $load_expected->($fn);

    my $got = do {
      my $cmd = qq($target_command $fn);
      print "# Running $cmd...\n" unless $o_quiet;
      $parse_got->(scalar qx($cmd));
    };

    is_deeply $got, $expected, $title;
  };

  if ($@) {
    BAIL_OUT("Test $fn died with error for test $fn: Reason: $@");
  }
}

sub load_expected_yaml {
  my ($fn) = @_;
  my $expFn = "$FindBin::Bin/expected/".basename($fn);
  $expFn =~ s/\.xhf$/\.yaml/;
  YAML::Syck::LoadFile($expFn);
}

sub parse_got_yaml {
  my ($yaml) = @_;
  YAML::Syck::Load($yaml);
}

sub load_expected_jsonl {
  my ($fn) = @_;
  my $expFn = "$FindBin::Bin/expected_jsonl/".basename($fn);
  $expFn =~ s/\.xhf$/\.jsonl/;

  my @json;
  open my $fh, '<', $expFn or die "Can't open $expFn: $!";
  while (my $line = <$fh>) {
    chomp($line);
    my $json;
    try {
      $json = JSON->new->utf8->decode($line)
    }
    catch {
      die "Can't parse jsonl file $expFn: $_ ($line)";
    };
    push @json, $json;
  }

  \@json
}

sub parse_got_jsonl {
  my ($jsonl) = @_;
  [map {
    JSON->new->utf8->decode($_)
  } split "\n", $jsonl]
}

