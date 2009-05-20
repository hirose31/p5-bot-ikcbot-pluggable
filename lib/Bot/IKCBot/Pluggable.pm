package Bot::IKCBot::Pluggable;

use warnings;
use strict;

our $VERSION = '0.01';

use base qw( Bot::BasicBot::Pluggable );
use POE;
use POE::Session;
use POE::Component::IKC::Server;

our $STATE_TABLE = {
    say    => 'hearsay',
    notice => 'hearnotice',
};

sub run {
    my $self = shift;

    POE::Component::IKC::Server::create_ikc_server(
        ip   => $self->{ikc_ip},
        port => $self->{ikc_port},
        name => 'IKC',
       );

    POE::Session->create(
        object_states => [
            $self => {
                _start => 'start_state_ikc',
                %$STATE_TABLE,
            }
           ]
       );

    $self->SUPER::run($self);
}

sub start_state_ikc {
    my($self, $kernel, $session) = @_[ OBJECT, KERNEL, SESSION ];
    $self->{kernel}  = $kernel;
    $self->{session} = $session;

    $kernel->alias_set($self->{ALIASNAME}."_IKC");

    $kernel->call( IKC => publish => $self->{ALIASNAME}."_IKC" => [keys %$STATE_TABLE] );
}

sub hearsay {
    my($self, $arg) = @_[ OBJECT, ARG0 ];
    $self->say($arg);
}

sub hearnotice {
    my($self, $arg) = @_[ OBJECT, ARG0 ];
    $self->notice($arg);
}

# just Bot::BasicBot::say =~ s/privmsg/notice/g
sub notice {
    # If we're called without an object ref, then we're handling saying
    # stuff from inside a forked subroutine, so we'll freeze it, and toss
    # it out on STDOUT so that POE::Wheel::Run's handler can pick it up.
    if ( !ref( $_[0] ) ) {
        print $_[0] . "\n";
        return 1;
    }

    # Otherwise, this is a standard object method

    my $self = shift;
    my $args;
    if (ref($_[0])) {
        $args = shift;
    } else {
        my %args = @_;
        $args = \%args;
    }

    my $body = $args->{body};

    # add the "Foo: bar" at the start
    $body = "$args->{who}: $body"
        if ( $args->{channel} ne "msg" and $args->{address} );

    # work out who we're going to send the message to
    my $who = ( $args->{channel} eq "msg" ) ? $args->{who} : $args->{channel};

    unless ( $who && $body ) {
        print STDERR "Can't NOTICE without target and body\n";
        print STDERR " called from ".([caller]->[0])." line ".([caller]->[2])."\n";
        print STDERR " who = '$who'\n body = '$body'\n";
        return;
    }

    # if we have a long body, split it up..
    local $Text::Wrap::columns = 300;
    local $Text::Wrap::unexpand = 0;             # no tabs
    my $wrapped = Text::Wrap::wrap('', '..', $body); #  =~ m!(.{1,300})!g;
    # I think the Text::Wrap docs lie - it doesn't do anything special
    # in list context
    my @bodies = split(/\n+/, $wrapped);

    # post an event that will send the message
    for my $body (@bodies) {
        my ($who, $body) = $self->charset_encode($who, $body);
        #warn "$who => $body\n";
        $poe_kernel->post( $self->{IRCNAME}, 'notice', $who, $body );
    }
}

# use notice instead of say (privmsg) when bot's reply
sub reply {
    my $self = shift;
    my ($mess, $body) = @_;
    my %hash = %$mess;
    $hash{body} = $body;
    return $self->notice(%hash);
}

=head1 NAME

Bot::IKCBot::Pluggable - The great new Bot::IKCBot::Pluggable!

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Bot::IKCBot::Pluggable;

    my $foo = Bot::IKCBot::Pluggable->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head1 AUTHOR

HIROSE Masaaki, C<< <hirose31 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-bot-ikcbot-pluggable at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Bot-IKCBot-Pluggable>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Bot::IKCBot::Pluggable


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Bot-IKCBot-Pluggable>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Bot-IKCBot-Pluggable>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Bot-IKCBot-Pluggable>

=item * Search CPAN

L<http://search.cpan.org/dist/Bot-IKCBot-Pluggable/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 HIROSE Masaaki, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Bot::IKCBot::Pluggable

__END__

# for Emacsen
# Local Variables:
# mode: cperl
# cperl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8
# End:

# vi: set ts=4 sw=4 sts=0 :
