Message-ID: <46A5C8B0.5060401@imap.cc>
Date: Tue, 24 Jul 2007 11:38:56 +0200
From: Tilman Schmidt <tilman@imap.cc>
MIME-Version: 1.0
Subject: Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au>	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	 <20070723221846.d2744f42.akpm@linux-foundation.org> <2c0942db0707232301o5ab428bdrd1bc831cacf806c@mail.gmail.com>
In-Reply-To: <2c0942db0707232301o5ab428bdrd1bc831cacf806c@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7D20BFFEDF91EB3B221A9A96"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7D20BFFEDF91EB3B221A9A96
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Ray Lee schrieb:
> I spend a lot of time each day watching my computer fault my
> workingset back in when I switch contexts. I'd rather I didn't have to
> do that. Unfortunately, that's a pretty subjective problem report. For
> whatever it's worth, we have pretty subjective solution reports
> pointing to swap prefetch as providing a fix for them.

Add me.

> My concern is that a subjective problem report may not be good enough.

That's my impression too, seeing the insistence on numbers.

> So, what do I measure to make this an objective problem report?

That seems to be the crux of the matter: how to measure subjective
usability issues (aka user experience) when simple reports along the
lines of "A is much better than B for everyday work" are not enough.
The same problem already impaired the "fair scheduler" discussion.
It would really help to have a clear direction there.

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--------------enig7D20BFFEDF91EB3B221A9A96
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGpciwMdB4Whm86/kRApXjAJ9DH12VDcvttfRPtDCRrEDs0emn+wCfZgl1
pEWhTqYquIM2Hb/O7HE1gnY=
=yI2D
-----END PGP SIGNATURE-----

--------------enig7D20BFFEDF91EB3B221A9A96--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
