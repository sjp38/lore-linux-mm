Message-ID: <46364346.6030407@imap.cc>
Date: Mon, 30 Apr 2007 21:28:06 +0200
From: Tilman Schmidt <tilman@imap.cc>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>	<46338AEB.2070109@imap.cc>	<20070428141024.887342bd.akpm@linux-foundation.org>	<4636248E.7030309@imap.cc> <20070430112130.b64321d3.akpm@linux-foundation.org>
In-Reply-To: <20070430112130.b64321d3.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6850B0B8D4D50A301B397375"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6850B0B8D4D50A301B397375
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 30.04.2007 20:21 schrieb Andrew Morton:
> A lot of Greg's driver tree has gone upstream, so please check current
> mainline.

2.6.21-final is fine.

>  If that's OK then we need to pick through the difference between
> 2.6.21-rc7-mm2's driver tree and the patches which went into mainline. =
 And
> that's a pretty small set.

I'm not quite sure how to determine that difference. Can you just provide=

me with a list of patches you'd like me to test?

Thanks,
Tilman

--=20
Tilman Schmidt                                  E-Mail: tilman@imap.cc
Wehrhausweg 66                                  Fax: +49 228 4299019
53227 Bonn
Germany


--------------enig6850B0B8D4D50A301B397375
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGNkNOMdB4Whm86/kRAtHKAJ9Pl1M57E0ot8J4Je7eZzDk10247QCbBLDP
R9dJxM+2y6xZgu9rjy/dEbE=
=K3Ic
-----END PGP SIGNATURE-----

--------------enig6850B0B8D4D50A301B397375--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
