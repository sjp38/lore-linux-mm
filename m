Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id DD0B96B02B5
	for <linux-mm@kvack.org>; Fri,  3 May 2013 01:30:42 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 3 May 2013 15:18:23 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3F65A2BB0058
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:30:35 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r435Gna520512786
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:16:49 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r435UXXI029232
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:30:34 +1000
Date: Fri, 3 May 2013 15:30:27 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 10/10] powerpc: disable assert_pte_locked
Message-ID: <20130503053027.GV13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="w1TwAseT95X423KH"
Content-Disposition: inline
In-Reply-To: <1367178711-8232-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--w1TwAseT95X423KH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:21:51AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> With THP we set pmd to none, before we do pte_clear. Hence we can't
> walk page table to get the pte lock ptr and verify whether it is locked.
> THP do take pte lock before calling pte_clear. So we don't change the loc=
king
> rules here. It is that we can't use page table walking to check whether
> pte locks are help with THP.
>=20
> NOTE: This needs to be re-written. Not to be merged upstream.

So, rewrite it..

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/mm/pgtable.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
> index 214130a..d77f94f 100644
> --- a/arch/powerpc/mm/pgtable.c
> +++ b/arch/powerpc/mm/pgtable.c
> @@ -224,6 +224,7 @@ int ptep_set_access_flags(struct vm_area_struct *vma,=
 unsigned long address,
>  #ifdef CONFIG_DEBUG_VM
>  void assert_pte_locked(struct mm_struct *mm, unsigned long addr)
>  {
> +#if 0
>  	pgd_t *pgd;
>  	pud_t *pud;
>  	pmd_t *pmd;
> @@ -237,6 +238,7 @@ void assert_pte_locked(struct mm_struct *mm, unsigned=
 long addr)
>  	pmd =3D pmd_offset(pud, addr);
>  	BUG_ON(!pmd_present(*pmd));
>  	assert_spin_locked(pte_lockptr(mm, pmd));
> +#endif
>  }
>  #endif /* CONFIG_DEBUG_VM */
> =20

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--w1TwAseT95X423KH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGDS3MACgkQaILKxv3ab8Z3rgCfZ3GXpCcjc5lE1xzIeS/i+I8b
Hh4Anjhya8cFF6nxZgjOoRwb71la58Fz
=9w60
-----END PGP SIGNATURE-----

--w1TwAseT95X423KH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
