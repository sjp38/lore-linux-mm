Subject: Re: [PATCH 00/33] Swap over NFS -v14
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200710311426.33223.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl>
	 <200710311426.33223.nickpiggin@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-H8xFTlN2az+i59IqNUDQ"
Date: Wed, 31 Oct 2007 12:27:13 +0100
Message-Id: <1193830033.27652.159.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

--=-H8xFTlN2az+i59IqNUDQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 14:26 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > Hi,
> >
> > Another posting of the full swap over NFS series.
>=20
> Hi,
>=20
> Is it really worth all the added complexity of making swap
> over NFS files work, given that you could use a network block
> device instead?

As it stands, we don't have a usable network block device IMHO.
NFS is by far the most used and usable network storage solution out
there, anybody with half a brain knows how to set it up and use it.

> Also, have you ensured that page_file_index, page_file_mapping
> and page_offset are only ever used on anonymous pages when the
> page is locked? (otherwise PageSwapCache could change)

Good point, I hope so, both ->readpage() and ->writepage() take a locked
page, I'd have to look if it remains locked throughout the NFS call
chain.

Then again, it might become obsolete with the extended swap a_ops.


--=-H8xFTlN2az+i59IqNUDQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKGaRXA2jU0ANEf4RApFUAJ4+CBvPm0mCVlIMmXKt1KBmtVP/3wCfWg+f
0Bv7xVApLAX9gH4Chrrlb70=
=IEK+
-----END PGP SIGNATURE-----

--=-H8xFTlN2az+i59IqNUDQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
