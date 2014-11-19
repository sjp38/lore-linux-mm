Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A7DDD6B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 03:15:11 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so94733pad.24
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 00:15:11 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id bc3si1415430pbb.199.2014.11.19.00.15.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 00:15:10 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 16/19] thp: update documentation
Date: Wed, 19 Nov 2014 08:07:59 +0000
Message-ID: <20141119080828.GA11447@hori1.linux.bs1.fc.nec.co.jp>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-17-git-send-email-kirill.shutemov@linux.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <86738F71C2FE06408B3F0D1A192CBF99@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Nov 05, 2014 at 04:49:51PM +0200, Kirill A. Shutemov wrote:
> The patch updates Documentation/vm/transhuge.txt to reflect changes in
> THP design.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  Documentation/vm/transhuge.txt | 84 +++++++++++++++++++-----------------=
------
>  1 file changed, 38 insertions(+), 46 deletions(-)
>=20
> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.=
txt
> index df1794a9071f..33465e7b0d9b 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -200,9 +200,18 @@ thp_collapse_alloc_failed is incremented if khugepag=
ed found a range
>  	of pages that should be collapsed into one huge page but failed
>  	the allocation.
> =20
> -thp_split is incremented every time a huge page is split into base
> +thp_split_page is incremented every time a huge page is split into base
>  	pages. This can happen for a variety of reasons but a common
>  	reason is that a huge page is old and is being reclaimed.
> +	This action implies splitting all PMD the page mapped with.
> +
> +thp_split_page_failed is is incremented if kernel fails to split huge

'is' appears twice.

> +	page. This can happen if the page was pinned by somebody.
> +
> +thp_split_pmd is incremented every time a PMD split into table of PTEs.
> +	This can happen, for instance, when application calls mprotect() or
> +	munmap() on part of huge page. It doesn't split huge page, only
> +	page table entry.
> =20
>  thp_zero_page_alloc is incremented every time a huge zero page is
>  	successfully allocated. It includes allocations which where

There is a sentense related to the adjustment on futex code you just
removed in patch 15/19 in "get_user_pages and follow_page" section.

  ...
  split_huge_page() to avoid the head and tail pages to disappear from
  under it, see the futex code to see an example of that, hugetlbfs also
  needed special handling in futex code for similar reasons).

this seems obsolete, so we need some change on this?

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
