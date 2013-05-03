Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 512596B02B3
	for <linux-mm@kvack.org>; Fri,  3 May 2013 01:30:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 3 May 2013 15:23:07 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 854F02CE8053
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:30:34 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r435GdOQ21692518
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:16:40 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r435UXQF029214
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:30:33 +1000
Date: Fri, 3 May 2013 14:53:23 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 04/10] powerpc: Update find_linux_pte_or_hugepte to
 handle transparent hugepages
Message-ID: <20130503045323.GP13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="FmdPcZLZZW6lDAYm"
Content-Disposition: inline
In-Reply-To: <1367178711-8232-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--FmdPcZLZZW6lDAYm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:21:45AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

What's the difference in meaning between pmd_huge() and pmd_large()?


>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/hugetlbpage.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index 8601f2d..081c001 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -954,7 +954,7 @@ pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsign=
ed long ea, unsigned *shift
>  			pdshift =3D PMD_SHIFT;
>  			pm =3D pmd_offset(pu, ea);
> =20
> -			if (pmd_huge(*pm)) {
> +			if (pmd_huge(*pm) || pmd_large(*pm)) {
>  				ret_pte =3D (pte_t *) pm;
>  				goto out;
>  			} else if (is_hugepd(pm))

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--FmdPcZLZZW6lDAYm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGDQsIACgkQaILKxv3ab8YImACcDHu/Yfoj6P+E/cOG0SzhzP3I
YNQAoJD5k+X43Mkyuz9g0ClwfAbcsa0Y
=FggU
-----END PGP SIGNATURE-----

--FmdPcZLZZW6lDAYm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
