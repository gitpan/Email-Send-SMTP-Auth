
# $Id: Auth.pm,v 1.11 2006/01/08 03:16:57 Daddy Exp $

package Email::Send::SMTP::Auth;

use Carp;
use Email::Send::SMTP;

use strict;

use vars qw( $VERSION );
$VERSION = do { my @r = (q$Revision: 1.11 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

use constant DEBUG => 0;

sub is_available
  {
  return 1;
  } # is_available

sub send
  {
  my $class = shift;
  my $oMessage = shift;
  my $sSMTP = shift || '';
  my $sUsername = shift || '';
  my $sPassword = shift || '';
  return Email::Send::SMTP->send($oMessage,
                                 Host => $sSMTP,
                                 username => $sUsername,
                                 password => $sPassword,
                                );
  } # send

1;

=head1 NAME

Email::Send::SMTP::Auth - Send messages using SMTP with login/password

=head1 SYNOPSIS

  use Email::Send;
  send SMTP::Auth => $oMessage, 'smtp.example.com', 'userid', 'password';

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<Net::SMTP_auth> to send a
message via an SMTP server, with basic authorization.

If your password is undef or empty-string, plain SMTP without
authorization will be used.

=head1 SEE ALSO

L<Email::Send>,
L<Email::Send::SMTP>,
L<Email::Address>,
L<perl>.

=head1 AUTHOR

Martin Thurn, <F<mthurn@cpan.org>>.

=head1 COPYRIGHT

  Copyright (c) 2006 Martin Thurn.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut

__END__

