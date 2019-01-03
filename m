Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0D838E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 02:41:08 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so28366671pgb.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 23:41:08 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t5si50603594pgc.369.2019.01.02.23.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 23:41:07 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [v4 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
	<1546145375-793-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Thu, 03 Jan 2019 15:41:05 +0800
In-Reply-To: <1546145375-793-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Sun, 30 Dec 2018 12:49:35 +0800")
Message-ID: <875zv6w5m6.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: tim.c.chen@intel.com, minchan@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Yang Shi <yang.shi@linux.alibaba.com> writes:

> swap_vma_readahead()'s comment is missed, just add it.
>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/swap_state.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
>
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 78d500e..dd8f698 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -698,6 +698,23 @@ static void swap_ra_info(struct vm_fault *vmf,
>  	pte_unmap(orig_pte);
>  }
>  
> +/**
> + * swap_vm_readahead - swap in pages in hope we need them soon

s/swap_vm_readahead/swap_vma_readahead/

> + * @entry: swap entry of this memory
> + * @gfp_mask: memory allocation flags
> + * @vmf: fault information
> + *
> + * Returns the struct page for entry and addr, after queueing swapin.
> + *
> + * Primitive swap readahead code. We simply read in a few pages whoes
> + * virtual addresses are around the fault address in the same vma.
> + *
> + * This has been extended to use the NUMA policies from the mm triggering
> + * the readahead.

What is this?  I know you copy it from swap_cluster_readahead(), but we
have only one mm for vma readahead.

> + * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.

Better to make it explicit that your are talking about mmap_sem?

Best Regards,
Huang, Ying

> + *
> + */
>  static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>  				       struct vm_fault *vmf)
>  {
