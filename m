Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 502D86B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 06:53:34 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7IAqVJL017424
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 06:52:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7IArcnh221470
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 06:53:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7IArbQS008572
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 06:53:38 -0400
Date: Tue, 18 Aug 2009 11:53:35 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH 0/3] Add pseudo-anonymous huge page mappings V3
Message-ID: <20090818105335.GA23058@us.ibm.com>
References: <cover.1250258125.git.ebmunson@us.ibm.com> <87d46usg0q.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9jxsPFA5p3P2qPhR"
Content-Disposition: inline
In-Reply-To: <87d46usg0q.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com
List-ID: <linux-mm.kvack.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 17 Aug 2009, Andi Kleen wrote:

> Eric B Munson <ebmunson@us.ibm.com> writes:
>=20
> > This patch set adds a flag to mmap that allows the user to request
> > a mapping to be backed with huge pages.  This mapping will borrow
> > functionality from the huge page shm code to create a file on the
> > kernel internal mount and uses it to approximate an anonymous
> > mapping.  The MAP_HUGETLB flag is a modifier to MAP_ANONYMOUS
> > and will not work without both flags being preset.
>=20
>=20
> You seem to have forgotten to describe WHY you want this?
>=20
> From my guess, this seems to be another step into turning hugetlb.c
> into another parallel VM implementation. Instead of basically
> developing two parallel VMs wouldn't it be better to unify the two?
>=20
> I think extending hugetlb.c forever without ever thinking about
> that is not the right approach.
>=20
> -Andi
>=20
> --=20
> ak@linux.intel.com -- Speaking for myself only.
>=20

This patch is meant to simplify the programming model because presently
there is a large chunk of boiler plate code required to create private,
hugepage backed mappings.  This patch would allow use of huge pages=20
without linking to libhugetlbfs or having hugetblfs mounted.

Unification would provide these same benefits, but it has been resisted
each time that it has been suggested for several reasons.  It would
break PAGE_SIZE assumptions across the kernel.  It makes page-table
abstractions really expensive.  And it does not provide any benefit on
architectures that do not support huge pages, incurring fast path
penalties wihtout providing any benefit on these architectures.

Eric

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--9jxsPFA5p3P2qPhR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqKiC8ACgkQsnv9E83jkzqTJgCeMf/rZ3pXtxYusEP2hdQCGRRz
yScAnjJQiV8ByJmZXqeNfrTwMMyrhCZq
=5KNG
-----END PGP SIGNATURE-----

--9jxsPFA5p3P2qPhR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
