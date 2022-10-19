#!/usr/bin/env perl
use strict;
use warnings FATAL => qw/all/;
use 5.016;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Encode;
use Getopt::Long;
use File::Basename;

use YATT::Lite::XHF;

use JSON;

sub usage {
  die join("\n", @_, <<END);
Usage: $0 [-d OUTDIR]  FILES...
END

}

{

  GetOptions("d|outdir=s", \ (my $o_outdir)
             , "h|help",   \ (my $o_help)
           )
    or usage("Invalid option");
  usage() if $o_help;

  if ($o_outdir) {
    usage("Can't find outdir: $o_outdir") unless -d $o_outdir;
    usage("outdir is not writable: $o_outdir") unless -w $o_outdir;
  }

  foreach my $fn (@ARGV) {
    my $parser = YATT::Lite::XHF->new(file => $fn, encoding => 'utf8');

    # Read toplevel as dictionaries.
    my @data;
    # Metainfo. Maybe empty.
    if (defined (my $header = $parser->read(skip_comment => 0))) {
      push @data, $header;
    }

    # body.
    push @data, $_ while $_ = $parser->read;

    emit_json($fn, $o_outdir, \@data);
  }
}

sub emit_json {
  my ($fn, $o_outdir, $data) = @_;

  my $json = JSON->new->utf8->canonical;

  if ($o_outdir) {
    my $outfn = join("/", $o_outdir, basename($fn));
    $outfn =~ s/\.xhf$/.json/;
    open my $outFH, '>', $outfn or die "$outfn: $!";
    print $outFH $json->encode($_), "\n" for @$data;
  } else {
    print $json->encode($_), "\n" for @$data;
  }
}
