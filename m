Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6SLO04u016513
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 17:24:00 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SLO0GI240074
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 17:24:00 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SLO0OK004447
	for <linux-mm@kvack.org>; Mon, 28 Jul 2008 17:24:00 -0400
Date: Mon, 28 Jul 2008 14:23:54 -0700
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080728212354.GB8450@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com> <1217277204.23502.36.camel@nimitz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wq9mPyueHGvFACwf"
Content-Disposition: inline
In-Reply-To: <1217277204.23502.36.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 28 Jul 2008, Dave Hansen wrote:

> On Mon, 2008-07-28 at 12:17 -0700, Eric Munson wrote:
> >=20
> > This patch stack introduces a personality flag that indicates the
> > kernel
> > should setup the stack as a hugetlbfs-backed region. A userspace
> > utility
> > may set this flag then exec a process whose stack is to be backed by
> > hugetlb pages.
>=20
> I didn't see it mentioned here, but these stacks are fixed-size, right?
> They can't actually grow and are fixed in size at exec() time, right?
>=20
> -- Dave

The stack VMA is a fixed size but the pages will be faulted in as needed.

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--wq9mPyueHGvFACwf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIjjjqsnv9E83jkzoRAugvAKD36x3OyfiN/GtGM+x0LJ6SL7e7TgCdHOOf
OGGM1jiwgdCWkwRUj/Gd/Fg=
=5CJt
-----END PGP SIGNATURE-----

--wq9mPyueHGvFACwf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
