Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 374336B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 04:33:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so8154459pbb.0
        for <linux-mm@kvack.org>; Thu, 19 Sep 2013 01:33:37 -0700 (PDT)
Date: Thu, 19 Sep 2013 10:33:29 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH] mm/ksm: return NULL when doesn't get mergeable page
Message-ID: <20130919083329.GA1620@thinkpad-work.brq.redhat.com>
References: <5236FC88.6050409@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5236FC88.6050409@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 16 Sep 2013, Jianguo Wu wrote:
> In get_mergeable_page() local variable page is not initialized,
> it may hold a garbage value, when find_mergeable_vma() return NULL,
> get_mergeable_page() may return a garbage value to the caller.
> 
> So initialize page as NULL.
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> ---
>  mm/ksm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index b6afe0c..87efbae 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -460,7 +460,7 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
>  	struct mm_struct *mm = rmap_item->mm;
>  	unsigned long addr = rmap_item->address;
>  	struct vm_area_struct *vma;
> -	struct page *page;
> +	struct page *page = NULL;
>  
>  	down_read(&mm->mmap_sem);
>  	vma = find_mergeable_vma(mm, addr);
> -- 
> 1.7.1
> 

When find_mergeable_vma returned NULL, NULL is assigned to page in "out"
statement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
