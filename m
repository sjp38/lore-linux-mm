Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id BD3F26B0070
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 04:51:01 -0500 (EST)
Date: Fri, 16 Nov 2012 11:52:06 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [next:akpm 205/376] mm/huge_memory.c:716:2: error: implicit
 declaration of function 'pfn_pmd'
Message-ID: <20121116095206.GA4043@otc-wbsnb-06>
References: <50a4c285.wqKVmKLchrLESqoS%fengguang.wu@intel.com>
 <20121115142728.190c5b3e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Content-Disposition: inline
In-Reply-To: <20121115142728.190c5b3e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mm@kvack.org, linux-mips@linux-mips.org, linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 15, 2012 at 02:27:28PM -0800, Andrew Morton wrote:
> On Thu, 15 Nov 2012 18:23:01 +0800
> kbuild test robot <fengguang.wu@intel.com> wrote:
>=20
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.g=
it akpm
> > head:   d3faae60d84f586ff8937b77c8476bca1b5f8ec6
> > commit: 165a1669c89b5fa2f6c54bf609b408a592f024b3 [205/376] thp: copy_hu=
ge_pmd(): copy huge zero page
> > config: make ARCH=3Dmips allmodconfig
> >=20
> > All error/warnings:
> >=20
> > mm/huge_memory.c: In function 'set_huge_zero_page':
> > mm/huge_memory.c:716:2: error: implicit declaration of function 'pfn_pm=
d' [-Werror=3Dimplicit-function-declaration]
> > mm/huge_memory.c:716:8: error: incompatible types when assigning to typ=
e 'pmd_t' from type 'int'
> > mm/huge_memory.c: In function 'do_huge_pmd_numa_page':
> > mm/huge_memory.c:825:2: error: incompatible type for argument 3 of 'upd=
ate_mmu_cache_pmd'
> > In file included from include/linux/mm.h:44:0,
> >                  from mm/huge_memory.c:8:
> > arch/mips/include/asm/pgtable.h:385:20: note: expected 'struct pmd_t *'=
 but argument is of type 'pmd_t'
> > mm/huge_memory.c:895:2: error: incompatible type for argument 3 of 'upd=
ate_mmu_cache_pmd'
> > In file included from include/linux/mm.h:44:0,
> >                  from mm/huge_memory.c:8:
> > arch/mips/include/asm/pgtable.h:385:20: note: expected 'struct pmd_t *'=
 but argument is of type 'pmd_t'
> > cc1: some warnings being treated as errors
> >=20
> > vim +716 +/pfn_pmd mm/huge_memory.c
> >=20
> > 0bbbc0b3 Andrea Arcangeli   2011-01-13  710  #endif
> > 71e3aac0 Andrea Arcangeli   2011-01-13  711 =20
> > 165a1669 Kirill A. Shutemov 2012-11-15  712  static void set_huge_zero_=
page(pgtable_t pgtable, struct mm_struct *mm,
> > 165a1669 Kirill A. Shutemov 2012-11-15  713  		struct vm_area_struct *v=
ma, unsigned long haddr, pmd_t *pmd)
> > 165a1669 Kirill A. Shutemov 2012-11-15  714  {
> > 165a1669 Kirill A. Shutemov 2012-11-15  715  	pmd_t entry;
> > 165a1669 Kirill A. Shutemov 2012-11-15 @716  	entry =3D pfn_pmd(huge_ze=
ro_pfn, vma->vm_page_prot);
> > 165a1669 Kirill A. Shutemov 2012-11-15  717  	entry =3D pmd_wrprotect(e=
ntry);
> > 165a1669 Kirill A. Shutemov 2012-11-15  718  	entry =3D pmd_mkhuge(entr=
y);
> > 165a1669 Kirill A. Shutemov 2012-11-15  719  	set_pmd_at(mm, haddr, pmd=
, entry);
>=20
> hm.  mips doesn't implement pfn_pmd() - quite a few architectures
> don't.

I think it would be easier to fix it on arch side. Ralf?

> Not sure about the update_mmu_cache_pmd() thing.

I'll send a patchset to fix it. (it's not related to huge zero page)

--=20
 Kirill A. Shutemov

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpgzGAAoJEAd+omnVudOMSgsP/i2Q3JaEN32QnJ7E4qbGC/05
oJrGvfVxXkRRT//bLYG7zADB9ZhOcFHgyy82GLRH4GV4LNIHPs5VTIv/q85nbTYe
SvWN8TazqmTmDwJQu43isU//Vi5SYN+p79dD9bM/K/Ol5O1kiDimcz2pKDkf4C85
5Te5SyloKOVWWkpHmc8zARmG2PBlAtVa0laR4pIrSB4qQLrdhvtYhKMoqZQsB3z9
Q5Wf2Q9zKJCEQpmBjC1Wosq6WEKJUs3ZfbONCFIEb6geDHUTr2g2/dm7QyQk8ucp
W3/iYDPHlciTcnWik6pi2w0ZYaABGhpDVmlGs7lYk5uqeTIk+my18IdJ1G2IaxGn
MAhdGzg55gRSjwQ+kmN3Icerz9eYm80HCZMhoGDJX5hhxqgH+TWf+DIyhVSpZY5h
X0s0e9JOqhu6qA9wpungm1D6GdiFK1vtHx6ptjUgetqi+mbiT+hnobaaeCADSWOG
cemHeF0BN7pwg+R47Rhfz27jeaBscwxCIhnFFGVIXIz0ctgcLzYk0UHXazu9ogrM
sMec8s96WvxanwuvO+C3wQIzzhP77WznDrU7To/BaohD0WEQzdFGDldntUIzygKI
E9LDnMiUO6iQZAB4dUX0vFWn2F0GgqLxqNdLHVwKgln6xY6d4mk1Qap7A2fDFcbQ
RLb6+hl7ypvWeQZGzD9t
=2YxA
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
