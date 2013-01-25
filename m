Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 0CD3D6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:09:17 -0500 (EST)
Message-ID: <1359118913.3146.3.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Bug#695182: [PATCH] Subtract min_free_kbytes from dirtyable
 memory
From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 25 Jan 2013 13:01:53 +0000
In-Reply-To: <201301250953.r0P9rOSe012192@como.maths.usyd.edu.au>
References: <201301250953.r0P9rOSe012192@como.maths.usyd.edu.au>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iFYjDGU4L+x/XuQ3FgUD"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au, 695182@bugs.debian.org
Cc: minchan@kernel.org, psz@maths.usyd.edu.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--=-iFYjDGU4L+x/XuQ3FgUD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-01-25 at 20:53 +1100, paul.szabo@sydney.edu.au wrote:
> Dear Minchan,
>=20
> > So what's the effect for user?
> > ...
> > It seems you saw old kernel.
> > ...
> > Current kernel includes ...
> > So I think we don't need this patch.
>=20
> As I understand now, my patch is "right" and needed for older kernels;
> for newer kernels, the issue has been fixed in equivalent ways; it was
> an oversight that the change was not backported; and any justification
> you need, you can get from those "later better" patches.
[...]

If you can identify where it was fixed then your patch for older
versions should go to stable with a reference to the upstream fix (see
Documentation/stable_kernel_rules.txt).

Ben.

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-iFYjDGU4L+x/XuQ3FgUD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUQKCQee/yOyVhhEJAQrv8w/+K0UfY/Du3BVyBlioflti6Woj1AI53pU3
6nCmPedozQADW/LYynQ5SlHyMJ+M7JZeOk9UKHD7TgvjIDTNKj54SweKIbpVFQI8
G9RxanI55W8yMblqnb9k5ud2t6Fxw/klJbNFNROkby+64+bZCc2tvIDRE8yuIrMR
8/dSqy+VEkCDYlrQLR1I3+dSAAkN4k0AWGaRng1FCcz2d4s2ki6H39mP0ahBfRMY
xNgnC6erhUwKm1jK1CTpldd+2p2rufCspq24pUAJgPfc2GmlB28g+j7fcA0CuVxM
dCnmfn2fGTGu3S5cntbKa64qjGqGgX5yY4xxQOpHAyYUhaUJPxpZCwRC6FPSp3q9
VJE45OoMbfsWT32cOGptVhckRNfws0pdZOvL5fjI1t62+p49k1Tu2mcerW5+Xfa2
R+mdbCTSCDBx+qZz8E6tS2PCx4dahfdTNc/dGIetG8wTc1YP+XnI3/KIXY/JHJhf
2WlNH0+PyHRSJ51n9+xhSFA10QpQWetZZ6IBsNC9nlSo7itLzdqix+8q72ZGPZyV
IPFhaAWRBScXxCAn0+ECnb2dIN11y+pcUjArFq2DDPzvW3CjMH2EQxMAcYfbKO84
kCR1QbaZ2en4hcqV5hHgmLxFISP5d7BFzQvAjq2MII5c/Qxo9PdQqTH/Ce/WkmbB
S0q0xmrs2SQ=
=jd1m
-----END PGP SIGNATURE-----

--=-iFYjDGU4L+x/XuQ3FgUD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
