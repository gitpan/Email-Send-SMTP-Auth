package Email::Send::SMTP::Auth;
# $Id: Auth.pm,v 1.7 2004/12/29 02:41:52 Daddy Exp $

use Carp;
use Net::SMTP_auth;
use Email::Address;

use strict;

use vars qw( $VERSION $SMTP $VERBOSE );
$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf "%d."."%03d" x $#r, @r };

BEGIN
  {
  $VERBOSE = 0;  # Unless our caller sets it otherwise
  } # end of BEGIN block
use constant DEBUG => 0;

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
  # Make sure the to-addresses are good:
  my @asToAddr;
 TO_ADDR_HEADER:
  foreach my $sWhere (qw( To Cc Bcc ))
    {
    my $sHeader = $oMessage->header($sWhere);
    DEBUG && warn " DDD got header=$sHeader= from header=$sWhere=\n";
    next TO_ADDR_HEADER unless (defined $sHeader);
    next TO_ADDR_HEADER unless ($sHeader ne '');
 TO_ADDR:
    foreach my $oAddr (Email::Address->parse($sHeader))
      {
      DEBUG && warn " DDD got o=$oAddr= from header=$sWhere=\n";
      unless (ref $oAddr)
        {
        warn " XXX '$sWhere' portion '$sHeader' does not parse into an Email::Address\n" if $VERBOSE;
        next TO_ADDR;
        } # unless
      my $sAddr = $oAddr->address;
      DEBUG && warn " DDD got addr=$sAddr= from header=$sWhere=\n";
      push @asToAddr, $sAddr;
      } # foreach TO_ADDR
    } # foreach TO_ADDR_HEADER
  # Now talk to the server:
  $SMTP->mail($oFrom->address);
  unless ($SMTP->ok)
    {
    warn sprintf(" XXX SMTP server refused 'from', with error %d: %s", $SMTP->code, $SMTP->message) if $VERBOSE;
    return 0;
    } # unless
  foreach my $sAddr (@asToAddr)
    {
    $SMTP->to($sAddr);
    unless ($SMTP->ok)
      {
      warn sprintf(" XXX SMTP server refused recipient '%s', with error %d: %s",
                   $sAddr, $SMTP->code, $SMTP->message) if $VERBOSE;
      return 0;
      } # unless
    } # foreach
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

