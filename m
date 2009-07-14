Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CDFA36B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 09:30:11 -0400 (EDT)
Date: Tue, 14 Jul 2009 17:03:49 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: Re: kmemleak hexdump proposal
Message-ID: <20090714140349.GA3145@localdomain.by>
References: <20090629201014.GA5414@localdomain.by>
 <1247566033.28240.46.camel@pc1117.cambridge.arm.com>
 <20090714103356.GA2929@localdomain.by>
 <1247567641.28240.51.camel@pc1117.cambridge.arm.com>
 <20090714105709.GB2929@localdomain.by>
 <1247578781.28240.92.camel@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fUYQa+Pmc3FrFX/N"
Content-Disposition: inline
In-Reply-To: <1247578781.28240.92.camel@pc1117.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On (07/14/09 14:39), Catalin Marinas wrote:
> On Tue, 2009-07-14 at 13:57 +0300, Sergey Senozhatsky wrote:
> [...]
> > +/*
> > + * Printing of the objects hex dump to the seq file. The number on lin=
es
> > + * to be printed is limited to HEX_MAX_LINES to prevent seq file spamm=
ing.
> > + * The actual number of printed bytes depends on HEX_ROW_SIZE.
> > + * It must be called with the object->lock held.
> > + */
> [...]
>=20
> The patch looks fine. Could you please add a description and
> Signed-off-by line?
>=20

Sure. During 30-40 minutes (sorry, I'm a bit busy now). OK?
Should I update Documentation/kmemeleak.txt either?


> Thanks.
>=20
> --=20
> Catalin
>=20

	Sergey

--fUYQa+Pmc3FrFX/N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iJwEAQECAAYFAkpckEUACgkQfKHnntdSXjTNKgP/Z2SFMRD4sQZU/JCn/3jgNszp
fsuN65FbX/iOVCpHSPzL0UwPSddxbangiYiEauiP1hRpZkRSscmT1W/pOEjI0fZB
UfK1AHdToB25pMIeyJJmDpOslwKOsJsFQ4IXa4ooz1RDkUjvDpnJfqyYYqYYHjNg
8qmx7ksiTEwFQX4eBF4=
=qewY
-----END PGP SIGNATURE-----

--fUYQa+Pmc3FrFX/N--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
