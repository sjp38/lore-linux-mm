Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2A9946B00B4
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 01:19:23 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Tue, 30 Apr 2013 15:11:26 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 7A30B2CE804C
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:19:17 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3U5JAYA17629274
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:19:11 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3U5JGaQ026984
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 15:19:16 +1000
Date: Tue, 30 Apr 2013 15:16:34 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 08/18] powerpc: New hugepage directory format
Message-ID: <20130430051634.GA20202@truffula.fritz.box>
References: <1367177859-7893-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367177859-7893-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VcZjVMblxkg0/8Ur"
Content-Disposition: inline
In-Reply-To: <1367177859-7893-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--VcZjVMblxkg0/8Ur
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:07:29AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> Change the hugepage directory format so that we can have leaf ptes direct=
ly
> at page directory avoiding the allocation of hugepage directory.
>=20
> With the new table format we have 3 cases for pgds and pmds:
> (1) invalid (all zeroes)
> (2) pointer to next table, as normal; bottom 6 bits =3D=3D 0
> (4) hugepd pointer, bottom two bits =3D=3D 00, next 4 bits indicate size =
of table
>=20
> Instead of storing shift value in hugepd pointer we use mmu_psize_def ind=
ex
> so that we can fit all the supported hugepage size in 4 bits
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Looks ok.

Reviewed-by: David Gibson <david@gibson.dropbear.id.au>

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--VcZjVMblxkg0/8Ur
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF/U7IACgkQaILKxv3ab8YN3gCeKnNvwfsBdlQsaxOeHcN3Jq7V
jEUAnimhVE/KpOz8T8NTKyEuKlpLYFTy
=566/
-----END PGP SIGNATURE-----

--VcZjVMblxkg0/8Ur--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
