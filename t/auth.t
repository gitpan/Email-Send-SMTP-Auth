use ExtUtils::testlib;
use Test::More no_plan;

use strict;

BEGIN
  {
  use_ok('Data::Dumper');
  use_ok('Email::Send');
  use_ok('Email::Send::SMTP::Auth');
  use_ok('Email::Simple');
  use_ok('Email::Abstract::EmailSimple');
  use_ok('User');
  } # end of BEGIN block
$Email::Send::SMTP::Auth::VERBOSE = 1;
my $sSMTPserver = $ENV{SMTPSERVER} || 'your SMTP server';
my $sFrom = $ENV{SMTPTESTFROM} || '';
my $sTo = $ENV{SMTPTESTTO} || '';
my $sCc = $ENV{SMTPTESTCC} || '';
my $sBcc = $ENV{SMTPTESTBCC} || '';
my $sDTG = scalar(localtime);
SKIP:
  {
  my $iSkip = 0;
  if ($sSMTPserver eq 'your SMTP server')
    {
    diag(qq{The SMTPSERVER environment variable is not set.  Its value should be the SMTP server name or IP address.});
    $iSkip++;
    }
  if ($sFrom eq '')
    {
    diag(qq{The SMTPTESTFROM environment variable is not set.  Its value should be an address authorized to send email via $sSMTPserver.});
    $iSkip++;
    } # if
  if ($sTo eq '')
    {
    diag(qq{The SMTPTESTTO environment variable is not set.  Its value should be an address to which a test email can be sent.});
    $iSkip++;
    } # if
  if ($sCc eq '')
    {
    diag(qq{The SMTPTESTCC environment variable is not set.  Its value should be an address to which a test email can be sent.});
    } # if
  if ($sBcc eq '')
    {
    diag(qq{The SMTPTESTBCC environment variable is not set.  Its value should be an address to which a test email can be sent.});
    } # if
  my $sUsername = $ENV{SMTPUSERNAME} || 'that username';
  diag(qq{The SMTPUSERNAME environment variable is not set.  Its value should be a valid login name, if $sSMTPserver requires you to log in.}) unless ($sUsername ne 'that username');
  my $sPassword = $ENV{SMTPPASSWORD} || '';
  diag(qq{The SMTPPASSWORD environment variable is not set.  Its value should be the password for $sUsername, if $sSMTPserver requires you to log in.}) unless ($sPassword ne '');
  # Need to send empty-string (not empty-parens or no-args) to prevent
  # undef warning:
  my $oMessage = Email::Simple->new('');
  isa_ok($oMessage, 'Email::Simple');
  ok $oMessage->body_set(qq{This is a test email.
It was sent from $sFrom
It was sent to   $sTo
It was sent Cc   $sCc
It was sent Bcc  $sBcc
It was sent via  $sSMTPserver
It was sent at   $sDTG
});
  ok $oMessage->header_set('Subject', 'test message sent by Email-Send-SMTP-Auth t/auth.t');

  skip "No test email can be sent, because of missing environment variables.", 3 if $iSkip;
  diag(qq{Test email will be sent From: =$sFrom=});
  diag(qq{Test email will be sent   To: =$sTo=});
  diag(qq{Test email will be sent   Cc: =$sCc=});
  diag(qq{Test email will be sent  Bcc: =$sBcc=});
  diag(qq{Test email will be sent  via: =$sSMTPserver=});
  diag(qq{Test email was     sent   at: =$sDTG=});
  ok $oMessage->header_set('From', $sFrom);
  ok $oMessage->header_set('To', $sTo);
  ok $oMessage->header_set('Cc', $sCc) if ($sCc ne '');
  ok $oMessage->header_set('Bcc', $sBcc) if ($sBcc ne '');
  ok send 'SMTP::Auth' => $oMessage, $sSMTPserver, $sUsername, $sPassword;
  } # end of SKIP block
