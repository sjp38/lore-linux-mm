Subject: Re: [PATCH 00/33] Swap over NFS -v14
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071030.213753.126064697.davem@davemloft.net>
References: <20071030160401.296770000@chello.nl>
	 <200710311426.33223.nickpiggin@yahoo.com.au>
	 <20071030.213753.126064697.davem@davemloft.net>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-yW7DcZkAyc3tw+pTPoVz"
Date: Wed, 31 Oct 2007 10:53:16 +0100
Message-Id: <1193824396.27652.105.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: nickpiggin@yahoo.com.au, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

--=-yW7DcZkAyc3tw+pTPoVz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-30 at 21:37 -0700, David Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>
> Date: Wed, 31 Oct 2007 14:26:32 +1100
>=20
> > Is it really worth all the added complexity of making swap
> > over NFS files work, given that you could use a network block
> > device instead?
>=20
> Don't be misled.  Swapping over NFS is just a scarecrow for the
> seemingly real impetus behind these changes which is network storage
> stuff like iSCSI.

Not quite, yes, iSCSI is also on the 'want' list of quite a few people,
but swap over NFS on its own is also a feature of great demand.

--=-yW7DcZkAyc3tw+pTPoVz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKFCMXA2jU0ANEf4RAnCYAJ9EShZNc2aAigDfV05aRlrTBUws0wCeLutM
XGe5bBLDF8SxDFeM890dEoY=
=66ee
-----END PGP SIGNATURE-----

--=-yW7DcZkAyc3tw+pTPoVz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
