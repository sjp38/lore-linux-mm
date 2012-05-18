Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id AD1916B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 21:11:19 -0400 (EDT)
Date: Thu, 17 May 2012 21:11:17 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 00/17] Swap-over-NBD without deadlocking V11
Message-ID: <20120518011117.GA5894@mgebm.net>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
Content-Disposition: inline
In-Reply-To: <1337266231-8031-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 17 May 2012, Mel Gorman wrote:

> Mostly addressing feedback from David Miller.
>=20
> Changeloc since V10
>   o Rebase to 3.4-rc5
>   o Coding style fixups						      (davem)
>   o API consistency						      (davem)
>   o Rename sk_allocation to sk_gfp_atomic and use only when necessary (da=
vem)
>   o Use static branches for sk_memalloc_socks			      (davem)
>   o Use static branch checks in fast paths			      (davem)
>   o Document concerns about PF_MEMALLOC leaking flags		      (davem)
>   o Locking fix in slab						      (mel)

<snip>

I am attempting to test these, but when they are applied on top of mainline
head my laptop hangs about 60-90 seconds after boot.  I am trying mainline
without these sets now and will post results.

Eric

--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPtaG1AAoJEKhG9nGc1bpJ8JYP/2tRKWs9oCsl3RWzGHDrDHlr
xgyhfmWo66HnIHS4MGikWeHEk23sYzXdkms7wbty2mdO67sJifI4YHqrKObhNc4/
ud/Idi2VYEEemd6IIEYeB63UmgqEjw8NcTjHTR3av3f7USs5eI8SkKW1kAW5w8Qk
qv/omY+bISVTDUpG/NNuC8xVxE9JIUQgLYt/6ZzDDqq4gyl+HJ4rjxgeBWbptswL
6/VihOCKZwDVNlRhTr1PC2fsYEBZvObpCZD39/GQlSqvRRk2kmdQ/jIuZoaFsFBG
ylDpnl76kil1I4pLSuPGF4SFlQksU2jANXd9GtC2hSn5KXfvkGoBYcVIv7rXBHgH
ZTnzdnla603MpqWTwR0U8lbQj0KRUjNuOIsD5lN5vL89nJb0Xs1FKXzI2uDwgVhx
KEB/KtFOrcgUZwd8FayMWSDFMOS8Td0WOqdfJiaWlVFUCgnESfHeYTkFDBqLnJJv
EatxiRrMwsoq5vUEURpP4/9wjMp/s0SEGa0hgujIfGtvXnEanBH4BE/a5WsPU2Zc
rMG80KGmGh8UYaGVNidjcF0xK9DHdEet52TQxSMLvlrGHU1U3e5RMudpi0bXGl3J
+gp49EYGdETVUBBZBCFvCWYstOo7FVlEE/xe6ueoEdvJLo4rZzkVUPrnh+VOnyOK
d2NeRVRU1GXkvImB2Yvm
=KJjb
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
