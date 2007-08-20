Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0708201211240.20591@sbz-30.cs.Helsinki.FI>
References: <20070806102922.907530000@chello.nl>
	 <20070806103658.603735000@chello.nl> <1187595513.6114.176.camel@twins>
	 <Pine.LNX.4.64.0708201211240.20591@sbz-30.cs.Helsinki.FI>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-udHQMOltm/5b8k9KQ8wZ"
Date: Mon, 20 Aug 2007 11:17:35 +0200
Message-Id: <1187601455.6114.189.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

--=-udHQMOltm/5b8k9KQ8wZ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-08-20 at 12:12 +0300, Pekka J Enberg wrote:
> Hi Peter,
>=20
> On Mon, 20 Aug 2007, Peter Zijlstra wrote:
> > -static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int no=
de)
> > +static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int no=
de, int *reserve)
> >  {
>=20
> [snip]
>=20
> > +	*reserve =3D page->reserve;
>=20
> Any reason why the callers that are actually interested in this don't do=20
> page->reserve on their own?

because new_slab() destroys the content?

struct page {
	...
	union {
		pgoff_t index;		/* Our offset within mapping. */
		void *freelist;		/* SLUB: freelist req. slab lock */
		int reserve;		/* page_alloc: page is a reserve page */
		atomic_t frag_count;	/* skb fragment use count */
	};
	...
};

static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, i=
nt *reserve)
{
	...
	*reserve =3D page->reserve;
	...
	page->freelist =3D start;
	...
}


--=-udHQMOltm/5b8k9KQ8wZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGyVwvXA2jU0ANEf4RAhQNAJ91XekewOmq+RfoxHrvoNYOGWXWFQCfbEUN
UUBObXECAFrQ2DfXDhTdUvk=
=zbSK
-----END PGP SIGNATURE-----

--=-udHQMOltm/5b8k9KQ8wZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
