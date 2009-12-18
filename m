Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F098E6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 06:39:49 -0500 (EST)
Date: Fri, 18 Dec 2009 11:39:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm tracing: cleanup Documentation/trace/events-kmem.txt
Message-ID: <20091218113936.GB21194@csn.ul.ie>
References: <20091217120644.b32a3e5c.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091217120644.b32a3e5c.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 12:06:44PM -0800, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Clean up typos/grammos/spellos in events-kmem.txt.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Mel Gorman <mel@csn.ul.ie>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  Documentation/trace/events-kmem.txt |   14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> --- linux-2.6.32-git14.orig/Documentation/trace/events-kmem.txt
> +++ linux-2.6.32-git14/Documentation/trace/events-kmem.txt
> @@ -1,7 +1,7 @@
>  			Subsystem Trace Points: kmem
>  
> -The tracing system kmem captures events related to object and page allocation
> -within the kernel. Broadly speaking there are four major subheadings.
> +The kmem tracing system captures events related to object and page allocation
> +within the kernel. Broadly speaking there are five major subheadings.
>  
>    o Slab allocation of small objects of unknown type (kmalloc)
>    o Slab allocation of small objects of known type
> @@ -9,7 +9,7 @@ within the kernel. Broadly speaking ther
>    o Per-CPU Allocator Activity
>    o External Fragmentation
>  
> -This document will describe what each of the tracepoints are and why they
> +This document describes what each of the tracepoints is and why they
>  might be useful.
>  
>  1. Slab allocation of small objects of unknown type
> @@ -34,7 +34,7 @@ kmem_cache_free		call_site=%lx ptr=%p
>  These events are similar in usage to the kmalloc-related events except that
>  it is likely easier to pin the event down to a specific cache. At the time
>  of writing, no information is available on what slab is being allocated from,
> -but the call_site can usually be used to extrapolate that information
> +but the call_site can usually be used to extrapolate that information.
>  
>  3. Page allocation
>  ==================
> @@ -80,9 +80,9 @@ event indicating whether it is for a per
>  When the per-CPU list is too full, a number of pages are freed, each one
>  which triggers a mm_page_pcpu_drain event.
>  
> -The individual nature of the events are so that pages can be tracked
> +The individual nature of the events is so that pages can be tracked
>  between allocation and freeing. A number of drain or refill pages that occur
> -consecutively imply the zone->lock being taken once. Large amounts of PCP
> +consecutively imply the zone->lock being taken once. Large amounts of per-CPU
>  refills and drains could imply an imbalance between CPUs where too much work
>  is being concentrated in one place. It could also indicate that the per-CPU
>  lists should be a larger size. Finally, large amounts of refills on one CPU
> @@ -102,6 +102,6 @@ is important.
>  
>  Large numbers of this event implies that memory is fragmenting and
>  high-order allocations will start failing at some time in the future. One
> -means of reducing the occurange of this event is to increase the size of
> +means of reducing the occurrence of this event is to increase the size of
>  min_free_kbytes in increments of 3*pageblock_size*nr_online_nodes where
>  pageblock_size is usually the size of the default hugepage size.
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
