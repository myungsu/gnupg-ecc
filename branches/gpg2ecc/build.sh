#!/bin/sh

D=`pwd`
P=/usr/local/gpg2ecc

cd libgpg-error ; ./autogen.sh;  ./configure --prefix=$P ; make || exit 1; cd $D

cd libassuan ; ./autogen.sh; ./configure --with-gpg-error-prefix=$P --prefix=$P ; 	make || exit 1; cd $D

cd libgcrypt ; ./autogen.sh ; ./configure --prefix=$P --with-gpg-error-prefix=$P --disable-optimization; 	make || exit 1; cd $D

export LD_LIBRARY_PATH=$P/lib/

cd gnupg ; ./autogen.sh ; ./configure	--prefix=$P --with-gpg-error-prefix=$P --with-libgcrypt-prefix=$P --with-libassuan-prefix=$P --enable-maintainer-mode --disable-optimization ; make || exit 1; cd $D

