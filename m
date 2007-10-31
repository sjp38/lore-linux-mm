Subject: Re: [PATCH 09/33] mm: system wide ALLOC_NO_WATERMARK
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200710311452.36239.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl>
	 <20071030160912.283002000@chello.nl>
	 <200710311452.36239.nickpiggin@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-e5tlmua4wL578c6z+yiG"
Date: Wed, 31 Oct 2007 11:45:55 +0100
Message-Id: <1193827555.27652.133.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

--=-e5tlmua4wL578c6z+yiG
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 14:52 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > Change ALLOC_NO_WATERMARK page allocation such that the reserves are sy=
stem
> > wide - which they are per setup_per_zone_pages_min(), when we scrape th=
e
> > barrel, do it properly.
> >
>=20
> IIRC it's actually not too uncommon to have allocations coming here via
> page reclaim. It's not exactly clear that you want to break mempolicies
> at this point.

Hmm, the way I see it is that mempolicies are mainly for user-space
allocations, reserve allocations are always kernel allocations. These
already break mempolicies - for example hardirq context allocations.

Also, as it stands, the reserve is spread out evenly over all
zones/nodes (excluding highmem), so by restricting ourselves to a
subset, we don't have access to the full reserve.


--=-e5tlmua4wL578c6z+yiG
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKFzjXA2jU0ANEf4RAoU0AJ0eZtew/3cO5/H6pCLyHNnXKc7hhgCgi54o
PtDuuGj/tQ4uMH0Vvthjoc4=
=Y12J
-----END PGP SIGNATURE-----

--=-e5tlmua4wL578c6z+yiG--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
