Message-ID: <46390129.4020801@imap.cc>
Date: Wed, 02 May 2007 23:22:49 +0200
From: Tilman Schmidt <tilman@imap.cc>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
 (-1)
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org>	<46338AEB.2070109@imap.cc>	<20070428141024.887342bd.akpm@linux-foundation.org>	<4636248E.7030309@imap.cc>	<20070430112130.b64321d3.akpm@linux-foundation.org>	<46364346.6030407@imap.cc>	<20070430124638.10611058.akpm@linux-foundation.org>	<46383742.9050503@imap.cc>	<20070502001000.8460fb31.akpm@linux-foundation.org>	<20070502075238.GA9083@suse.de>	<4638CC03.7030903@imap.cc> <20070502130746.265bba0f.akpm@linux-foundation.org>
In-Reply-To: <20070502130746.265bba0f.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig00F219DB640D3586A4CAC9A8"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <gregkh@suse.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig00F219DB640D3586A4CAC9A8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 02.05.2007 22:07 schrieb Andrew Morton:
>> Started to git-bisect mainline now, but that will take some time.
[...]
> I don't think there's much point in you doing that.  We know what the b=
ug is.

Good. Saves me some work. :-)

If you'd like me to test anything, just let me know.

Thanks,
Tilman

--=20
Tilman Schmidt                          E-Mail: tilman@imap.cc
Bonn, Germany
- Undetected errors are handled as if no error occurred. (IBM) -


--------------enig00F219DB640D3586A4CAC9A8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3rc1 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGOQExMdB4Whm86/kRAm9jAJ9DZjLpQWN1FY27ZWHT1smk0xojlwCggv1N
1KQiVAt6tlPyy73mtjYL1DI=
=+Q0I
-----END PGP SIGNATURE-----

--------------enig00F219DB640D3586A4CAC9A8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
