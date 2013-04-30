Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B0BE26B00AD
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 22:24:33 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Tue, 30 Apr 2013 12:17:04 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id A548E2BB0054
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:24:28 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3U2OM1L20250864
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:24:22 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3U2OS5U030260
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:24:28 +1000
Date: Tue, 30 Apr 2013 12:24:19 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 01/18] mm/THP: HPAGE_SHIFT is not a #define on some
 arch
Message-ID: <20130430022419.GW20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367177859-7893-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130430022149.GU20202@truffula.fritz.box>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="AAiVQQES42Kk67ff"
Content-Disposition: inline
In-Reply-To: <20130430022149.GU20202@truffula.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--AAiVQQES42Kk67ff
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 30, 2013 at 12:21:49PM +1000, David Gibson wrote:
> On Mon, Apr 29, 2013 at 01:07:22AM +0530, Aneesh Kumar K.V wrote:
> > From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> >=20
> > On archs like powerpc that support different hugepage sizes, HPAGE_SHIFT
> > and other derived values like HPAGE_PMD_ORDER are not constants. So move
> > that to hugepage_init
>=20
> These seems to miss the point.  Those variables may be defined in
> terms of HPAGE_SHIFT right now, but that is of itself kind of broken.
> The transparent hugepage mechanism only works if the hugepage size is
> equal to the PMD size - and PMD_SHIFT remains a compile time constant.
>=20
> There's no reason having transparent hugepage should force the PMD
> size of hugepage to be the default for other purposes - it should be
> possible to do THP as long as PMD-sized is a possible hugepage size.

Oh, also, I'm pretty sure I said something similar on the last
posting.  Receiving review comments and then ignoring them does not
count as "Reviewed-by"...

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--AAiVQQES42Kk67ff
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF/K1MACgkQaILKxv3ab8ZG0ACdE7EVAPUvYm9ZKpBCGl5kcxUZ
mdAAnjuJ05ld6KGO2nz+O7O1clcnF5kP
=mSnw
-----END PGP SIGNATURE-----

--AAiVQQES42Kk67ff--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
