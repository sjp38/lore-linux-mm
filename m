Message-ID: <46383742.9050503@imap.cc>
Date: Wed, 02 May 2007 09:01:22 +0200
From: Tilman Schmidt <tilman@imap.cc>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>	<46338AEB.2070109@imap.cc>	<20070428141024.887342bd.akpm@linux-foundation.org>	<4636248E.7030309@imap.cc>	<20070430112130.b64321d3.akpm@linux-foundation.org>	<46364346.6030407@imap.cc> <20070430124638.10611058.akpm@linux-foundation.org>
In-Reply-To: <20070430124638.10611058.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEAD6DD5674EDB7A6243AF5BE"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEAD6DD5674EDB7A6243AF5BE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 30.04.2007 21:46 schrieb Andrew Morton:
> Not really - everything's tangled up.  A bisection search on the
> 2.6.21-rc7-mm2 driver tree would be the best bet.

And the winner is:

gregkh-driver-driver-core-make-uevent-environment-available-in-uevent-fil=
e.patch

Reverting only that from 2.6.21-rc7-mm2 gives me a working kernel
again.

I'll try building 2.6.21-git3 minus that one next, but I'll have
to revert it manually, because my naive attempt to "patch -R" it
failed 1 out of 2 hunks.

HTH
T.

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
- Undetected errors are handled as if no error occurred. (IBM) -


--------------enigEAD6DD5674EDB7A6243AF5BE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGODdLMdB4Whm86/kRAmt/AJ4oeZhZQlRmU8q4c4apkLcszDCPGQCfeAQf
p9mC4P9Z6qzlo/nrZnokt0w=
=zn2T
-----END PGP SIGNATURE-----

--------------enigEAD6DD5674EDB7A6243AF5BE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
