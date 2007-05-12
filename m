Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
	mode:0x84020
From: Nicolas Mailhot <nicolas.mailhot@laposte.net>
In-Reply-To: <20070512164237.GA2691@skynet.ie>
References: <20070510230044.GB15332@skynet.ie>
	 <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
	 <1178863002.24635.4.camel@rousalka.dyndns.org>
	 <20070511090823.GA29273@skynet.ie>
	 <1178884283.27195.1.camel@rousalka.dyndns.org>
	 <20070511173811.GA8529@skynet.ie>
	 <1178905541.2473.2.camel@rousalka.dyndns.org>
	 <1178908210.4360.21.camel@rousalka.dyndns.org>
	 <20070511203610.GA12136@skynet.ie>
	 <1178957491.4095.2.camel@rousalka.dyndns.org>
	 <20070512164237.GA2691@skynet.ie>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uaW40IU6tqIOqYkknwMv"
Date: Sat, 12 May 2007 20:09:03 +0200
Message-Id: <1178993343.6397.1.camel@rousalka.dyndns.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-uaW40IU6tqIOqYkknwMv
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Le samedi 12 mai 2007 =C3=A0 17:42 +0100, Mel Gorman a =C3=A9crit :

> order-2 (at least 19 pages but more are there) and higher pages were free
> and this was a NORMAL allocation. It should also be above watermarks so
> something screwy is happening
>=20
> *peers suspiciously*
>=20
> Can you try the following patch on top of the kswapd patch please? It is
> also available from http://www.csn.ul.ie/~mel/watermarks.patch

Ok, testing now

--=20
Nicolas Mailhot

--=-uaW40IU6tqIOqYkknwMv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iEYEABECAAYFAkZGArkACgkQI2bVKDsp8g0AdACg4kHURYsfvh7XVXtLnm2/R3f9
JrYAoOfyxfXQ30HH25DhJd/cVpWkmpu3
=cr1N
-----END PGP SIGNATURE-----

--=-uaW40IU6tqIOqYkknwMv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
