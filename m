Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 175CD6B00B3
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 01:19:23 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Tue, 30 Apr 2013 15:11:26 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E18283578050
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:19:16 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3U55Qjc19988630
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:05:26 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3U5JGhO026987
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:19:16 +1000
Date: Tue, 30 Apr 2013 15:17:18 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 09/18] powerpc: Switch 16GB and 16MB explicit
 hugepages to a different page table format
Message-ID: <20130430051718.GB20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367177859-7893-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WG0/bXtUnGTsWt66"
Content-Disposition: inline
In-Reply-To: <1367177859-7893-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--WG0/bXtUnGTsWt66
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:07:30AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We will be switching PMD_SHIFT to 24 bits to facilitate THP impmenetation.
> With PMD_SHIFT set to 24, we now have 16MB huge pages allocated at PGD le=
vel.
> That means with 32 bit process we cannot allocate normal pages at
> all, because we cover the entire address space with one pgd entry. Fix th=
is
> by switching to a new page table format for hugepages. With the new page =
table
> format for 16GB and 16MB hugepages we won't allocate hugepage directory. =
Instead
> we encode the PTE information directly at the directory level. This force=
s 16MB
> hugepage at PMD level. This will also make the page take walk much simple=
r later
> when we add the THP support.
>=20
> With the new table format we have 4 cases for pgds and pmds:
> (1) invalid (all zeroes)
> (2) pointer to next table, as normal; bottom 6 bits =3D=3D 0
> (3) leaf pte for huge page, bottom two bits !=3D 00
> (4) hugepd pointer, bottom two bits =3D=3D 00, next 4 bits indicate size
> of table
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Mostly ok, except that in several pages your comments imply you have
16M and 16M page directory levels, but you haven't actually made that
change yet.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--WG0/bXtUnGTsWt66
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF/U94ACgkQaILKxv3ab8Z0QQCfQdn7i4FpPxl/wxygybY35S3u
9PEAn27oIHzZf0eXK7sxTx9OhIQB04TP
=jGRf
-----END PGP SIGNATURE-----

--WG0/bXtUnGTsWt66--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
