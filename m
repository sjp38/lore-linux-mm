Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DE265620012
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:26:44 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o1BLQfbQ007634
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 21:26:41 GMT
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz1.hot.corp.google.com with ESMTP id o1BLQbFQ027269
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:26:40 -0800
Received: by pzk5 with SMTP id 5so2952805pzk.29
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:26:39 -0800 (PST)
Date: Thu, 11 Feb 2010 13:26:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: suppress pfn range output for zones without pages
In-Reply-To: <20100211122507.GA32292@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1002111324280.5705@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com> <20100211122507.GA32292@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Mel Gorman wrote:

> > free_area_init_nodes() emits pfn ranges for all zones on the system.
> > There may be no pages on a higher zone, however, due to memory
> > limitations or the use of the mem= kernel parameter.  For example:
> > 
> > Zone PFN ranges:
> >   DMA      0x00000001 -> 0x00001000
> >   DMA32    0x00001000 -> 0x00100000
> >   Normal   0x00100000 -> 0x00100000
> > 
> > The implementation copies the previous zone's highest pfn, if any, as the
> > next zone's lowest pfn.  If its highest pfn is then greater than the
> > amount of addressable memory, the upper memory limit is used instead.
> > Thus, both the lowest and highest possible pfn for higher zones without
> > memory may be the same.
> > 
> > The output is now suppressed for zones that do not have a valid pfn
> > range.
> > 
> 
> I see no problem with the patch. Was it a major problem or just
> confusing?
> 

It was just confusing, I don't think anybody would be parsing the kernel 
log for this specifically to determine whether ZONE_NORMAL exists :)

> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> 

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
