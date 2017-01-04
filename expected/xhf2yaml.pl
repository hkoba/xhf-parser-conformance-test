#!/usr/bin/env perl
use strict;
use warnings FATAL => qw/all/;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Encode;

use YATT::Lite::XHF;
use YAML::Tiny;

foreach my $fn (@ARGV) {
  my $parser = YATT::Lite::XHF->new(file => $fn, encoding => 'utf8');

  my @data;
  push @data, scalar $parser->read(skip_comment => 0);
  push @data, $_ while $_ = $parser->read;

  print encode_utf8(YAML::Tiny->new(@data)->write_string);
}
