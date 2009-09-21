Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D20E16B014F
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:25:20 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8LCOVV8006383
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:24:31 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8LCPMQT241944
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:25:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8LCM8N6019864
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:22:09 -0400
Date: Mon, 21 Sep 2009 06:25:20 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] Add MAP_HUGETLB for mmaping pseudo-anonymous huge page
	regions
Message-ID: <20090921122520.GA6706@us.ibm.com>
References: <cover.1251197514.git.ebmunson@us.ibm.com> <20090917154404.e1d3694e.akpm@linux-foundation.org> <20090917174616.f64123fb.akpm@linux-foundation.org> <200909181719.47240.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
In-Reply-To: <200909181719.47240.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru
List-ID: <linux-mm.kvack.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 18 Sep 2009, Arnd Bergmann wrote:

> This patch adds a flag for mmap that will be used to request a huge
> page region that will look like anonymous memory to user space.  This
> is accomplished by using a file on the internal vfsmount.  MAP_HUGETLB
> is a modifier of MAP_ANONYMOUS and so must be specified with it.  The
> region will behave the same as a MAP_ANONYMOUS region using small pages.
>=20
> The patch also adds the MAP_STACK flag, which was previously defined
> only on some architectures but not on others. Since MAP_STACK is meant
> to be a hint only, architectures can define it without assigning a
> specific meaning to it.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I think this is a more sane way of handling the mman flags.

Acked-by: Eric B Munson <ebmunson@us.ibm.com>

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkq3cLAACgkQsnv9E83jkzogIwCg0C3UQ940Rgg3GBLsZPOGpRSV
OqEAn3NAWPo80yUM0uy/L18dcsTRzzG7
=ErOm
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
