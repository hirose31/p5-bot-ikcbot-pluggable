#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Carp;

use Pod::Usage;
use Encode;
use POE::Component::IKC::ClientLite;
use String::IRC;

our $channel;
our $ikc_ip   = '127.0.0.1',
our $ikc_port = 1919;
our $bot_name = 'ikchan',
eval { require "ikcbot-config.pl" };

$ARGV[0] && $ARGV[0] =~ /^--?h/
    and pod2usage(-exitval => 1, -verbose => 2);

@ARGV >= 2
    or  pod2usage(-msg=> "missing args",
                  -exitval => 1, -verbose => 1);

$channel = shift @ARGV;
$channel =~ /^#/
    or  pod2usage(-msg=> "invalid channel name: $channel",
                  -exitval => 1, -verbose => 1);

my $msg = join ' ', @ARGV;
$msg = decode('euc_jp', $msg);
$msg =~ s/[\r\n]/ /g;

$msg =~ s/(warning)/String::IRC->new($1)->black('yellow')->bold->stringify/ei;
$msg =~ s/(critical)/String::IRC->new($1)->black('red')->bold->stringify/ei;
$msg =~ s/(recovery)/String::IRC->new($1)->black('green')->bold->stringify/ei;
$msg =~ s/\b(OK)\b/String::IRC->new($1)->black('green')->bold->stringify/e;

utf8::encode($msg) if utf8::is_utf8($msg);


my $ikc = POE::Component::IKC::ClientLite::create_ikc_client(
    ip      => $ikc_ip,
    port    => $ikc_port,
    name    => 'notify-irc',
    timeout => 5,
   ) or croak $!;

$ikc->post($bot_name.'_IKC/notice', { body => $msg, channel => $channel });

exit;

__END__

=head1 NAME

B<notify-alert-to-irc.pl> - notify alert message to IRC channel.

=head1 SYNOPSIS

B<notify-alert-to-irc.pl> I<channel> I<message> [ I<message> I<...> ]

=head1 OPTIONS

=over 4

=item B<channel>

IRC channel name that you want to post alert message.

=item B<message>

Alert message.

multiple messages are concatenated by space.

=back

=head1 EXAMPLE

  define command {
    command_name  notify-service-by-irc
    command_line  /usr/irori/bin/notify-alert-to-irc.pl '#scramble' "$NOTIFICATIONTYPE$ Service: $SERVICEDESC$ Host: $HOSTALIAS$ Address: $HOSTADDRESS$ State: $SERVICESTATE$" "Date/Time: $SHORTDATETIME$" "- Additional Info: $SERVICEOUTPUT$"
  }

=cut

# for Emacsen
# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8
# End:

# vi: set ts=4 sw=4 sts=0 :
