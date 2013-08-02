Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 2368C6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 12:27:26 -0400 (EDT)
Date: Fri, 2 Aug 2013 18:27:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] mm, page_alloc: add likely macro to help compiler
 optimization
Message-ID: <20130802162722.GA29220@dhcp22.suse.cz>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Fri 02-08-13 11:07:56, Joonsoo Kim wrote:
> We rarely allocate a page with ALLOC_NO_WATERMARKS and it is used
> in slow path. For making fast path more faster, add likely macro to
> help compiler optimization.

The code is different in mmotm tree (see mm: page_alloc: rearrange
watermark checking in get_page_from_freelist)

Besides that, make sure you provide numbers which prove your claims
about performance optimizations.

> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b100255..86ad44b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1901,7 +1901,7 @@ zonelist_scan:
>  			goto this_zone_full;
>  
>  		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
> -		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
> +		if (likely(!(alloc_flags & ALLOC_NO_WATERMARKS))) {
>  			unsigned long mark;
>  			int ret;
>  
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
