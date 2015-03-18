#summary How to build GnuPG
#labels Phase-Deploy,Featured

# Introduction #

This page lists steps I needed to take to build and setup development environment for GnuPG 2.x on Red Hat Fedora Core 13 Linux.

# Pre-requisites #

In this section we install standard developer libraries shipped with FC13. You may already have them on your system.

  * Install standard development packages, such as with command
```
yum groupinstall "Development Libraries"
yum groupinstall "Development Tools"
```

> This step is here for general guidance. We assume that you are familiar with installing development environment.

  * **libksba**. This is X.509 management library.

```
yum install libksba-devel
```

  * **pth**. This is GNU pthread library.

```
yum install pth-devel
```

  * **transfig**. This is needed for fig2dev.

```
yum install transfig (for fig2dev missing)
```

  * On 64 bit FC13 I needed to remove 64 bit version and install earlier 32 bit version of texinfo (`texinfo-4.13a-4.fc11.i586.rpm`). The existing 64 bit versions were crashing at make time of libgcrypt.

# Compiling #

  * We will be installing all compiled modules into separate directory to avoid overwrite to the RPM-installed modules. This location is referenced bellow with the variable $P, which we define as

```
export P=/usr/local/gpg2ecc
```

  * Checkout the source tree in this project. Navigate to the directory containing gnupg and libgcrypt (so that `cd gnupg` works)

  * Compile **libgpg-error**

```
cd libgpg-error
./autogen.sh
./configure --prefix=$P 
make
sudo -c "make install"
```

> At this time there are no project-specific changes in this library and you can use standard `-devel` package instead, if you prefer. As soon as version 1.8 of libgpg-error becomes available in FC13 RPM repository, this module will be removed.


  * Compile **libassuan**

```
cd libassuan
./autogen.sh
./configure --with-gpg-error-prefix=$P --prefix=$P
make
sudo -c "make install"
```

> At this time there are no project-specific changes in this library and you can use standard `-devel` package instead, if you prefer. As soon as version 2.0 of libassuan becomes available in FC13 RPM repository, this module will be removed.

  * Compile **libgcrypt**

```
cd libgcrypt
./autogen.sh
./configure --prefix=$P --with-gpg-error-prefix=$P 
make
sudo -c "make install"
```

  * Prepare library path for the gnupg make step

```
export LD_LIBRARY_PATH=$P/lib/
```

  * Compile **gnupg**

```
cd gnupg
./autogen.sh
./configure --prefix=$P --with-gpg-error-prefix=$P --with-libgcrypt-prefix=$P --enable-maintainer-mode
```

# Executing #

  * First, make sure to run built version of gpg-agent

```
killall gpg-agent
agent/gpg-agent --daemon --write-env-file ./.gpg-agent-info --enable-ssh-support --debug-all --allow-preset-passphrase --verbose --log-file ./gpg-agent-verbose.log
tail -f ./gpg-agent-verbose.log 
```

  * Running the built gpg2:

```
cd gnupg
g10/gpg2 --expert --gen-key
```

> will display the ECDSA + ECDH key generation option. Once you generate the key, you would work with it just as you do with a typical RSA key, encrypting/decrypting or signing/verifying as usual.

# Debugging #

  * Additional ECC-releated information is available with the the `--debug 15` option, for example:

```
g10/gpg2 --debug 15 --expert --gen-key
```