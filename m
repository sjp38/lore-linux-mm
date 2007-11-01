Subject: Re: per-bdi-throttling: synchronous writepage doesn't work
	correctly
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1Indqb-00049a-00@dorka.pomaz.szeredi.hu>
References: <E1IndEw-00046x-00@dorka.pomaz.szeredi.hu>
	 <1193935886.27652.313.camel@twins>
	 <E1IndPT-00047e-00@dorka.pomaz.szeredi.hu>
	 <1193936949.27652.321.camel@twins>
	 <E1Indqb-00049a-00@dorka.pomaz.szeredi.hu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tNPUnuLGMUTQ9uh1rASb"
Date: Thu, 01 Nov 2007 18:39:30 +0100
Message-Id: <1193938770.27652.328.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jdike@addtoit.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=-tNPUnuLGMUTQ9uh1rASb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-11-01 at 18:28 +0100, Miklos Szeredi wrote:
> > The page not having PG_writeback set on return is a hint, but not fool
> > proof, it could be the device is just blazing fast.
>=20
> Hmm, does it actually has to be foolproof though?  What will happen if
> bdi_writeout_inc() is called twice for the page?  The device will get
> twice the number of pages it deserves?  That's not all that bad,
> especially since that is a really really fast device.

Basically, yes.

But then again, that would require auditing all ->writepage() callsites.



--=-tNPUnuLGMUTQ9uh1rASb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKg9SXA2jU0ANEf4RAhxyAJwLeufXonQYVMeLHA7r+JcGfedEdgCfXvCL
jdocEtAFn/AUW123WpFxQBU=
=2axN
-----END PGP SIGNATURE-----

--=-tNPUnuLGMUTQ9uh1rASb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
