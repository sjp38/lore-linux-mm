Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 71B9A6B00AB
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 11:09:41 -0500 (EST)
Date: Mon, 8 Mar 2010 16:09:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
Message-ID: <20100308160920.GA13788@csn.ul.ie>
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 08, 2010 at 10:21:04AM +0100, Thomas Gleixner wrote:
> __zone_pcp_update() iterates over NR_CPUS instead of limiting the
> access to the possible cpus. This might result in access to
> uninitialized areas as the per cpu allocator only populates the per
> cpu memory for possible cpus.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Looks good.

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -3224,7 +3224,7 @@ static int __zone_pcp_update(void *data)
>  	int cpu;
>  	unsigned long batch = zone_batchsize(zone), flags;
>  
> -	for (cpu = 0; cpu < NR_CPUS; cpu++) {
> +	for_each_possible_cpu(cpu) {
>  		struct per_cpu_pageset *pset;
>  		struct per_cpu_pages *pcp;
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
