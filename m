From: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
Date: Wed, 12 Mar 2008 16:19:42 +0100
References: <200803061447.05797.Jens.Osterkamp@gmx.de> <200803072330.46448.Jens.Osterkamp@gmx.de> <Pine.LNX.4.64.0803071453170.9654@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803071453170.9654@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1441593.E2tnLPT8v4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <200803121619.45708.Jens.Osterkamp@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--nextPart1441593.E2tnLPT8v4
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 07 March 2008, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Jens Osterkamp wrote:
>=20
> > 0xc000000000056f08 is in copy_process (/home/auto/jens/kernels/linux-2.=
6.25-rc3/include/linux/slub_def.h:209).
> > 204                             struct kmem_cache *s =3D kmalloc_slab(s=
ize);
> > 205
> > 206                             if (!s)
> > 207                                     return ZERO_SIZE_PTR;
> > 208
> > 209                             return kmem_cache_alloc(s, flags);
> > 210                     }
> > 211             }
> > 212             return __kmalloc(size, flags);
> > 213     }
> >=20
> > which is in the middle of kmalloc.
>=20
> Its in the middle of inline code generated within the function that calls=
=20
> kmalloc. Its not in kmalloc per se.
>=20
> Can you figure out what the value of size is here? I suspect we are doing=
=20
> a lookup here in kmalloc_caches with an invalid offset.

I added a printk in kmalloc and the size seems to be 0x4000.

Gru=DF,
	Jens

--nextPart1441593.E2tnLPT8v4
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBH1/SRP1aZ9bkt7XMRAujiAJ42Abn29naSP7bqT5unIWnnIA1lqwCgtZww
Vm1yULSEypyv1OK7RN2LED0=
=aRLF
-----END PGP SIGNATURE-----

--nextPart1441593.E2tnLPT8v4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
