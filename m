Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200710311437.28630.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl>
	 <20071030160910.813944000@chello.nl>
	 <200710311437.28630.nickpiggin@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FT+zCI+A90irqp0ysoO4"
Date: Wed, 31 Oct 2007 11:42:38 +0100
Message-Id: <1193827358.27652.126.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

--=-FT+zCI+A90irqp0ysoO4
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 14:37 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
> > contexts that are entitled to it.
> >
> > Care is taken to only touch the SLUB slow path.
> >
> > This is done to ensure reserve pages don't leak out and get consumed.
>=20
> I think this is generally a good idea (to prevent slab allocators
> from stealing reserve). However I naively think the implementation
> is a bit overengineered and thus has a few holes.
>=20
> Humour me, what was the problem with failing the slab allocation
> (actually, not fail but just call into the page allocator to do
> correct waiting  / reclaim) in the slowpath if the process fails the
> watermark checks?

Ah, we actually need slabs below the watermarks. Its just that once I
allocated those slabs using __GFP_MEMALLOC/PF_MEMALLOC I don't want
allocation contexts that do not have rights to those pages to walk off
with objects.

So, this generic reserve framework still uses the slab allocator to
provide certain kind of objects (kmalloc, kmem_cache_alloc), it just
separates those that are and are not entitled to the reserves.

--=-FT+zCI+A90irqp0ysoO4
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKFweXA2jU0ANEf4RAi7hAJ9NcZFgKlpbDF0l5r2ZdGlxPyGB0ACfYutM
wzNhYh+DCVlsSEe0s5P2XBQ=
=9k+N
-----END PGP SIGNATURE-----

--=-FT+zCI+A90irqp0ysoO4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
