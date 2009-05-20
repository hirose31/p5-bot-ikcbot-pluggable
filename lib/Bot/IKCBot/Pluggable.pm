package Bot::IKCBot::Pluggable;

use warnings;
use strict;

our $VERSION = '0.01';

use POE qw(
              Session
              Component::IKC::Server
         );
use base qw( Bot::BasicBot::Pluggable );

our $STATE_TABLE = {
    say => 'hearsay',
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
