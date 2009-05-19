#!/usr/bin/env perl

use strict;
use warnings;
use FindBin::libs;

use Bot::IKCBot::Pluggable;

my $ikc_ip   = '127.0.0.1',
my $ikc_port = 1919;
my $bot_name = 'ikchan',
my $channel  = '#test1919';

my $bot = Bot::IKCBot::Pluggable->new(
    channels => [$channel],
    server   => "irc.example.com",
    port     => "6667",

    nick     => "pluggabot",
    altnicks => ["pbot", "pluggable"],
    username => "bot",
    name     => "Yet Another Pluggable Bot",

    ignore_list => [qw(shingo- shingo--)],

    verbose => 1,

    ALIASNAME => $bot_name,

    ikc_ip   => 0,
    ikc_port => 1919,
   );

$bot->load("Karma");
$bot->load("Join");

$bot->run;

__END__

# for Emacsen
# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8
# End:

# vi: set ts=4 sw=4 sts=0 :
