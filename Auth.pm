package Email::Send::SMTP::Auth;
# $Id: Auth.pm,v 1.5 2004/07/08 03:23:38 Daddy Exp $

use Carp;
use Net::SMTP_auth;
use Email::Address;

use strict;

use vars qw( $VERSION $SMTP $VERBOSE );
$VERSION = do { my @r = (q$Revision: 1.5 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

BEGIN
  {
  $VERBOSE = 0;  # Unless our caller sets it otherwise
  } # end of BEGIN block

sub send
  {
  my $oMessage = shift;
  my $sSMTP = shift || '';
  my $sUsername = shift || '';
  my $sPassword = shift || '';
  if ($sSMTP ne '')
    {
    $SMTP->quit if ref $SMTP;
    $SMTP = Net::SMTP_auth->new($sSMTP);
    if ($sPassword ne '')
      {
      $SMTP->auth('LOGIN', $sUsername, $sPassword);
      unless ($SMTP->ok)
        {
        warn sprintf(" XXX SMTP server refused login with error %d: %s", $SMTP->code, $SMTP->message) if $VERBOSE;
        return 0;
        } # unless
      } # if sPassword
    } # if
  if (! ref $SMTP)
    {
    return 0;
    } # if
  # Make sure the from-address is good:
  my $sFrom = $oMessage->header('From');
  unless ($sFrom)
    {
    warn " XXX message has no 'From' header\n" if $VERBOSE;
    return 0;
    } # unless
  unless ($sFrom ne '')
    {
    warn " XXX message has empty 'From' header\n" if $VERBOSE;
    return 0;
    } # unless
  my $oFrom = (Email::Address->parse($sFrom))[0];
  unless (ref $oFrom)
    {
    warn " XXX 'From' header does not parse into an Email::Address\n" if $VERBOSE;
    return 0;
    } # unless
  # Make sure the to-address is good:
  my $sTo = $oMessage->header('To');
  unless ($sTo)
    {
    warn " XXX message has no 'To' header\n" if $VERBOSE;
    return 0;
    } # unless
  unless ($sTo ne '')
    {
    warn " XXX message has empty 'To' header\n" if $VERBOSE;
    return 0;
    } # unless
  my $oTo = (Email::Address->parse($sTo))[0];
  unless (ref $oTo)
    {
    warn " XXX 'To' header does not parse into an Email::Address\n" if $VERBOSE;
    return 0;
    } # unless
  # Now talk to the server:
  $SMTP->mail($oFrom->address);
  unless ($SMTP->ok)
    {
    warn sprintf(" XXX SMTP server refused 'from', with error %d: %s", $SMTP->code, $SMTP->message) if $VERBOSE;
    return 0;
    } # unless
  $SMTP->to($oTo->address);
  unless ($SMTP->ok)
    {
    warn sprintf(" XXX SMTP server refused 'to', with error %d: %s", $SMTP->code, $SMTP->message) if $VERBOSE;
    return 0;
    } # unless
  $SMTP->data($oMessage->as_string);
  unless ($SMTP->ok)
    {
    warn sprintf(" XXX SMTP server refused data, with error %d: %s", $SMTP->code, $SMTP->message) if $VERBOSE;
    return 0;
    } # unless
  return 1;
  } # send

sub DESTROY
  {
  $SMTP->quit if $SMTP;
  } # DESTROY

1;

__END__

=head1 NAME

Email::Send::SMTP::Auth - Send messages using SMTP with login/password

=head1 SYNOPSIS

  use Email::Send;
  send SMTP::Auth => $oMessage, 'smtp.example.com', 'userid', 'password';

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<Net::SMTP_auth> to send a
message via an SMTP server, with basic authorization.  The first
invocation of C<send> requires three arguments after the message: the
SMTP server name (or IP address), login account name, and password.
Subsequent calls will remember these settings until/unless they are
reset.

If your password is undef or empty-string, plain SMTP without
authorization will be used.

=head1 SEE ALSO

L<Email::Send>,
L<Net::SMTP_auth>,
L<Email::Address>,
L<perl>.

=head1 AUTHOR

Martin Thurn, <F<mthurn@cpan.org>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Martin Thurn.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut

