Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C79F06B0152
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:27:43 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8LCPAZx025751
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:25:10 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8LCRnjY255476
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:27:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8LCOZL5027767
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 08:24:35 -0400
Date: Mon, 21 Sep 2009 06:27:47 -0600
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] remove duplicate asm/mman.h files
Message-ID: <20090921122747.GB6706@us.ibm.com>
References: <cover.1251197514.git.ebmunson@us.ibm.com> <20090917174616.f64123fb.akpm@linux-foundation.org> <200909181719.47240.arnd@arndb.de> <200909181848.42192.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ADZbWkCsHQ7r3kzd"
Content-Disposition: inline
In-Reply-To: <200909181848.42192.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, rth@twiddle.net, ink@jurassic.park.msu.ru
List-ID: <linux-mm.kvack.org>


--ADZbWkCsHQ7r3kzd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 18 Sep 2009, Arnd Bergmann wrote:

> A number of architectures have identical asm/mman.h files,
> x86 differs only in a single line, so they can all be merged
> by using the new generic file.
>=20
> The remaining asm/mman.h files are substantially different
> from each other.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Eric B Munson <ebmunson@us.ibm.com>

--ADZbWkCsHQ7r3kzd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkq3cUIACgkQsnv9E83jkzoyDwCfZ/rslkDkEqdXk9m8Fn5xub0y
xAAAoLj4kDVjhTchT1jPjJh5WQfVh0g5
=7X9j
-----END PGP SIGNATURE-----

--ADZbWkCsHQ7r3kzd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
