Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D93FC5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 10:01:09 -0400 (EDT)
Date: Thu, 21 Oct 2010 22:01:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] page_isolation: codeclean fix comment and rm
 unneeded val init
Message-ID: <20101021140105.GA9709@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 09:28:19PM +0800, Bob Liu wrote:
> function __test_page_isolated_in_pageblock() return 1 if all pages
> in the range is isolated, so fix the comment.
> value pfn will be init in the following loop so rm it.

This is a bit confusing, but the original comment should be intended
for test_pages_isolated()..

> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/page_isolation.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 5e0ffd9..4ae42bb 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -86,7 +86,7 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
>   * all pages in [start_pfn...end_pfn) must be in the same zone.
>   * zone->lock must be held before call this.
>   *
> - * Returns 0 if all pages in the range is isolated.
> + * Returns 1 if all pages in the range is isolated.
>   */
>  static int
>  __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn)
> @@ -119,7 +119,6 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
>  	struct zone *zone;
>  	int ret;
>  
> -	pfn = start_pfn;
>  	/*
>  	 * Note: pageblock_nr_page != MAX_ORDER. Then, chunks of free page
>  	 * is not aligned to pageblock_nr_pages.
> -- 
> 1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
