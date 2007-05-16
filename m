Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than
	order-0
From: Nicolas Mailhot <nicolas.mailhot@laposte.net>
In-Reply-To: <464B131F.6090904@yahoo.com.au>
References: <Pine.LNX.4.64.0705141058590.11319@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0705141111400.11411@schroedinger.engr.sgi.com>
	 <20070514182456.GA9006@skynet.ie>
	 <1179218576.25205.1.camel@rousalka.dyndns.org>
	 <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie>
	 <464AC00E.10704@yahoo.com.au>
	 <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie>
	 <464ACA68.2040707@yahoo.com.au>
	 <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie>
	 <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie>
	 <464B131F.6090904@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-haMVnvx+zn+m5t5tZB24"
Date: Wed, 16 May 2007 17:06:53 +0200
Message-Id: <1179328013.23605.1.camel@rousalka.dyndns.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@skynet.ie>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-haMVnvx+zn+m5t5tZB24
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Le jeudi 17 mai 2007 =C3=A0 00:20 +1000, Nick Piggin a =C3=A9crit :
> Mel Gorman wrote:
>=20
> > =3D=3D=3D=3D=3D=3D
> >=20
> > On third thought: The trouble with this solution is that we will now se=
t
> > the order to that used by the largest kmalloc cache. Bad... this could =
be
> > 6 on i386 to 13 if CONFIG_LARGE_ALLOCs is set. The large kmalloc caches=
 are
> > rarely used and we are used to OOMing if those are utilized to frequent=
ly.
> >=20
> > I guess we should only set this for non kmalloc caches then.=20
> > So move the call into kmem_cache_create? Would make the min order 3 on
> > most of my mm machines.
> > =3D=3D=3D
>=20
> Also, I might add that the e1000 page allocations failures usually come
> from kmalloc, so doing this means they might just be protected by chance
> if someone happens to create a kmem cache of order 3.

The system on which the patches were tested does not include an e1000
card

--=20
Nicolas Mailhot

--=-haMVnvx+zn+m5t5tZB24
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Ceci est une partie de message
	=?ISO-8859-1?Q?num=E9riquement?= =?ISO-8859-1?Q?_sign=E9e?=

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iEYEABECAAYFAkZLHggACgkQI2bVKDsp8g3KbACgirYWIOHHbJ7Tf0RkovGJ1rQv
opgAnju/JY4jIHxTLECAQKtN8i8I8U+C
=JoEO
-----END PGP SIGNATURE-----

--=-haMVnvx+zn+m5t5tZB24--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
