Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50E806B0270
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 09:30:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so12446132wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:30:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hc5si29990405wjb.226.2016.04.26.06.30.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 06:30:50 -0700 (PDT)
Subject: Re: [PATCH 14/28] mm, page_alloc: Simplify last cpupid reset
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-2-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F6D89.1000704@suse.cz>
Date: Tue, 26 Apr 2016 15:30:49 +0200
MIME-Version: 1.0
In-Reply-To: <1460711275-1130-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 11:07 AM, Mel Gorman wrote:
> The current reset unnecessarily clears flags and makes pointless calculations.

Ugh, indeed.

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/mm.h | 5 +----
>   1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ffcff53e3b2b..60656db00abd 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -837,10 +837,7 @@ extern int page_cpupid_xchg_last(struct page *page, int cpupid);
>
>   static inline void page_cpupid_reset_last(struct page *page)
>   {
> -	int cpupid = (1 << LAST_CPUPID_SHIFT) - 1;
> -
> -	page->flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
> -	page->flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
> +	page->flags |= LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT;
>   }
>   #endif /* LAST_CPUPID_NOT_IN_PAGE_FLAGS */
>   #else /* !CONFIG_NUMA_BALANCING */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
