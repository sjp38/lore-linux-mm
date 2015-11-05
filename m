Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D5B5082F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 03:09:03 -0500 (EST)
Received: by pasz6 with SMTP id z6so83410862pas.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:09:03 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id b7si6420893pat.207.2015.11.05.00.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 00:09:02 -0800 (PST)
Date: Thu, 5 Nov 2015 17:09:10 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/5] mm, page_owner: print migratetype of a page, not
 pageblock
Message-ID: <20151105080910.GA25938@js1304-P5Q-DELUXE>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
 <1446649261-27122-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446649261-27122-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Wed, Nov 04, 2015 at 04:00:57PM +0100, Vlastimil Babka wrote:
> The information in /sys/kernel/debug/page_owner includes the migratetype
> declared during the page allocation via gfp_flags. This is also checked against
> the pageblock's migratetype, and reported as Fallback allocation if these two
> differ (although in fact fallback allocation is not the only reason why they
> can differ).
> 
> However, the migratetype actually printed is the one of the pageblock, not of
> the page itself, so it's the same for all pages in the pageblock. This is
> apparently a bug, noticed when working on other page_owner improvements. Fixed.

We can guess page migratetype through gfp_mask output although it isn't
easy task for now. But, there is no way to know pageblock migratetype.
I used this to know how memory is fragmented.

Thanks.

> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/page_owner.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 983c3a1..a9f16b8 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -113,7 +113,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>  			"PFN %lu Block %lu type %d %s Flags %s%s%s%s%s%s%s%s%s%s%s%s\n",
>  			pfn,
>  			pfn >> pageblock_order,
> -			pageblock_mt,
> +			page_mt,
>  			pageblock_mt != page_mt ? "Fallback" : "        ",
>  			PageLocked(page)	? "K" : " ",
>  			PageError(page)		? "E" : " ",
> -- 
> 2.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
