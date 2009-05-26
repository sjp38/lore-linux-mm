Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D82656B007E
	for <linux-mm@kvack.org>; Tue, 26 May 2009 17:35:05 -0400 (EDT)
Subject: Re: [PATCH] drm: i915: ensure objects are allocated below 4GB on
 PAE
From: Eric Anholt <eric@anholt.net>
In-Reply-To: <1243365473.23657.32.camel@twins>
References: <20090526162717.GC14808@bombadil.infradead.org>
	 <1243365473.23657.32.camel@twins>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-2b5Qwv+ghC29vTSW04rb"
Date: Tue, 26 May 2009 14:35:30 -0700
Message-Id: <1243373730.8400.26.camel@gaiman.anholt.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Kyle McMartin <kyle@mcmartin.ca>, airlied@redhat.com, dri-devel@lists.sf.net, linux-kernel@vger.kernel.org, jbarnes@virtuousgeek.org, stable@kernel.org, hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, shaohua.li@intel.com
List-ID: <linux-mm.kvack.org>


--=-2b5Qwv+ghC29vTSW04rb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-05-26 at 21:17 +0200, Peter Zijlstra wrote:
> On Tue, 2009-05-26 at 12:27 -0400, Kyle McMartin wrote:
> > From: Kyle McMartin <kyle@redhat.com>
> >=20
> > Ensure we allocate GEM objects below 4GB on PAE machines, otherwise
> > misery ensues. This patch is based on a patch found on dri-devel by
> > Shaohua Li, but Keith P. expressed reticence that the changes unfairly
> > penalized other hardware.
> >=20
> > (The mm/shmem.c hunk is necessary to ensure the DMA32 flag isn't used
> >  by the slab allocator via radix_tree_preload, which will hit a
> >  WARN_ON.)
>=20
> Why is this, is the gart not PAE friendly?
>=20
> Seems to me its a grand way of promoting 64bit hard/soft-ware.

No, the GART's fine.  But the APIs required to make the AGP code
PAE-friendly got deprecated, so the patches to fix the AGP code got
NAKed, and Venkatesh  never sent out his patches to undeprecate the APIs
and use them.

It's been like 6 months now, and it's absurd.  I'd like to see this
patch go in so people's graphics can start working again and stop
corrupting system memory.

--=20
Eric Anholt
eric@anholt.net                         eric.anholt@intel.com



--=-2b5Qwv+ghC29vTSW04rb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkocYKIACgkQHUdvYGzw6vfHiACggawPj/xiVzdN3rZtqnKCioMe
4zMAnApmzjwYB2DzyB73KILG51NUsn8M
=QOfV
-----END PGP SIGNATURE-----

--=-2b5Qwv+ghC29vTSW04rb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
