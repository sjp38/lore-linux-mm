Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8ADA56B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:08:09 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n81D4L2I000427
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 07:04:22 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n81D85ls159268
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 07:08:07 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n81D84um013915
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 07:08:04 -0600
Date: Tue, 1 Sep 2009 14:08:01 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge
	page regions
Message-ID: <20090901130801.GB7995@us.ibm.com>
References: <cover.1251282769.git.ebmunson@us.ibm.com> <1c66a9e98a73d61c611e5cf09b276e954965046e.1251282769.git.ebmunson@us.ibm.com> <1721a3e8bdf8f311d2388951ec65a24d37b513b1.1251282769.git.ebmunson@us.ibm.com> <Pine.LNX.4.64.0908312036410.16402@sister.anvils> <20090901094635.GA7995@us.ibm.com> <Pine.LNX.4.64.0909011128530.16601@sister.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lEGEL1/lMxI0MVQ2"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909011128530.16601@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>


--lEGEL1/lMxI0MVQ2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 01 Sep 2009, Hugh Dickins wrote:

snip

>=20
> Sorry, no, I disagree.
>=20
> I agree that the fs/hugetlbfs/inode.c:941 message and backtrace in
> themselves are symptoms of the can_do_hugetlb_shm() bug that Mel
> reported and fixed (I'm agreeing a little too readily, I've not
> actually studied that bug and fix, I'm taking it on trust).
>=20
> But that does not explain how last year's openSUSE 11.1 userspace
> was trying for a MAP_HUGETLB mapping at startup on PowerPC (but
> not on x86), while you're only introducing MAP_HUGETLB now.
>=20
> That is explained by you #defining MAP_HUGETLB in include/asm-generic/
> mman-common.h to a number which is already being used for other MAP_s
> on some architectures.  That's a separate bug which needs to be fixed
> by distributing the MAP_HUGETLB definition across various asm*/mman.h.
>=20
> Hugh
>=20

Would it be okay to keep the define in include/asm-generic/mman.h
if a value that is known free across all architectures is used?
0x080000 is not used by any arch and, AFAICT would work just as well.

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--lEGEL1/lMxI0MVQ2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqdHLEACgkQsnv9E83jkzr89ACdECI9i/3KubokFNiLAPhLViqC
i4MAoM1nvr8YwK+B5DCiggN1AvbMge4z
=MUAy
-----END PGP SIGNATURE-----

--lEGEL1/lMxI0MVQ2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
