Subject: Re: per-bdi-throttling: synchronous writepage doesn't work
	correctly
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1IndPT-00047e-00@dorka.pomaz.szeredi.hu>
References: <E1IndEw-00046x-00@dorka.pomaz.szeredi.hu>
	 <1193935886.27652.313.camel@twins>
	 <E1IndPT-00047e-00@dorka.pomaz.szeredi.hu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-dSa74V+mZJnKJ/sKvoKp"
Date: Thu, 01 Nov 2007 18:09:09 +0100
Message-Id: <1193936949.27652.321.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jdike@addtoit.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-dSa74V+mZJnKJ/sKvoKp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-11-01 at 18:00 +0100, Miklos Szeredi wrote:
> > > Hi,
> > >=20
> > > It looks like bdi_thresh will always be zero if filesystem does
> > > synchronous writepage, resulting in very poor write performance.
> > >=20
> > > Hostfs (UML) is one such example, but there might be others.
> > >=20
> > > The only solution I can think of is to add a set_page_writeback();
> > > end_page_writeback() pair (or some reduced variant, that only does
> > > the proportions magic).  But that means auditing quite a few
> > > filesystems...
> >=20
> > Ouch...
> >=20
> > I take it there is no other function that is shared between all these
> > writeout paths which we could stick a bdi_writeout_inc(bdi) in?
>=20
> No, and you can't detect it from the callers either I think.

The page not having PG_writeback set on return is a hint, but not fool
proof, it could be the device is just blazing fast.

I guess there is nothing to it but for me to grep writepage and manually
look at all hits...



--=-dSa74V+mZJnKJ/sKvoKp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKgg1XA2jU0ANEf4RAn80AJ47Qu81P9UszpqrtAsdBGtbBKwqUgCbBQJg
6hM3NjbF6zxEbRDKfNQgLyc=
=AUR4
-----END PGP SIGNATURE-----

--=-dSa74V+mZJnKJ/sKvoKp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
