#!/usr/bin/env perl
 
use strict;
use warnings;
 
use Net::Growl;
use Net::IMAP::Simple;
use Email::MIME;
use YAML;
use File::HomeDir;
 
our $app = 'IMAP2Growl';
 
my $config_file = File::HomeDir->my_home . '/.imap2growl.yaml';
 
my $c = YAML::LoadFile($config_file) || {};
my ($imap_conf, $growl_conf) = map {
    (ref $c->{$_} eq 'ARRAY')? $c->{$_}: [$c->{$_}];
  } qw/imap growl/;
 
foreach (@$imap_conf) {
  $_->{folder} ||= 'INBOX';
  
  register(
      application => $app,
      host => $_->{host},
      password => $_->{pass},
    ) foreach (@$growl_conf);
  
  my $imap = Net::IMAP::Simple->new($_->{host})
    or to_growl('Error', "Unable to connect.\n". $Net::IMAP::Simple::errstr);
 
  $imap->login($_->{user}, $_->{pass})
    or to_growl('Error', "Login failed.\n". $imap->errstr);
  
  my $new_count = $imap->recent;
  my $full_count = $imap->select($_->{folder});
  for (my $i=$full_count; $i > $full_count-$new_count; $i--) {
    my $email = Email::MIME->new(join('', @{$imap->top($i)}));
    my $subject = $email->header('Subject') || 'No subject';
    my $from = $email->header('From') || 'No from';
    to_growl("$subject\n".$_->{host}, $from);
  }
}
 
sub to_growl {
  my ($message, $description) = @_;
  notify(
      title => $message,
      description => $description,
      application => $app,
      password => $_->{pass},
    ) foreach (@$growl_conf);
  exit if ($message eq 'Error');
}
 
__END__
 
=head1 NAME
 
IMAP2Growl
 
=head1 SYNOPSIS
 
% imap2growl.pl
 
=head1 DESCRIPTION
 
From IMAPserver's new mail to Growl.
 
=head1 CONFIG
 
in ~/.imap2growl.yaml
 
imap:
host: localhost
user: userid
pass: password
folder: INBOX optional
 
growl:
host: localhost
pass: password
 
or
 
imap:
- host: localhost
user: userid
pass: password
folder: INOBX
- host: localhost
user: userid
pass: password
folder: spam
 
growl:
- host: localhost
pass: password
- host: 192.168.0.1
pass: passwd
 
=cut
