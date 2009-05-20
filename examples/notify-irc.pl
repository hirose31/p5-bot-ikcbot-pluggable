#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Carp;

use Encode;
use POE::Component::IKC::ClientLite;

my $ikc_ip   = '127.0.0.1',
my $ikc_port = 1919;
my $bot_name = 'ikchan',
my $channel  = '#test1919';

my $ikc = POE::Component::IKC::ClientLite::create_ikc_client(
    ip      => $ikc_ip,
    port    => $ikc_port,
    name    => 'notify-irc',
    timeout => 5,
   ) or croak $!;

my $msg;
if (@ARGV) {
    $msg = join ' ', @ARGV;
    $msg = decode('euc_jp', $msg);
} else {
    $msg = do { local $/; <> };
}
$msg =~ s/[\r\n]/ /g;

utf8::encode($msg) if utf8::is_utf8($msg);
$ikc->post($bot_name.'_IKC/say', { body => $msg, channel => $channel });
exit;

__END__

# for Emacsen
# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8
# End:

# vi: set ts=4 sw=4 sts=0 :
