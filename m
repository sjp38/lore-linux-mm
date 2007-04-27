Date: Thu, 26 Apr 2007 23:32:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 09/10] SLUB: Exploit page mobility to increase
 allocation order
Message-Id: <20070426233207.a86faf0a.akpm@linux-foundation.org>
In-Reply-To: <20070427042909.415420974@sgi.com>
References: <20070427042655.019305162@sgi.com>
	<20070427042909.415420974@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007 21:27:04 -0700 clameter@sgi.com wrote:

> If there is page mobility then we can defragment memory. So its possible to
> use higher order of pages for slab allocations.
> 
> If the defaults were not overridden set the max order to 4 and guarantee 16
> objects per slab. This will put some stress on Mel's antifrag approaches.
> If these defaults are too large then they should be later reduced.
> 
> Cc: Mel Gorman <mel@skynet.ie>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.21-rc7-mm2/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.21-rc7-mm2.orig/include/linux/mmzone.h	2007-04-26 20:57:58.000000000 -0700
> +++ linux-2.6.21-rc7-mm2/include/linux/mmzone.h	2007-04-26 21:05:48.000000000 -0700
> @@ -25,6 +25,8 @@
>  #endif
>  #define MAX_ORDER_NR_PAGES (1 << (MAX_ORDER - 1))
>  
> +extern int page_group_by_mobility_disabled;
> +

This creates unfortunate linkage between your stuff and Mel's stuff.

And afaik nobody has done a detailed review of Mel's stuff in a year or
three.  I will do so, but you know how it is.  (that kernelcore= thing
smells like highmem to me).  I'm a bit wobbly about merging it all at this
stage.

So I'll queue this patch up somewhere from where it can be easily dropped
again, but it makes further patches a bit trickier.  Please keep them as
fine-grained as poss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
