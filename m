Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 51D5F6B005C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:39:40 -0400 (EDT)
Subject: Re: [PATCH] drm: i915: ensure objects are allocated below 4GB on
 PAE
From: Eric Anholt <eric@anholt.net>
In-Reply-To: <20090527004250.GA11835@sli10-desk.sh.intel.com>
References: <20090526162717.GC14808@bombadil.infradead.org>
	 <Pine.LNX.4.64.0905262343140.13452@sister.anvils>
	 <20090527001840.GC16929@bombadil.infradead.org>
	 <20090527004250.GA11835@sli10-desk.sh.intel.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-gVhHpGaJA1/89bQ8nK4v"
Date: Wed, 27 May 2009 10:40:12 -0700
Message-Id: <1243446012.8400.37.camel@gaiman.anholt.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: Kyle McMartin <kyle@mcmartin.ca>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "airlied@redhat.com" <airlied@redhat.com>, "dri-devel@lists.sf.net" <dri-devel@lists.sf.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>, "stable@kernel.org" <stable@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


--=-gVhHpGaJA1/89bQ8nK4v
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-05-27 at 08:42 +0800, Shaohua Li wrote:
> On Wed, May 27, 2009 at 08:18:40AM +0800, Kyle McMartin wrote:
> > On Tue, May 26, 2009 at 11:55:50PM +0100, Hugh Dickins wrote:
> > > I'm confused: I thought GFP_DMA32 only applies on x86_64:
> > > my 32-bit PAE machine with (slightly!) > 4GB shows no ZONE_DMA32.
> > > Does this patch perhaps depend on another, to enable DMA32 on 32-bit
> > > PAE, or am I just in a muddle?
> > >=20
> >=20
> > No, you're exactly right, I'm just a muppet and missed the obvious.
> > Looks like the "correct" fix is the fact that the allocation is thus
> > filled out with GFP_USER, therefore, from ZONE_NORMAL, and below
> > max_low_pfn.
> >=20
> > Looks like we'll need some additional thinking to get true ZONE_DMA32 o=
n
> > i386... ugh, I'll look into it tonight.
> For i386, GFP_USER is enough. But 945G GART can only map to physical page=
 < 4G,
> so for x64, we need GFP_DMA32. This is the reason I add extra GFP_DMA32.

Those 945Gs don't have memory located above 4G, from my reading of the
chipset specs.

--=20
Eric Anholt
eric@anholt.net                         eric.anholt@intel.com



--=-gVhHpGaJA1/89bQ8nK4v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkodevwACgkQHUdvYGzw6vcEngCgjb9B+8tpQB4CH1x/3rE63frA
H9wAn06Mh1ljZtMcAFVVbstunBWdz18J
=hwZx
-----END PGP SIGNATURE-----

--=-gVhHpGaJA1/89bQ8nK4v--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
