Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9057D6B024E
	for <linux-mm@kvack.org>; Wed,  5 May 2010 08:52:17 -0400 (EDT)
Date: Wed, 5 May 2010 13:51:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] fix count_vm_event preempt in memory compaction direct
	reclaim
Message-ID: <20100505125156.GM20979@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-13-git-send-email-mel@csn.ul.ie> <20100505121908.GA5835@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100505121908.GA5835@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 02:19:08PM +0200, Andrea Arcangeli wrote:
> On Tue, Apr 20, 2010 at 10:01:14PM +0100, Mel Gorman wrote:
> > +		if (page) {
> > +			__count_vm_event(COMPACTSUCCESS);
> > +			return page;
> 
> ==
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Preempt is enabled so it must use count_vm_event.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

Andrew, this is a fix to the patch
mmcompaction-direct-compact-when-a-high-order-allocation-fails.patch

Thanks Andrea, well spotted.

> ---
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1768,7 +1768,7 @@ __alloc_pages_direct_compact(gfp_t gfp_m
>  				alloc_flags, preferred_zone,
>  				migratetype);
>  		if (page) {
> -			__count_vm_event(COMPACTSUCCESS);
> +			count_vm_event(COMPACTSUCCESS);
>  			return page;
>  		}
>  
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
