### Summary ###

This project brought to life Elliptic Curve Cryptography support in OpenPGP as an end-user feature. Users can simply select an ECC key generation option in

```
   gpg2 --gen-key 
```

and then use the generated public key as they normally would use any other public key, as shown [here](running.md).

The implementation follows the [ECC in OpenPGP RFC6637](http://tools.ietf.org/html/rfc6637), an IETF standards track specification.

The main goals of this project are:
  * adoption of ECC in OpenPGP,
  * [NSA Suite B](http://www.nsa.gov/ia/programs/suiteb_cryptography/) compliance at the AES 256 bit strength (equivalent to TOP SECRET level).

[Sample Keys and messages](https://sites.google.com/site/brainhub/pgpecckeys) are available.

See the single changeset **[r15](https://code.google.com/p/gnupg-ecc/source/detail?r=15)** for what does it take to implement ECDSA and ECDH public key support in GnuPG. That's all the changes. You can browse the source at [gpg2ecc](http://code.google.com/p/gnupg-ecc/source/browse/#svn/branches/gpg2ecc).

The ECC support accomplished in this project was **successfully merged** into mainline GnuPG v.2 source tree in Feb 2011. We look forward to see these GnuPG changes propagate into a public release so that they are available in end-user packages.

The latest GnuPG release with ECC support is referenced bellow:

| **Component name** | **reference at [GnuPG](http://gnupg.org)** |
|:-------------------|:-------------------------------------------|
| libgcrypt 1.5.0| [source](ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.5.0.tar.gz)  [.sig](ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.5.0.tar.gz) _SHA-1 checksum_ e6508315b76eaf3d0df453f67371b106654bd4fe |
| GnuPG 2.1.0 beta| [source](ftp://ftp.gnupg.org/gcrypt/gnupg/unstable/gnupg-2.1.0beta2.tar.bz2) [.sig](ftp://ftp.gnupg.org/gcrypt/gnupg/unstable/gnupg-2.1.0beta2.tar.bz2.sig) |

The nuild instructions can be found [here](http://code.google.com/p/gnupg-ecc/wiki/HowToBuildGnuPG) and will work for either gnupg.org source tree or this project's source tree (that's how [these binaries](http://code.google.com/p/gnupg-ecc/downloads/list) are built).

There are other projects, such as [Zfone](http://zfoneproject.com/) and pgcrypto (a crypto module for PostgresSQL), that follow the [ECC in OpenPGP RFC6637](http://tools.ietf.org/html/rfc6637). What do these projects find useful in ECC in general and the specification in particular?

The general benefits offered to users by this project are:
  * smaller keys
  * smaller messages
  * stronger information protection than with currently popular RSA 2048 bit keys
  * regulatory compliance
  * access to larger universe of devices and environments that can use public key cryptography, such as mobile VoIP applications
  * "plan B" to switch to in case of a breakthrough in attacks on traditional public key crypto field.

### Ancestry ###

The following modules from the GnuPG v.2 set are maintained under source control as the base for ECC changes:

| **Top-level componenet name** | **Baseline Version** | **Has ECC-related modifications?** | **Assigned version** |
|:------------------------------|:---------------------|:-----------------------------------|:---------------------|
| **gnupg** | gnupg-2.0.16 | Yes | 2.1.0 |
| **libgcrypt** | libgcrypt-1.4.6 | Yes | 1.5.0, library binary interface version 2 |
| libassuan | libassuan-2.0.1 | No, only needed to match the version | no change |
| libgpg-error | libgpg-error-1.9 | No, only needed to match the version | no change |

` `

### Interoperability ###

For interoperability with another product from independent code base you can use
**Symantec PGP Command Line** version 10.2 and above. Release notes are posted [here](http://www.symantec.com/business/support/index?page=landing&key=59287), which include ECC support in the New Features section (or you can navigate to this page through [support page](http://www.symantec.com/business/support/index?page=products), then click on PGP Command Line on this support page). Trialware is available [here](http://www.symantec.com/business/command-line).