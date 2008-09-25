From: Keith Packard <keithp@keithp.com>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Date: Thu, 25 Sep 2008 07:38:07 -0700
Message-ID: <1222353487.4343.205.camel@koto.keithp.com>
References: <20080923091017.GB29718@wotan.suse.de>
	 <48D8C326.80909@tungstengraphics.com>
	 <20080925001856.GB23494@wotan.suse.de>
	 <48DB3B88.7080609@tungstengraphics.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5ksctFAUSjiUwZz2PkgW"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753554AbYIYOih@vger.kernel.org>
In-Reply-To: <48DB3B88.7080609@tungstengraphics.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Thomas =?ISO-8859-1?Q?Hellstr=F6m?= <thomas@tungstengraphics.com>
Cc: keithp@keithp.com, Nick Piggin <npiggin@suse.de>, "eric@anholt.net" <eric@anholt.net>, "hugh@veritas.com" <hugh@veritas.com>, "hch@infradead.org" <hch@infradead.org>, "airlied@linux.ie" <airlied@linux.ie>, "jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>, "dri-devel@lists.sourceforge.net" <dri-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org


--=-5ksctFAUSjiUwZz2PkgW
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-09-25 at 00:19 -0700, Thomas Hellstr=C3=B6m wrote:
>  If data is
> dirtied in VRAM or the page(s) got discarded
>  we need new pages and to set up a copy operation.

Note that this can occur as a result of a suspend-to-memory transition
at which point *all* of the objects in VRAM will need to be preserved in
main memory, and so the pages aren't really 'freed', they just don't
need to have valid contents, but the system should be aware that the
space may be needed at some point in the future.

--=20
keith.packard@intel.com

--=-5ksctFAUSjiUwZz2PkgW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBI26JPQp8BWwlsTdMRAsZQAJ9L293zEdR9IZafP1KaiS4g1c0LVACgiuAm
MNdQDSJ3EIeR78OANbe2AV8=
=Ph60
-----END PGP SIGNATURE-----

--=-5ksctFAUSjiUwZz2PkgW--
