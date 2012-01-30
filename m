Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id D3FA86B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 07:42:48 -0500 (EST)
Date: Mon, 30 Jan 2012 12:42:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 10/15] mm: extract reclaim code from
 __alloc_pages_direct_reclaim()
Message-ID: <20120130124245.GM25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-11-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327568457-27734-11-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 26, 2012 at 10:00:52AM +0100, Marek Szyprowski wrote:
> This patch extracts common reclaim code from __alloc_pages_direct_reclaim()
> function to separate function: __perform_reclaim() which can be later used
> by alloc_contig_range().
> 
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> ---
>  mm/page_alloc.c |   30 +++++++++++++++++++++---------
>  1 files changed, 21 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4e60c0b..e35d06b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2094,16 +2094,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  }
>  #endif /* CONFIG_COMPACTION */
>  
> -/* The really slow allocator path where we enter direct reclaim */
> -static inline struct page *
> -__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> -	struct zonelist *zonelist, enum zone_type high_zoneidx,
> -	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
> -	int migratetype, unsigned long *did_some_progress)
> +/* Perform direct synchronous page reclaim */
> +static inline int
> +__perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
> +		  nodemask_t *nodemask)

This function is too large to be inlined. Make it a static int. Once
that is fixed add a

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
