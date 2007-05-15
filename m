Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
	order-0
From: Nicolas Mailhot <nicolas.mailhot@laposte.net>
In-Reply-To: <20070514182456.GA9006@skynet.ie>
References: <20070514173218.6787.56089.sendpatchset@skynet.skynet.ie>
	 <20070514173238.6787.57003.sendpatchset@skynet.skynet.ie>
	 <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
	 <20070514182456.GA9006@skynet.ie>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zcBbKcVDD/ofQ11iG/b5"
Date: Tue, 15 May 2007 10:42:56 +0200
Message-Id: <1179218576.25205.1.camel@rousalka.dyndns.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Christoph Lameter <clameter@sgi.com>, apw@shadowen.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-zcBbKcVDD/ofQ11iG/b5
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Le lundi 14 mai 2007 =C3=A0 19:24 +0100, Mel Gorman a =C3=A9crit :
> On (14/05/07 11:13), Christoph Lameter didst pronounce:
> > I think the slub fragment may have to be this way? This calls=20
> > raise_kswapd_order on each kmem_cache_create with the order of the cach=
e=20
> > that was created thus insuring that the min_order is correctly.
> >=20
> > Signed-off-by: Christoph Lameter <clameter@sgi.com>
> >=20
>=20
> Good plan. Revised patch as follows;

Kernel with this patch and the other one survives testing. I'll stop
heavy testing now and consider the issue closed.

Thanks for looking at my bug report.

--=20
Nicolas Mailhot

--=-zcBbKcVDD/ofQ11iG/b5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iEYEABECAAYFAkZJcosACgkQI2bVKDsp8g3QdgCgz9A9D3JFs5LwQ3W/X0q1+drc
XPAAn2Cl8M2ZRj6YHy/4F7N/odwt7sau
=fkcT
-----END PGP SIGNATURE-----

--=-zcBbKcVDD/ofQ11iG/b5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
