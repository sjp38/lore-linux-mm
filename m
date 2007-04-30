Message-ID: <46366082.2090701@imap.cc>
Date: Mon, 30 Apr 2007 23:32:50 +0200
From: Tilman Schmidt <tilman@imap.cc>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>	<46338AEB.2070109@imap.cc>	<20070428141024.887342bd.akpm@linux-foundation.org>	<4636248E.7030309@imap.cc>	<20070430112130.b64321d3.akpm@linux-foundation.org>	<46364346.6030407@imap.cc> <20070430124638.10611058.akpm@linux-foundation.org>
In-Reply-To: <20070430124638.10611058.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEACE2589D3800D1B7F99AAC8"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEACE2589D3800D1B7F99AAC8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 30.04.2007 21:46 schrieb Andrew Morton:

>> 2.6.21-final is fine.
>=20
> Sure, but what about 2.6.21-git3 (or, better, current -git)?

OIC. Sorry for being dense. Will check.

>>>  If that's OK then we need to pick through the difference between
>>> 2.6.21-rc7-mm2's driver tree and the patches which went into mainline=
=2E  And
>>> that's a pretty small set.
>> I'm not quite sure how to determine that difference. Can you just prov=
ide
>> me with a list of patches you'd like me to test?
>=20
> Not really - everything's tangled up.  A bisection search on the
> 2.6.21-rc7-mm2 driver tree would be the best bet.

Ok. No prob. It'll just take a bit of time. (Compiling a kernel on
that machine takes about 4 hours.)

I'll be back. :-)

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
- Undetected errors are handled as if no error occurred. (IBM) -


--------------enigEACE2589D3800D1B7F99AAC8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGNmCOMdB4Whm86/kRAhK/AJ4sbnHVvKJ8vjEzkq49VuvE041C0ACfbKNw
7HwTCKZPYg2HoZqndUrLpJs=
=RASc
-----END PGP SIGNATURE-----

--------------enigEACE2589D3800D1B7F99AAC8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
