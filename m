Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id B663A900015
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 12:05:47 -0400 (EDT)
Received: by qkhq76 with SMTP id q76so74889316qkh.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 09:05:47 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id 84si16181639qkq.78.2015.06.02.09.05.46
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 09:05:47 -0700 (PDT)
Date: Tue, 2 Jun 2015 12:05:46 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [RESEND PATCH 3/3] Add tests for lock on fault
Message-ID: <20150602160545.GA2253@akamai.com>
References: <1432908808-31150-1-git-send-email-emunson@akamai.com>
 <1432908808-31150-4-git-send-email-emunson@akamai.com>
 <556DCB05.1010102@osg.samsung.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Content-Disposition: inline
In-Reply-To: <556DCB05.1010102@osg.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuahkh@osg.samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 02 Jun 2015, Shuah Khan wrote:

> On 05/29/2015 08:13 AM, Eric B Munson wrote:
> > Test the mmap() flag, the mlockall() flag, and ensure that mlock limits
> > are respected.  Note that the limit test needs to be run a normal user.
> >=20
> > Signed-off-by: Eric B Munson <emunson@akamai.com>
> > Cc: Shuah Khan <shuahkh@osg.samsung.com>
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-api@vger.kernel.org
> > ---
> >  tools/testing/selftests/vm/Makefile         |   8 +-
> >  tools/testing/selftests/vm/lock-on-fault.c  | 145 ++++++++++++++++++++=
++++++++
> >  tools/testing/selftests/vm/on-fault-limit.c |  47 +++++++++
> >  tools/testing/selftests/vm/run_vmtests      |  23 +++++
> >  4 files changed, 222 insertions(+), 1 deletion(-)
> >  create mode 100644 tools/testing/selftests/vm/lock-on-fault.c
> >  create mode 100644 tools/testing/selftests/vm/on-fault-limit.c
> >=20
> > diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selfte=
sts/vm/Makefile
> > index a5ce953..32f3d20 100644
> > --- a/tools/testing/selftests/vm/Makefile
> > +++ b/tools/testing/selftests/vm/Makefile
> > @@ -1,7 +1,13 @@
> >  # Makefile for vm selftests
> > =20
> >  CFLAGS =3D -Wall
> > -BINARIES =3D hugepage-mmap hugepage-shm map_hugetlb thuge-gen hugetlbf=
stest
> > +BINARIES =3D hugepage-mmap
> > +BINARIES +=3D hugepage-shm
> > +BINARIES +=3D hugetlbfstest
> > +BINARIES +=3D lock-on-fault
> > +BINARIES +=3D map_hugetlb
> > +BINARIES +=3D on-fault-limit
> > +BINARIES +=3D thuge-gen
> >  BINARIES +=3D transhuge-stress
> > =20
> >  all: $(BINARIES)
> > diff --git a/tools/testing/selftests/vm/lock-on-fault.c b/tools/testing=
/selftests/vm/lock-on-fault.c
> > new file mode 100644
> > index 0000000..e6a9688
>=20
> Hi Eric,
>=20
> Could you please make sure make kselftest run from kernel main
> Makefile works and tools/testing/selftests/kselftest_install.sh
> works. For now you have to be in tools/testing/selftests to run
> kselftest_install.sh
>=20

I am working on getting V2 ready, I will ensure these work and make any
necessary adjustments before sending V2 out.

Eric

--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVbdRZAAoJELbVsDOpoOa9x3kQANSTBRYpmlw8NoSvCMWz/yqQ
12ZdZ/5G5upe7YMBFGD6bupYQ3+nNiarUb7T+pgbIw0+dAEuTSQ7euls3RA2KKDL
TlvgPfcdAnVsIAPhlFY+g7aqh5zhXzSKM/wf+ltoE+Kl6c0rzq4ZIzkTVf9guflY
KwjzGOEtYsGt8RwdYTl/N2Q4vhPJ30tBXPtviANV13Ax/pAwkiYzeFVbK1ifCaUl
dqM3SEjqbmMFkO5Cr+3zKi4F4ay5Kn69qAQ4H/rnVoTv3GzhCJyur2qK24pw6Nf+
iorgd9s5RjE1Rc5uJ48ofgtlG0K70Y4clyHUSHTUXct+sDMlNAQTCCb3Eehl2SRt
KmuYEghyC9sFbL4qembwq+C/s+Fd7DqVTMTvP5BMIiVcs3/KcVdebvrfAYHNbIMa
82d12bSWR5Gfyr2X4bvr4n1gOM1bUkvtbpyL+P7+BA1j9b5JcrbF9Xj0IvmEpiCS
uSWNG757eLba3nKF6I8OCFdZL6ha4fldEUrklUcTLuF3nopm7WWaI7a9SNq6/HdH
fjwShyD1ZcNkIIWctZlFANgH24X703495mgFjOhqRggA2TMxNxIMD4BUFoBoEJCk
6Hh1tKlKxXyYUMdDffDXQrrHGpeqTLyYWY3kwslpYCb3QJAbh2XWEYQ1siY8//NB
ACOVHuBMjYdXwqM8Q8/J
=b+/S
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
