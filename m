Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A51AC6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 08:29:08 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id xr1so20575016wjb.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 05:29:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k141si25822309wmd.133.2016.11.28.05.29.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 05:29:07 -0800 (PST)
Subject: Re: [PATCH v2 1/6] mm: hugetlb: rename some allocation functions
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
 <1479107259-2011-2-git-send-email-shijie.huang@arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <52b661c9-f4b0-3d94-cf9b-a0ffd5ecb723@suse.cz>
Date: Mon, 28 Nov 2016 14:29:03 +0100
MIME-Version: 1.0
In-Reply-To: <1479107259-2011-2-git-send-email-shijie.huang@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>, akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On 11/14/2016 08:07 AM, Huang Shijie wrote:
> After a future patch, the __alloc_buddy_huge_page() will not necessarily
> use the buddy allocator.
>
> So this patch removes the "buddy" from these functions:
> 	__alloc_buddy_huge_page -> __alloc_huge_page
> 	__alloc_buddy_huge_page_no_mpol -> __alloc_huge_page_no_mpol
> 	__alloc_buddy_huge_page_with_mpol -> __alloc_huge_page_with_mpol
>
> This patch makes preparation for the later patch.
>
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> ---
>  mm/hugetlb.c | 24 ++++++++++++++----------
>  1 file changed, 14 insertions(+), 10 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3edb759..496b703 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1157,6 +1157,10 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
>
>  static inline bool gigantic_page_supported(void) { return true; }
>  #else
> +static inline struct page *alloc_gigantic_page(int nid, unsigned int order)
> +{
> +	return NULL;
> +}

This hunk is not explained by the description. Could belong to a later 
patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
