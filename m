Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B0B796B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 20:18:08 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so3842483pab.3
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 17:18:08 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id zp6si403572pbc.127.2015.04.09.17.18.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 17:18:07 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t3A0I029001825
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 09:18:04 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: use pmd_page() in follow_huge_pmd()
Date: Fri, 10 Apr 2015 00:08:42 +0000
Message-ID: <20150410000814.GA3623@hori1.linux.bs1.fc.nec.co.jp>
References: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>
In-Reply-To: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B19D6B38F80488449F97BB2E5B08B896@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Apr 09, 2015 at 06:11:35PM +0200, Gerald Schaefer wrote:
> commit 61f77eda "mm/hugetlb: reduce arch dependent code around follow_hug=
e_*"
> broke follow_huge_pmd() on s390, where pmd and pte layout differ and usin=
g
> pte_page() on a huge pmd will return wrong results. Using pmd_page() inst=
ead
> fixes this.
>=20
> All architectures that were touched by commit 61f77eda have pmd_page()
> defined, so this should not break anything on other architectures.
>=20
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>

Thank you for the report. This looks good to me.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> Cc: stable@vger.kernel.org # v3.12
> ---
>  mm/hugetlb.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e8c92ae..271e443 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3865,8 +3865,7 @@ retry:
>  	if (!pmd_huge(*pmd))
>  		goto out;
>  	if (pmd_present(*pmd)) {
> -		page =3D pte_page(*(pte_t *)pmd) +
> -			((address & ~PMD_MASK) >> PAGE_SHIFT);
> +		page =3D pmd_page(*pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
>  		if (flags & FOLL_GET)
>  			get_page(page);
>  	} else {
> --=20
> 2.1.4
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
