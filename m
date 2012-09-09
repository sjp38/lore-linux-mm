Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id AAC2B6B0062
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 12:57:25 -0400 (EDT)
Message-ID: <1347209830.7709.39.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Consider for longterm kernels: mm: avoid swapping out with
 swappiness==0
From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 09 Sep 2012 17:57:10 +0100
In-Reply-To: <5038E7AA.5030107@gmail.com>
References: <5038E7AA.5030107@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wYhpxHhSKRlkiylv7G9Y"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Zdenek Kaspar <zkaspar82@gmail.com>, linux-mm@kvack.org


--=-wYhpxHhSKRlkiylv7G9Y
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-08-25 at 16:56 +0200, Zdenek Kaspar wrote:
> Hi Greg,
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dcommit=
;h=3Dfe35004fbf9eaf67482b074a2e032abb9c89b1dd
>=20
> In short: this patch seems beneficial for users trying to avoid memory
> swapping at all costs but they want to keep swap for emergency reasons.
>=20
> More details: https://lkml.org/lkml/2012/3/2/320
>=20
> Its included in 3.5, so could this be considered for -longterm kernels ?

Andrew, Rik, does this seem appropriate for longterm?

Ben.

--=20
Ben Hutchings
Time is nature's way of making sure that everything doesn't happen at once.

--=-wYhpxHhSKRlkiylv7G9Y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUEzKZue/yOyVhhEJAQoB2hAAjI0JBOCuzxGuFFbAgBkzT6EniYl0wyUP
prVyB89lGXnaBP5Fxrd1oMkKZ0OG5vtWYvtRTOB1v1qTlfj3QpT9btGg/mQ3YrXs
ECbo/aDj1XZS9o8ycxKeIXYbfVNU4qq0LrA4v/xxwAG2VZRySHNLVzwD20Kx9gTt
Nmdv2tUtKjrDIQAH0RfrVoweeGYQHahztWUOyEaLjfE8HMEIsaQh1Ps/SNpfT7GO
tenpdyGY2kagvxERtTte7GA05imhetRJHM+086v9A5kN8/kkwBnW7zz3WNm8vMN4
VxES+vH9WZNZTsIjm1EetgThbn4PF0AYWJLiSPazSqSairzB2Fiqkoa1MRbfCShw
klRSvSJVAwPc1NaC2k417u0CR8upJYOV/lfi2f4McPtn6tJH6KUwxamJ1pKt6bAE
UDdqQdInECjZ3ECdZgVJbdzuNIC/vRsOlxVwq/ZtsKrQXYPNStO832fVx2sNim10
nDpiZdxokYBOTcY9ycUBD9W2/AYYlyOUWa7nDnDNQUu+NoWRweOQqGzVy15jwWeU
c721n5vWQgbFkETewi5WLSVcQfcxhUZkFRcbKtgVR5c5ssHFVTGkhW1uAcS+xptE
lm7rtedmriDSgLDi7eWWyw3F4nuX+/DrMEYlB4H8JoRhPPZPXyG9EXPwvWSxtlTq
TdbBqCpJF5w=
=MsKa
-----END PGP SIGNATURE-----

--=-wYhpxHhSKRlkiylv7G9Y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
