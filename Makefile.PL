
use inc::Module::Install;

name('Email-Send-SMTP-Auth');
version_from('Auth.pm');

author('Martin Thurn <mthurn@cpan.org>');
license('perl');

requires( perl => '5.004' );
build_requires('Data::Dumper');
requires('Email::Address');
build_requires('Email::Abstract::EmailSimple');
build_requires('Email::Send');
build_requires('Email::Simple');
# Module::Pluggable is required when we use Email::Send, but not to
# install Email::Send!?!
build_requires('Module::Pluggable');
requires('Net::SMTP_auth');

check_nmake();      # check and download nmake.exe for Win32
&Makefile->write;

sub MY::postamble
  {
  my $ret = <<'PART0';
coverage :
	cover -delete
	$(MAKE) HARNESS_PERL_SWITCHES=-MDevel::Cover coverage_slave
coverage_slave : test
	cover
PART0
  return $ret;
  } # MY::postamble

__END__
