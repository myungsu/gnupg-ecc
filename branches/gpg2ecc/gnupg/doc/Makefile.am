# Copyright (C) 2002, 2004 Free Software Foundation, Inc.
#
# This file is part of GnuPG.
#
# GnuPG is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# GnuPG is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

## Process this file with automake to produce Makefile.in

examples = examples/README examples/scd-event examples/trustlist.txt \
	   examples/gpgconf.conf examples/pwpattern.list

helpfiles = help.txt help.be.txt help.ca.txt help.cs.txt		\
            help.da.txt help.de.txt help.el.txt help.eo.txt		\
            help.es.txt help.et.txt help.fi.txt help.fr.txt		\
            help.gl.txt help.hu.txt help.id.txt help.it.txt		\
            help.ja.txt help.nb.txt help.pl.txt help.pt.txt		\
            help.pt_BR.txt help.ro.txt help.ru.txt help.sk.txt		\
            help.sv.txt help.tr.txt help.zh_CN.txt help.zh_TW.txt

EXTRA_DIST = samplekeys.asc \
	     gnupg-logo.eps gnupg-logo.pdf gnupg-logo.png \
             gnupg-card-architecture.eps gnupg-card-architecture.png \
             gnupg-card-architecture.pdf \
             faq.raw FAQ faq.html gnupg7.texi \
             opt-homedir.texi see-also-note.texi specify-user-id.texi \
	     gpgv.texi texi.css  yat2m.c

BUILT_SOURCES = gnupg-card-architecture.eps gnupg-card-architecture.png \
                gnupg-card-architecture.pdf FAQ faq.html

info_TEXINFOS = gnupg.texi

dist_pkgdata_DATA = qualified.txt com-certs.pem $(helpfiles)

nobase_dist_doc_DATA = FAQ DETAILS HACKING TRANSLATE OpenPGP KEYSERVER \
                       $(examples)	

dist_html_DATA = faq.html 


gnupg_TEXINFOS = \
	gpg.texi gpgsm.texi gpg-agent.texi scdaemon.texi instguide.texi \
	tools.texi debugging.texi glossary.texi contrib.texi gpl.texi \
	sysnotes.texi gnupg-card-architecture.fig \
	howtos.texi howto-create-a-server-cert.texi

DVIPS = TEXINPUTS="$(srcdir)$(PATH_SEPARATOR)$$TEXINPUTS" dvips

AM_MAKEINFOFLAGS = -I $(srcdir) --css-include=$(srcdir)/texi.css

YAT2M_OPTIONS = -I $(srcdir) \
        --release "GnuPG @PACKAGE_VERSION@" --source "GNU Privacy Guard"

myman_sources = gnupg7.texi gpg.texi gpgsm.texi gpg-agent.texi \
                scdaemon.texi tools.texi
myman_pages   = gpg2.1 gpgsm.1 gpg-agent.1 scdaemon.1 gpgv2.1 \
                watchgnupg.1 gpgconf.1 addgnupghome.8 gpg-preset-passphrase.1 \
		gpg-connect-agent.1 gpgparsemail.1 symcryptrun.1 \
		gpgsm-gencert.sh.1 applygnupgdefaults.8 gpg-zip.1

man_MANS = $(myman_pages)
noinst_MANS = gnupg.7

watchgnupg_SOURCE = gnupg.texi


CLEANFILES = faq.raw.xref yat2m

DISTCLEANFILES = gnupg.tmp gnupg.ops yat2m-stamp.tmp yat2m-stamp \
		 $(myman_pages) gnupg.7

yat2m: yat2m.c
	$(CC_FOR_BUILD) -o $@ $(srcdir)/yat2m.c


.fig.png:
	fig2dev -L png `test -f '$<' || echo '$(srcdir)/'`$< $@

.fig.jpg:
	fig2dev -L jpg `test -f '$<' || echo '$(srcdir)/'`$< $@

.fig.eps:
	fig2dev -L eps `test -f '$<' || echo '$(srcdir)/'`$< $@

.fig.pdf:
	fig2dev -L pdf `test -f '$<' || echo '$(srcdir)/'`$< $@


FAQ : faq.raw
if WORKING_FAQPROG
	$(FAQPROG) -f $<  $@ || $(FAQPROG) -f $< $@
else
	: Warning: missing faqprog.pl, cannot make $@
	echo "No $@ due to missing faqprog.pl" > $@
	echo "See ftp://ftp.gnupg.org/gcrypt/contrib/faqprog.pl" >> $@
endif

faq.html : faq.raw
if WORKING_FAQPROG
	$(FAQPROG) -h -f $< $@ 2>&1 || $(FAQPROG) -h -f $< $@
else
	: Warning: missing faqprog.pl, cannot make $@
	echo "No $@ due to missing faqprog.pl" > $@
	echo "See ftp://ftp.gnupg.org/gcrypt/contrib/faqprog.pl" >> $@
endif


yat2m-stamp: $(myman_sources)
	@rm -f yat2m-stamp.tmp
	@touch yat2m-stamp.tmp
	for file in $(myman_sources) ; do \
              ./yat2m $(YAT2M_OPTIONS) --store \
	          `test -f '$$file' || echo '$(srcdir)/'`$$file ; done
	@mv -f yat2m-stamp.tmp $@

yat2m-stamp: yat2m

$(myman_pages) gnupg.7 : yat2m-stamp
	@if test -f $@; then :; else \
            trap 'rm -rf yat2m-stamp yat2m-lock' 1 2 13 15; \
               if mkdir yat2m-lock 2>/dev/null; then \
                 rm -f yat2m-stamp; \
                 $(MAKE) $(AM_MAKEFLAGS) yat2m-stamp; \
                 rmdir yat2m-lock; \
               else \
                 while test -d yat2m-lock; do sleep 1; done; \
                 test -f yat2m-stamp; exit $$?; \
               fi; \
             fi

# Make sure that gnupg.texi is touched if any other source file has
# been modified.  This is required so that the version.texi magic
# updates the release date.
gnupg.texi : $(gnupg_TEXINFOS)
	touch $(srcdir)/gnupg.texi

online: gnupg.html gnupg.pdf
	set -e; \
	echo "Uploading current manuals to www.gnupg.org ..."; \
	cp gnupg-logo.png gnupg.html/; \
        user=werner ; dashdevel="" ; \
        if echo "@PACKAGE_VERSION@" | grep -- "-svn" >/dev/null; then \
	  dashdevel="-devel" ; \
	else \
          rsync -v gnupg.pdf $${user}@cvs.gnupg.org:webspace/manuals/ ; \
        fi ; \
	cd gnupg.html ; \
        rsync -vr --exclude='.svn' .  \
	  $${user}@cvs.gnupg.org:webspace/manuals/gnupg$${dashdevel}/ 

