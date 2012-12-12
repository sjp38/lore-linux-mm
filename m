Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C86546B0083
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 05:54:13 -0500 (EST)
Date: Wed, 12 Dec 2012 12:55:38 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH, RESEND] asm-generic, mm: pgtable: consolidate zero page
 helpers
Message-ID: <20121212105538.GA14208@otc-wbsnb-06>
References: <1354881215-26257-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1212111906270.18872@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1212111906270.18872@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>, John Crispin <blogic@openwrt.org>


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 11, 2012 at 07:07:14PM -0800, David Rientjes wrote:
> On Fri, 7 Dec 2012, Kirill A. Shutemov wrote:
>=20
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >=20
> > We have two different implementation of is_zero_pfn() and
> > my_zero_pfn() helpers: for architectures with and without zero page
> > coloring.
> >=20
> > Let's consolidate them in <asm-generic/pgtable.h>.
> >=20
>=20
> What's the benefit from doing this other than generalizing some per-arch=
=20
> code?  It simply adds on more layer of redirection to try to find the=20
> implementation that matters for the architecture you're hacking on.

The idea of asm-generic is consolidation arch code which can be re-used
for different arches. It also makes support of new arches easier.

Do you think have copy of the same code here and there is any better?

--=20
 Kirill A. Shutemov

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQyGKqAAoJEAd+omnVudOMyuEQAMemWRvnFt+7wByWD1jXWC2Z
nUe8yPig5B3W4uawzQNJXj7PS9xr+xHCi52KlJT5TLnpPAih8ozor0Ohj+hxWBG0
OssHOzZhk6z+/IEG1DB8UDOmVUK9z3k17yfqsZkx+YB9F/x5tSug1Qt5AHGYvzt8
LXYbtVBx5CJm21TlnnOfx7woy21Q6CgAWhA+wBm+MiUbTN1btI8xmapBAuzrE+vh
1EIFdZe+7uWJOqHNadmVhjFvhF/Bym9z3dY7+hCc6dKvqPVOm2Bd1KJ5Pw3kgXls
m1d2Z6LEdC7k7z1ZtU1T+mUSVSJbEMCc3F9x7FcP24sw/9zYWNX0zG6t2Iz0Mr5N
AQ7uZxWIn9OdEhmViJyoqHDUNBIP+k+fg5M57ZsgB42BR4orJvRgCEtV2Byts+sN
kn0AqJHU2n7v60liv/mzeKKK9z/c+Kjeg3Tp6vRSg7jSjl1Akk9M4urtuu9fFEBw
bNS0IsIdjMwMF5DVXJGR5fCW8wu4r20VvRv8ISjGTo+g7FngSphafmwEq5Fl0/Hh
2c0sZ+j9fpuuvwzzYBUPdulXji8frkHZ4WxMGJ1DINTq6kARaaxGkNFUS1IeteCG
Wpyj+chEnkL+1UwLLdrfGz7gbO/+fmeiuTOAnbS2qOe5zcRD8pcTCBhQ4W/IQXcG
5L9+tvjncCAEktFUZWvH
=6aAs
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
