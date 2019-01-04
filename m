Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 716A58E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 21:25:19 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so29752463pgc.22
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 18:25:19 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v6si11846640pfb.178.2019.01.03.18.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 18:25:18 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [v5 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
References: <1546543673-108536-1-git-send-email-yang.shi@linux.alibaba.com>
	<1546543673-108536-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Fri, 04 Jan 2019 10:25:15 +0800
In-Reply-To: <1546543673-108536-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Fri, 4 Jan 2019 03:27:53 +0800")
Message-ID: <87imz5tb04.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: tim.c.chen@intel.com, minchan@kernel.org, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Yang Shi <yang.shi@linux.alibaba.com> writes:

> swap_vma_readahead()'s comment is missed, just add it.
>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Thank!

Reviewed-by: "Huang, Ying" <ying.huang@intel.com>

Best Regards,
Huang, Ying

> ---
> v5: Fixed the comments per Ying Huang
>
>  mm/swap_state.c | 16 +++++++++++++++-
>  1 file changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 78d500e..c8730d7 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -523,7 +523,7 @@ static unsigned long swapin_nr_pages(unsigned long offset)
>   * This has been extended to use the NUMA policies from the mm triggering
>   * the readahead.
>   *
> - * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
> + * Caller must hold read mmap_sem if vmf->vma is not NULL.
>   */
>  struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  				struct vm_fault *vmf)
> @@ -698,6 +698,20 @@ static void swap_ra_info(struct vm_fault *vmf,
>  	pte_unmap(orig_pte);
>  }
>  
> +/**
> + * swap_vma_readahead - swap in pages in hope we need them soon
> + * @entry: swap entry of this memory
> + * @gfp_mask: memory allocation flags
> + * @vmf: fault information
> + *
> + * Returns the struct page for entry and addr, after queueing swapin.
> + *
> + * Primitive swap readahead code. We simply read in a few pages whoes
> + * virtual addresses are around the fault address in the same vma.
> + *
> + * Caller must hold read mmap_sem if vmf->vma is not NULL.
> + *
> + */
>  static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>  				       struct vm_fault *vmf)
>  {
