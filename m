Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 942DD6B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 20:07:52 -0500 (EST)
Message-ID: <1359680851.31386.51.camel@deadeye.wl.decadent.org.uk>
Subject: Re: Bug#695182: [RFC] Reproducible OOM with just a few sleeps
From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 01 Feb 2013 01:07:31 +0000
In-Reply-To: <201301312306.r0VN6tBx012280@como.maths.usyd.edu.au>
References: <201301312306.r0VN6tBx012280@como.maths.usyd.edu.au>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SWzmCrfY7h298Vl8qUCB"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@ucw.cz


--=-SWzmCrfY7h298Vl8qUCB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-02-01 at 10:06 +1100, paul.szabo@sydney.edu.au wrote:
> Dear Ben,
>=20
> > Based on your experience I might propose to change the automatic kernel
> > selection for i386 so that we use 'amd64' on a system with >16GB RAM an=
d
> > a capable processor.
>=20
> Don't you mean change to amd64 for >4GB (or any RAM), never using PAE?
> PAE is broken for any amount of RAM.
[...]

No it isn't.

Ben.

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-SWzmCrfY7h298Vl8qUCB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUQsVU+e/yOyVhhEJAQqXog/+IVILgiQ4pXEQYLwTdIem3AggO4Vjg5iJ
Uball4sfs1ap0/LRygbr2MuvI40S9HQQYeBOU3AL5Y9dNvWdrIPjgsz5URseiyaF
M4TQQ7IBj88rPBUIWzClnmmZ0Qp6HfOKvh/8ezr/geH4eHjtwB9o6VnBUAMV/zhh
3JarsI+cL2dGDtW/11HZRq3KhCStSlVtVpCoA5Ocj2dVnPcgbt01HD/ByEk0KUWQ
rdkQtCk/7PVJebiLyRchqpSo25SEwUoHIZh2q9z2QsRlSW9oBXeDW9clg8NHMF1R
LbgPZNfSQrQLlK+3peA3wszJu3YcZxeLhIzdIN69KJb79DAG2ab4NuglxBV0i7Zj
Pnk1UHMCoOcI2ZDtbdk+ssa0YSKYFFCPovQj6Lz0mTg9VxmqFv1uISh36hsQ5Hbl
uT2t1q7vxSyYxzYQOqe6kQwtxIDJEtz8E+gYj54ACCuMDvH50UDVwV2yQRt00v47
G6Ydr5yEajHV7xDMYO7xSF5X8dmQ6M3GlgaHwPp8t/lbE5CW5dUNwzeJNFdAMygV
VytjvArlBFxVT3+ir4uhIIUdwqQk8dfRbjU8dbDi1nMIgSxX4okYap3IvjYtt5T3
1b5iOm0vLnfOVZDQZB9N2xNO3uiNy++cHRllQqVWGO8hq0YvhIf6mIMGKPzltSxy
BIcBxVNcE58=
=xVrj
-----END PGP SIGNATURE-----

--=-SWzmCrfY7h298Vl8qUCB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
