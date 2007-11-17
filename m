Subject: Re: [patch 0/6] lockless pagecache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20071111084556.GC19816@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6j3DAuVr16RfmFnb9bBQ"
Date: Sat, 17 Nov 2007 10:48:11 +0100
Message-Id: <1195292891.6739.1.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-6j3DAuVr16RfmFnb9bBQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Sun, 2007-11-11 at 09:45 +0100, Nick Piggin wrote:
> Hi,
>=20
> I wonder what everyone thinks about getting the lockless pagecache patch
> into -mm? This version uses Hugh's suggestion to avoid a smp_rmb and a lo=
ad
> and branch in the lockless lookup side, and avoids some atomic ops in the
> reclaim path, and avoids using a page flag! The coolest thing about it is
> that it speeds up single-threaded pagecache lookups...
>=20
> Patches are against latest git for RFC.

Full set

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--=-6j3DAuVr16RfmFnb9bBQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHPrjbXA2jU0ANEf4RAl66AJ98XMyF2iRPRnTeTtbm14k9n9GA5wCaAwBo
s7/gSESMbuBxQamIQ/X8q0o=
=GGLN
-----END PGP SIGNATURE-----

--=-6j3DAuVr16RfmFnb9bBQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
