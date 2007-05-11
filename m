Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
	mode:0x84020
From: Nicolas Mailhot <nicolas.mailhot@laposte.net>
In-Reply-To: <20070511090823.GA29273@skynet.ie>
References: <Pine.LNX.4.64.0705101447120.12874@schroedinger.engr.sgi.com>
	 <20070510220657.GA14694@skynet.ie>
	 <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com>
	 <20070510221607.GA15084@skynet.ie>
	 <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
	 <20070510224441.GA15332@skynet.ie>
	 <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
	 <20070510230044.GB15332@skynet.ie>
	 <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
	 <1178863002.24635.4.camel@rousalka.dyndns.org>
	 <20070511090823.GA29273@skynet.ie>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iSS1avLJLEBtnoji0oiw"
Date: Fri, 11 May 2007 13:51:23 +0200
Message-Id: <1178884283.27195.1.camel@rousalka.dyndns.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-iSS1avLJLEBtnoji0oiw
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Le vendredi 11 mai 2007 =C3=A0 10:08 +0100, Mel Gorman a =C3=A9crit :

> > seems to have cured the system so far (need to charge it a bit longer t=
o
> > be sure)
> >=20
>=20
> The longer it runs the better, particularly under load and after
> updatedb has run. Thanks a lot for testing

After a few hours of load testing still nothing in the logs, so the
revert was probably the right thing to do

--=20
Nicolas Mailhot

--=-iSS1avLJLEBtnoji0oiw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iEYEABECAAYFAkZEWLYACgkQI2bVKDsp8g1nawCgsLzbk5Wc4/0Gfey+//uNHEPA
kCoAn0HmY/aR2wKW5wizivptFnvVQfmY
=Hm2+
-----END PGP SIGNATURE-----

--=-iSS1avLJLEBtnoji0oiw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
