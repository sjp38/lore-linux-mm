Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
	mode:0x84020
From: Nicolas Mailhot <nicolas.mailhot@laposte.net>
In-Reply-To: <1178905541.2473.2.camel@rousalka.dyndns.org>
References: <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com>
	 <20070510221607.GA15084@skynet.ie>
	 <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
	 <20070510224441.GA15332@skynet.ie>
	 <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
	 <20070510230044.GB15332@skynet.ie>
	 <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
	 <1178863002.24635.4.camel@rousalka.dyndns.org>
	 <20070511090823.GA29273@skynet.ie>
	 <1178884283.27195.1.camel@rousalka.dyndns.org>
	 <20070511173811.GA8529@skynet.ie>
	 <1178905541.2473.2.camel@rousalka.dyndns.org>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zEJOmwkFzxD/DJB3VyQ0"
Date: Fri, 11 May 2007 20:30:10 +0200
Message-Id: <1178908210.4360.21.camel@rousalka.dyndns.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-zEJOmwkFzxD/DJB3VyQ0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Le vendredi 11 mai 2007 =C3=A0 19:45 +0200, Nicolas Mailhot a =C3=A9crit :
> Le vendredi 11 mai 2007 =C3=A0 18:38 +0100, Mel Gorman a =C3=A9crit :

> > so I'd like to look at the
> > alternative option with kswapd as well. Could you put that patch back i=
n again
> > please and try the following patch instead?=20
>=20
> I'll try this one now (if it applies)

Well it doesn't seem to apply. Are you sure you have a clean tree?
(I have vanilla mm2 + revert of
md-improve-partition-detection-in-md-array.patch for another bug)

+ umask 022
+ cd /builddir/build/BUILD
+ LANG=3DC
+ export LANG
+ unset DISPLAY
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
1 out of 1 hunk FAILED -- saving rejects to file mm/slub.c.rej
2 out of 3 hunks FAILED -- saving rejects to file mm/vmscan.c.r
--=20
Nicolas Mailhot

--=-zEJOmwkFzxD/DJB3VyQ0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iEYEABECAAYFAkZEtjIACgkQI2bVKDsp8g28TgCffij/RXX69mSlTnodd1m6eNGc
uQ0AoIgzZKyO9QMw1tiYyAk17Y8Am4mu
=c0e2
-----END PGP SIGNATURE-----

--=-zEJOmwkFzxD/DJB3VyQ0--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
