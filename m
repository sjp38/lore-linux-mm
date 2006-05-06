Message-ID: <445CC02D.8000600@redhat.com>
Date: Sat, 06 May 2006 08:26:37 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 00/14] remap_file_pages protection support
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <200605030245.01457.blaisorblade@yahoo.it> <445C6717.1000402@yahoo.com.au>
In-Reply-To: <445C6717.1000402@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCCBD25E0A5A9940137CF407B"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Blaisorblade <blaisorblade@yahoo.it>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCCBD25E0A5A9940137CF407B
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Nick Piggin wrote:
> I see no reason why they couldn't both go in. In fact, having an mmap
> flag for
> adding guard regions around vmas (and perhaps eg. a system-wide /
> per-process
> option for stack) could almost go in tomorrow.

This would have to be flexible, though.  For thread stacks, at least,
the programmer is able to specify the size of the guard area.  It can be
arbitrarily large.

Also, consider IA-64.  Here we have two stacks.  We allocate them with
one mmap call and put the guard somewhere in the middle (the optimal
ratio of CPU and register stack size is yet to be determined) and have
the stack grow toward each other.  This results into three VMAs in the
moment.  Anything which results on more VMAs obviously isn't good.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enigCCBD25E0A5A9940137CF407B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFEXMAt2ijCOnn/RHQRAgi3AKCn8g85TEA3i67iQlwdjk8czqUC1gCfb1wW
D4lwcZR3hhs1F6QmzOXPam8=
=HZtW
-----END PGP SIGNATURE-----

--------------enigCCBD25E0A5A9940137CF407B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
