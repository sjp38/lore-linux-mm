Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A4A3F6B0032
	for <linux-mm@kvack.org>; Fri,  2 Jan 2015 11:03:49 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id k11so4584482wes.6
        for <linux-mm@kvack.org>; Fri, 02 Jan 2015 08:03:49 -0800 (PST)
Received: from imgpgp01.kl.imgtec.org (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTPS id gd5si43241393wjb.178.2015.01.02.08.03.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 Jan 2015 08:03:48 -0800 (PST)
Message-ID: <54A6C161.30300@imgtec.com>
Date: Fri, 2 Jan 2015 16:03:45 +0000
From: James Hogan <james.hogan@imgtec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 22/38] metag: drop _PAGE_FILE and pte_file()-related helpers
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com> <1419423766-114457-23-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-23-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="OEPKX6FcXiONUNlg4Bbe1hW0RMjh59KTI"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

--OEPKX6FcXiONUNlg4Bbe1hW0RMjh59KTI
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 24/12/14 12:22, Kirill A. Shutemov wrote:
> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: James Hogan <james.hogan@imgtec.com>

Acked-by: James Hogan <james.hogan@imgtec.com>

Cheers
James

> ---
>  arch/metag/include/asm/pgtable.h | 6 ------
>  1 file changed, 6 deletions(-)
>=20
> diff --git a/arch/metag/include/asm/pgtable.h b/arch/metag/include/asm/=
pgtable.h
> index 0d9dc5487296..d0604c0a8702 100644
> --- a/arch/metag/include/asm/pgtable.h
> +++ b/arch/metag/include/asm/pgtable.h
> @@ -47,7 +47,6 @@
>   */
>  #define _PAGE_ACCESSED		_PAGE_ALWAYS_ZERO_1
>  #define _PAGE_DIRTY		_PAGE_ALWAYS_ZERO_2
> -#define _PAGE_FILE		_PAGE_ALWAYS_ZERO_3
> =20
>  /* Pages owned, and protected by, the kernel. */
>  #define _PAGE_KERNEL		_PAGE_PRIV
> @@ -219,7 +218,6 @@ extern unsigned long empty_zero_page;
>  static inline int pte_write(pte_t pte)   { return pte_val(pte) & _PAGE=
_WRITE; }
>  static inline int pte_dirty(pte_t pte)   { return pte_val(pte) & _PAGE=
_DIRTY; }
>  static inline int pte_young(pte_t pte)   { return pte_val(pte) & _PAGE=
_ACCESSED; }
> -static inline int pte_file(pte_t pte)    { return pte_val(pte) & _PAGE=
_FILE; }
>  static inline int pte_special(pte_t pte) { return 0; }
> =20
>  static inline pte_t pte_wrprotect(pte_t pte) { pte_val(pte) &=3D (~_PA=
GE_WRITE); return pte; }
> @@ -327,10 +325,6 @@ static inline void update_mmu_cache(struct vm_area=
_struct *vma,
>  #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
>  #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
> =20
> -#define PTE_FILE_MAX_BITS	22
> -#define pte_to_pgoff(x)		(pte_val(x) >> 10)
> -#define pgoff_to_pte(x)		__pte(((x) << 10) | _PAGE_FILE)
> -
>  #define kern_addr_valid(addr)	(1)
> =20
>  /*
>=20


--OEPKX6FcXiONUNlg4Bbe1hW0RMjh59KTI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUpsFiAAoJEGwLaZPeOHZ6JkQP+gNnOu1OENdTa9KbPViKpmFu
MTNoT7DjQnPG6KkCjL8ITrXbuqTNGFtAC5LHe/ZBRPgnV5X8/z6HN9EQf7mdl1nt
2Hb3Ze/CQGeoydM1cQiymkdoLJP68Bc2eMPkvDYNwo0RCwKmJmbEofxqT+Cc+a1r
B1qJXIHTLBj6EC4dRcTF0WageFamWQedN1uz/x4yqCCTIOablwbwnvOpoFeCgH/l
oFkc2CLl1aUO9LJSUvA4WDxQmnBKvG9wV7Br52VVyJQvYNGI3+HBdRLYAUdRM3Sm
5u3wZWBbiWterYpfO3b+6JOGDZqyhQ43hjzePksi+awYVL5QRPbGayacC6cmFsdV
77nAvXcGwtqkkWYFibgtAXpoRdf/FRYYBm041Bb9JgJ1PA58bm5qiKsE5ycVAB0M
BQ1PcDvYzA3jk6rJKgI79NpETkkjlDI3HqnXWTXywwTyOjvgkMzHkHhOwgncIZK6
LrWfXZgxekVDAG9xh9tiWwQGGYwtmgba5t3cmtZLJQGUOyxhB5p2aGYKaYH2Sjgq
81Eb0u57aksJa4DEHuRPEjm/3Mh7J0u9L4LxO1wRiACtKqK/1CyD3IE0alL2JMe8
pJr1yT5u4A741vtTj8fC2x2sxVjqhijdpyBcBcMazHjSUYQqTGKAtylolKtljecg
X9bBbKVvbNwJWdEn4Cdd
=RL0O
-----END PGP SIGNATURE-----

--OEPKX6FcXiONUNlg4Bbe1hW0RMjh59KTI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
