Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 1BE476B0037
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:42:04 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Thu, 11 Apr 2013 13:34:38 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 890AC2BB0054
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:55 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B3fmOX8651024
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:50 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B3frVT027833
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:41:54 +1000
Date: Thu, 11 Apr 2013 13:20:03 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 09/25] powerpc: Fix hpte_decode to use the correct
 decoding for page sizes
Message-ID: <20130411032003.GS8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OowMmFE4aK71mEhh"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--OowMmFE4aK71mEhh
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:47AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> As per ISA doc, we encode base and actual page size in the LP bits of
> PTE. The number of bit used to encode the page sizes depend on actual
> page size.  ISA doc lists this as
>=20
>    PTE LP     actual page size
> rrrr rrrz 	>=3D8KB
> rrrr rrzz	>=3D16KB
> rrrr rzzz 	>=3D32KB
> rrrr zzzz 	>=3D64KB
> rrrz zzzz 	>=3D128KB
> rrzz zzzz 	>=3D256KB
> rzzz zzzz	>=3D512KB
> zzzz zzzz 	>=3D1MB
>=20
> ISA doc also says
> "The values of the =E2=80=9Cz=E2=80=9D bits used to specify each size, al=
ong with all possible
> values of =E2=80=9Cr=E2=80=9D bits in the LP field, must result in LP val=
ues distinct from
> other LP values for other sizes."
>=20
> based on the above update hpte_decode to use the correct decoding for LP =
bits.
>=20
> Acked-by: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: David Gibson <david@gibson.dropbear.id.au>
--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--OowMmFE4aK71mEhh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFmK+MACgkQaILKxv3ab8akdgCdHfqzHW5v6BVA7mu4VZ7FJI54
wDAAn2fFJMLq67MmyH++f57HGe5O/LhK
=P2Me
-----END PGP SIGNATURE-----

--OowMmFE4aK71mEhh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
