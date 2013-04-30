Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 68ECD6B00AB
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 22:22:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Tue, 30 Apr 2013 12:12:42 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 26E6B2CE804D
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:22:04 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3U28CeZ23986272
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:08:13 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3U2M2Cb016865
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:22:02 +1000
Date: Tue, 30 Apr 2013 12:21:49 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 01/18] mm/THP: HPAGE_SHIFT is not a #define on some
 arch
Message-ID: <20130430022149.GU20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367177859-7893-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Sh7h4lnU5nPTsIof"
Content-Disposition: inline
In-Reply-To: <1367177859-7893-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--Sh7h4lnU5nPTsIof
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:07:22AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> On archs like powerpc that support different hugepage sizes, HPAGE_SHIFT
> and other derived values like HPAGE_PMD_ORDER are not constants. So move
> that to hugepage_init

These seems to miss the point.  Those variables may be defined in
terms of HPAGE_SHIFT right now, but that is of itself kind of broken.
The transparent hugepage mechanism only works if the hugepage size is
equal to the PMD size - and PMD_SHIFT remains a compile time constant.

There's no reason having transparent hugepage should force the PMD
size of hugepage to be the default for other purposes - it should be
possible to do THP as long as PMD-sized is a possible hugepage size.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--Sh7h4lnU5nPTsIof
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF/Kr0ACgkQaILKxv3ab8YK6ACePQzw/9X5H+l8PCCPLjXKGkKa
pYoAn2p0muo2mU8ZvptskameU9fEeUY/
=f8lO
-----END PGP SIGNATURE-----

--Sh7h4lnU5nPTsIof--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
