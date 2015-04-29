Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6AE6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 12:03:08 -0400 (EDT)
Received: by widdi4 with SMTP id di4so185745743wid.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:03:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e8si24089413wib.65.2015.04.29.09.03.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 09:03:07 -0700 (PDT)
Message-ID: <554100A6.8070003@redhat.com>
Date: Wed, 29 Apr 2015 18:02:46 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 10/28] mm, vmstats: new THP splitting event
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-11-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="dD50TWtfW8607vdjHHDFS6p1DuMvSuAxc"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--dD50TWtfW8607vdjHHDFS6p1DuMvSuAxc
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> The patch replaces THP_SPLIT with tree events: THP_SPLIT_PAGE,
> THP_SPLIT_PAGE_FAILT and THP_SPLIT_PMD. It reflects the fact that we

s/FAILT/FAILED

> are going to be able split PMD without the compound page and that
> split_huge_page() can fail.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  include/linux/vm_event_item.h | 4 +++-
>  mm/huge_memory.c              | 2 +-
>  mm/vmstat.c                   | 4 +++-
>  3 files changed, 7 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_ite=
m.h
> index 2b1cef88b827..3261bfe2156a 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -69,7 +69,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT=
,
>  		THP_FAULT_FALLBACK,
>  		THP_COLLAPSE_ALLOC,
>  		THP_COLLAPSE_ALLOC_FAILED,
> -		THP_SPLIT,
> +		THP_SPLIT_PAGE,
> +		THP_SPLIT_PAGE_FAILED,
> +		THP_SPLIT_PMD,
>  		THP_ZERO_PAGE_ALLOC,
>  		THP_ZERO_PAGE_ALLOC_FAILED,
>  #endif
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index ccbfacf07160..be6d0e0f5050 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1961,7 +1961,7 @@ int split_huge_page_to_list(struct page *page, st=
ruct list_head *list)
> =20
>  	BUG_ON(!PageSwapBacked(page));
>  	__split_huge_page(page, anon_vma, list);
> -	count_vm_event(THP_SPLIT);
> +	count_vm_event(THP_SPLIT_PAGE);
> =20
>  	BUG_ON(PageCompound(page));
>  out_unlock:
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1fd0886a389f..e1c87425fe11 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -821,7 +821,9 @@ const char * const vmstat_text[] =3D {
>  	"thp_fault_fallback",
>  	"thp_collapse_alloc",
>  	"thp_collapse_alloc_failed",
> -	"thp_split",
> +	"thp_split_page",
> +	"thp_split_page_failed",
> +	"thp_split_pmd",
>  	"thp_zero_page_alloc",
>  	"thp_zero_page_alloc_failed",
>  #endif
>=20



--dD50TWtfW8607vdjHHDFS6p1DuMvSuAxc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQQCmAAoJEHTzHJCtsuoCELEH/1A/Ekf6zCjgTKixiNcBmkr3
nLhdIOGJydcFLArj7ZcKhpzgTErwhEuUCLOwApo9eLvV3wzq9/fLmiwDYcKt1Mu2
LTG55QtecCnUc8YjYfV2RUgUqZf6ZUo+DY8hxCn1X5RbsOd2NPUnSfDCriDDtzg6
LH3pOLRucpcuF1oMZ8pMsf6P1P7ZiLZOfkFFBI6h9QPxVJ3xeVdSH4hRsUcAvVR+
W24O8F7AZ9W349yPQ1qJodWOLilCXLEzTpfz+pL39SrFuTFNsvvd7pqA6zksQ94w
CsnpKQJgSTadiORd0gKHOZRsTTXk7Bc+RekJ8/xIRwgc6DjuvAmd3bITpZJfgSM=
=qCJC
-----END PGP SIGNATURE-----

--dD50TWtfW8607vdjHHDFS6p1DuMvSuAxc--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
