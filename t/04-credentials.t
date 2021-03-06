# Copyright (C) 2017 Koha-Suomi
#
# This file is part of Pootle-Client.

use Modern::Perl '2015';
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use feature 'signatures'; no warnings "experimental::signatures";
use Carp::Always;
use Try::Tiny;
use Scalar::Util qw(blessed);
use Data::Dumper;

use Test::More;
use File::Temp;

use Pootle::Client;

use t::Mock::Client;


subtest "Load credentials from a file", \&credentialsFromFile;
sub credentialsFromFile {
  my ($fh, $filename, $papi);
  eval {

  #Write a file with nothing but the credentials
  ($fh, $filename) = File::Temp::tempfile();
  print $fh "username:password";
  close $fh;

  ok($papi = t::Mock::Client::new('http://translate.example.org', $filename),
    "Given a Pootle::Client connection, with credentials from a file");


  #Write other extra stuff to document the credentials file
  ($fh, $filename) = File::Temp::tempfile();
  print $fh <<TEXT;
#This is a credentials file, Pootle::Client gets its credentials from here

username:password

#Thanks!
TEXT
  close $fh;

  ok($papi = t::Mock::Client::new('http://translate.example.org', $filename),
    "Given a Pootle::Client connection, with credentials from a bloated file");

  };
  if ($@) {
    ok(0, $@);
  }
};

subtest "Load bad credentials from a file", \&badCredentialsFromFile;
sub badCredentialsFromFile {
  my ($fh, $filename, $papi);
  eval {

  ($fh, $filename) = File::Temp::tempfile();
  print $fh "username-password";
  close $fh;

  try {
    $papi = t::Mock::Client::new('http://translate.example.org', $filename);
    ok(0, "\$Pootle-Client should crash due to bad credentials from a file");
  } catch {
    ok(blessed($_) && $_->isa('Pootle::Exception::Credentials'),
       "Received proper Credentials-exception");
    like($_, qr/$filename/, "Faulting filename mentioned in exception");
  };

  };
  if ($@) {
    ok(0, $@);
  }
};

done_testing();
