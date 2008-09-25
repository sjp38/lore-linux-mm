Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
From: Keith Packard <keithp@keithp.com>
In-Reply-To: <20080925030738.GD4401@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de>
	 <1222185029.4873.157.camel@koto.keithp.com>
	 <20080925003021.GC23494@wotan.suse.de>
	 <1222305622.4343.166.camel@koto.keithp.com>
	 <20080925023014.GB4401@wotan.suse.de>
	 <1222310606.4343.174.camel@koto.keithp.com>
	 <20080925030738.GD4401@wotan.suse.de>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XqQhbIny+mHNIFULP/vz"
Date: Wed, 24 Sep 2008 23:16:59 -0700
Message-Id: <1222323419.4343.201.camel@koto.keithp.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: keithp@keithp.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-XqQhbIny+mHNIFULP/vz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-09-25 at 05:07 +0200, Nick Piggin wrote:

> That might be the cleanest logical way to do it actually. But for the mom=
ent
> I'm happy not to pull tmpfs apart :) Even if it seems like the wrong way
> around, at least it is insulated to within mm/

Sure; no sense changing that before we've gotten some experience with
the new API anyway. Would we consider modifying sysv IPC as well? It
currently uses the shmem_file_setup function although it lives a long
ways from mm...

--=20
keith.packard@intel.com

--=-XqQhbIny+mHNIFULP/vz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBI2yzbQp8BWwlsTdMRArGsAJ0QtSqtxjAHmD0Vkw9Gi/pl1DS1wQCff+gK
02jjeOhHWtzdb5ursF//qG4=
=f9E+
-----END PGP SIGNATURE-----

--=-XqQhbIny+mHNIFULP/vz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
