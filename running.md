#summary How to run compiled GnuPG ECC binary
#labels Phase-Deploy,Featured

# Introduction #

This document is a walkthrough for the steps needed to encrypt a message with a newly generated ECC key.

# Setup #

Click [Downloads](http://code.google.com/p/gnupg-ecc/downloads/list) tab on the [gnupg-ecc project](http://code.google.com/p/gnupg-ecc/) and download a suitable binary for your platform. This document will be using `gpg2ecc-2.1.0-r17.x86_64.tar.bz2` as an example.

```
    # Download the file into /tmp/_
    [user@host ~]$ wget http://gnupg-ecc.googlecode.com/files/gpg2ecc-2.1.0-r17.x86_64.tar.bz2 -O /tmp/_
```

Check that file is downloaded properly:

```
   [user@host ~]$ sha1sum /tmp/_
   # compare the SHA-1 sum with the one listed on the download page 
```

Check the content of the file:

```
   [user@host ~]$ tar -jtvf /tmp/_
   drwxr-xr-x root/root         0 2010-09-18 18:40 gpg2ecc-2.1.0-r17.x86_64/
   drwxr-xr-x root/root         0 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/lib/
   -rw-r--r-- root/root   2707526 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/lib/libgcrypt.a
   lrwxrwxrwx root/root         0 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libgpg-error.so.0 -> libgpg-error.so.0.7.0
   lrwxrwxrwx root/root         0 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libgpg-error.so -> libgpg-error.so.0.7.0
   -rwxr-xr-x root/root       971 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libgpg-error.la
   lrwxrwxrwx root/root         0 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/lib/libgcrypt.so -> libgcrypt.so.11.6.0
   -rwxr-xr-x root/root       990 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libassuan.la
   -rwxr-xr-x root/root     44169 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libgpg-error.so.0.7.0
   -rwxr-xr-x root/root    347756 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libassuan.so.0.1.0
   lrwxrwxrwx root/root         0 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libassuan.so -> libassuan.so.0.1.0
   lrwxrwxrwx root/root         0 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/lib/libassuan.so.0 -> libassuan.so.0.1.0
   -rwxr-xr-x root/root       871 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/lib/libgcrypt.la
   lrwxrwxrwx root/root         0 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/lib/libgcrypt.so.11 -> libgcrypt.so.11.6.0
   -rwxr-xr-x root/root   1275750 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/lib/libgcrypt.so.11.6.0
   drwxr-xr-x root/root         0 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/
   -rwxr-xr-x root/root   1048940 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpgsm
   -rwxr-xr-x root/root    318567 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/kbxutil
   -rwxr-xr-x root/root     21524 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/bin/dumpsexp
   -rwxr-xr-x root/root      1825 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/bin/gpg-error-config
   -rwxr-xr-x root/root    715155 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpg-agent
   -rwxr-xr-x root/root   1022429 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpgv2
   -rwxr-xr-x root/root     49740 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/bin/gpg-error
   -rwxr-xr-x root/root      2387 2010-09-18 18:38 gpg2ecc-2.1.0-r17.x86_64/bin/libassuan-config
   -rwxr-xr-x root/root      3756 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/bin/libgcrypt-config
   -rwxr-xr-x root/root    731858 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/scdaemon
   -rwxr-xr-x root/root      4635 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpgsm-gencert.sh
   -rwxr-xr-x root/root     21115 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/watchgnupg
   -rwxr-xr-x root/root   2005247 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpg2
   -rwxr-xr-x root/root    108338 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpgkey2ssh
   -rwxr-xr-x root/root     23508 2010-09-18 18:39 gpg2ecc-2.1.0-r17.x86_64/bin/hmac256
   -rwxr-xr-x root/root     47222 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpgparsemail
   -rwxr-xr-x root/root    382513 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpg-connect-agent
   -rwxr-xr-x root/root    321142 2010-09-18 18:46 gpg2ecc-2.1.0-r17.x86_64/bin/gpgconf
   ...
```

Place it into /usr/local/gpg2ecc and set up the environment:

```
   [user@host ~]$ tar -jxvf /tmp/_
   [user@host ~]$ su
   # the location /usr/local/gpg2ecc is required
   [user@host ~]$ mv -Rvp gpg2ecc-2.1.0-r17.x86_64 /usr/local/gpg2ecc
   [user@host ~]$ export LD_LIBRARY_PATH=/usr/local/gpg2ecc/lib/
   
   # we will be re-using existing pinentry
   [user@host ~]$ ln -s /usr/bin/pinentry /usr/local/gpg2ecc/bin/pinentry
```

For convenience let's set the shortcut, so that our version of gpg2 is invoked as gpg2ecc:

```
   [user@host ~]$ ln /usr/local/gpg2ecc/bin/gpg2 /usr/local/bin/gpg2ecc
   [user@host ~]$ exit
```

You should now see ECC options:
```
   [user@host ~]$ gpg2ecc --version | grep Pub
   Pubkey: RSA, ELG, DSA, ECDH, ECDSA
```

Before we generate new key, let's save the current keyring (don't forget to copy it back). For demonstration purpose we effectively hide current keys from gnupg. Alternatively, we can simply use `cp` bellow, because new ECC keys co-exist perfectly with present public keys, like RSA keys.

```
   [user@host ~]$ mv -vb ~/.gnupg/pubring.gpg ~/.gnupg/pubring_saved.gpg
   [user@host ~]$ mv -vb ~/.gnupg/secring.gpg ~/.gnupg/secring_saved.gpg
```

# Key generation #

The following single invocation, plus all the default answers except user ID, generates an ECC key:

```
	[user@host ~]$ gpg2ecc  --gen-key
	gpg (GnuPG) 2.1.0; Copyright (C) 2009 Free Software Foundation, Inc.
	This is free software: you are free to change and redistribute it.
	There is NO WARRANTY, to the extent permitted by law.

	Please select what kind of key you want:
	   (1) RSA and RSA (default)
	   (2) DSA and Elgamal
	   (3) DSA (sign only)
	   (4) RSA (sign only)
	   (9) ECDSA and ECDH
	Your selection? 9
	ECDSA keys may be between 256 and 521 bits long.
	What keysize do you want? (256) 
	Requested keysize is 256 bits
	Please specify how long the key should be valid.
			 0 = key does not expire
		  <n>  = key expires in n days
		  <n>w = key expires in n weeks
		  <n>m = key expires in n months
		  <n>y = key expires in n years
	Key is valid for? (0) 
	Key does not expire at all
	Is this correct? (y/N) y

	GnuPG needs to construct a user ID to identify your key.

	Real name: ECC Test
	Email address: ecc_test@domail.com
	Comment: 
	You selected this USER-ID:
		"ECC Test <ecc_test@domail.com>"

	Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
	You need a Passphrase to protect your secret key.
	<The PIN entry dialog pops up, set a passphrase there>

	We need to generate a lot of random bytes. It is a good idea to perform
	some other action (type on the keyboard, move the mouse, utilize the
	disks) during the prime generation; this gives the random number
	generator a better chance to gain enough entropy.
	We need to generate a lot of random bytes. It is a good idea to perform
	some other action (type on the keyboard, move the mouse, utilize the
	disks) during the prime generation; this gives the random number
	generator a better chance to gain enough entropy.
	gpg: key F72753B5 marked as ultimately trusted
	public and secret key created and signed.

	gpg: checking the trustdb
	gpg: public key of ultimately trusted key 3188175A not found
	gpg: public key of ultimately trusted key A4276C3A not found
	gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
	gpg: depth: 0  valid:   3  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 3u
	pub    256E/F72753B5 2010-10-15
		  Key fingerprint = 4614 A0AF 9450 BF51 AE9F  BB5C F126 22B6 F727 53B5
	uid                  ECC Test <ecc_test@domail.com>
	sub    256e/0D063282 2010-10-15
```

This is how does the new key look. The only difference with other keys here that you may notice is smaller bit size and that ECC keys are marked with

| E | ECC signing key/subkey |
|:--|:-----------------------|
| e | ECC encryption subkey  |

```
	[user@host ~]$ gpg2ecc --list-keys
	/encr/home/.gnupg/pubring.gpg
	-------------------------------
	pub    256E/F72753B5 2010-10-15
	uid                  ECC Test <ecc_test@domail.com>
	sub    256e/0D063282 2010-10-15
```

# Usage #

The rest of the document shows how this key can be used. Note that the behaviour is identical as if you have generated an RSA key above.

## Message signing ##

```
	[user@host ~]$ echo "Message" > _
	[user@host ~]$ gpg2ecc --sign -a _

	You need a passphrase to unlock the secret key for
	user: "ECC Test <ecc_test@domail.com>"
	256-bit ECDSA key, ID F72753B5, created 2010-10-15
	<The PIN entry dialog pops up, enter the passphrase there>
```

## Message verification ##

```
	[usery@host ~]$ gpg2ecc _.asc 
	File `_' exists. Overwrite? (y/N) n
	Enter new filename: __
	gpg: Signature made Thu 14 Oct 2010 05:12:34 PM PDT using ECDSA key ID F72753B5
	gpg: Good signature from "ECC Test <ecc_test@domail.com>"
```

## Message encryption ##

```
	[user@host ~] gpg2ecc --encrypt -r Test -a  -o _e.asc _
```

## Message decryption ##

```
	[user@host ~]$ gpg2ecc _e.asc 

	You need a passphrase to unlock the secret key for
	user: "ECC Test <ecc_test@domail.com>"
	256-bit ECDH key, ID 0D063282, created 2010-10-15 (main key ID F72753B5)
	<The PIN entry dialog pops up, enter the passphrase there>

	gpg: encrypted with 256-bit ECDH key, ID 0D063282, created 2010-10-15
		  "ECC Test <ecc_test@domail.com>"

	[user@host ~]$ diff _e _ && echo OK
	OK
```