Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
	mode:0x84020
From: Nicolas Mailhot <nicolas.mailhot@laposte.net>
In-Reply-To: <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
References: <200705102128.l4ALSI2A017437@fire-2.osdl.org>
	 <20070510144319.48d2841a.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0705101447120.12874@schroedinger.engr.sgi.com>
	 <20070510220657.GA14694@skynet.ie>
	 <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com>
	 <20070510221607.GA15084@skynet.ie>
	 <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
	 <20070510224441.GA15332@skynet.ie>
	 <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
	 <20070510230044.GB15332@skynet.ie>
	 <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-MxDrvQ0XLmIeHrHC0B+W"
Date: Fri, 11 May 2007 07:56:42 +0200
Message-Id: <1178863002.24635.4.camel@rousalka.dyndns.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-MxDrvQ0XLmIeHrHC0B+W
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Le jeudi 10 mai 2007 =C3=A0 16:01 -0700, Christoph Lameter a =C3=A9crit :
> On Fri, 11 May 2007, Mel Gorman wrote:
>=20
> > Nicholas, could you backout the patch
> > dont-group-high-order-atomic-allocations.patch and test again please?
> > The following patch has the same effect. Thanks
>=20
> Great! Thanks.

The proposed patch did not apply

+ cd /builddir/build/BUILD
+ rm -rf linux-2.6.21
+ /usr/bin/bzip2 -dc /builddir/build/SOURCES/linux-2.6.21.tar.bz2
+ tar -xf -
+ STATUS=3D0
+ '[' 0 -ne 0 ']'
+ cd linux-2.6.21
++ /usr/bin/id -u
+ '[' 499 =3D 0 ']'
++ /usr/bin/id -u
+ '[' 499 =3D 0 ']'
+ /bin/chmod -Rf a+rX,u+w,g-w,o-w .
+ echo 'Patch #2 (2.6.21-mm2.bz2):'
Patch #2 (2.6.21-mm2.bz2):
+ /usr/bin/bzip2 -d
+ patch -p1 -s
+ STATUS=3D0
+ '[' 0 -ne 0 ']'
+ echo 'Patch #3 (md-improve-partition-detection-in-md-array.patch):'
Patch #3 (md-improve-partition-detection-in-md-array.patch):
+ patch -p1 -R -s
+ echo 'Patch #4 (bug-8464.patch):'
Patch #4 (bug-8464.patch):
+ patch -p1 -s
1 out of 1 hunk FAILED -- saving rejects to file
include/linux/pageblock-flags.h
.rej
6 out of 6 hunks FAILED -- saving rejects to file mm/page_alloc.c.rej

Backing out dont-group-high-order-atomic-allocations.patch worked and
seems to have cured the system so far (need to charge it a bit longer to
be sure)

--=20
Nicolas Mailhot

--=-MxDrvQ0XLmIeHrHC0B+W
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iEYEABECAAYFAkZEBZoACgkQI2bVKDsp8g3ulwCdFEp5Vr9gJ0LQ5ZkhYtATZ7Oh
g84An3vg3usKKJJbaKMz+WXo4edWRhme
=zGaW
-----END PGP SIGNATURE-----

--=-MxDrvQ0XLmIeHrHC0B+W--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
