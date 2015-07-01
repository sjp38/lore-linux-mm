Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A4E0A6B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 19:19:25 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so29981042pab.1
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 16:19:25 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id ig4si5712661pbb.82.2015.07.01.16.19.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Jul 2015 16:19:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mempolicy: get rid of duplicated check for
 vma(VM_PFNMAP) in queue_pages_range()
Date: Wed, 1 Jul 2015 23:18:46 +0000
Message-ID: <20150701231845.GA3018@hori1.linux.bs1.fc.nec.co.jp>
References: <20150701183058.GD32640@redhat.com>
In-Reply-To: <20150701183058.GD32640@redhat.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F38E895D1AE66746B6AA623AE2B6CD10@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aristeu Rozanski <aris@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Dave Hansen <dave.hansen@intel.com>, Pavel Emelyanov <xemul@parallels.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jul 01, 2015 at 02:30:58PM -0400, Aristeu Rozanski wrote:
> This check was introduced as part of
> 	6f4576e3687 - mempolicy: apply page table walker on queue_pages_range()
> which got duplicated by
> 	48684a65b4e - mm: pagewalk: fix misbehavior of walk_page_range for vma(V=
M_PFNMAP)
> by reintroducing it earlier on queue_page_test_walk()
>=20
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Aristeu Rozanski <aris@redhat.com>

Thank you for finding and fixing this.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 99d4c1d..9885d07 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -608,9 +608,6 @@ static int queue_pages_test_walk(unsigned long start,=
 unsigned long end,
> =20
>  	qp->prev =3D vma;
> =20
> -	if (vma->vm_flags & VM_PFNMAP)
> -		return 1;
> -
>  	if (flags & MPOL_MF_LAZY) {
>  		/* Similar to task_numa_work, skip inaccessible VMAs */
>  		if (vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE))
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
