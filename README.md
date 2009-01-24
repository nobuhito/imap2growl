# NAME

IMAP2Growl

# SYNOPSIS

% imap2growl.pl

# DESCRIPTION

From IMAPserver's new mail to Growl.

# CONFIG

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

