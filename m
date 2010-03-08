Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5826B0078
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 18:23:46 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o28NNehN001252
	for <linux-mm@kvack.org>; Mon, 8 Mar 2010 23:23:41 GMT
Received: from pvd12 (pvd12.prod.google.com [10.241.209.204])
	by wpaz29.hot.corp.google.com with ESMTP id o28NNdnV009901
	for <linux-mm@kvack.org>; Mon, 8 Mar 2010 15:23:39 -0800
Received: by pvd12 with SMTP id 12so117360pvd.8
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 15:23:39 -0800 (PST)
Date: Mon, 8 Mar 2010 15:23:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
 allocators
In-Reply-To: <20100301180412.GF3852@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003081521380.1431@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com> <20100301135242.GE3852@csn.ul.ie> <alpine.DEB.2.00.1003010941020.26562@chino.kir.corp.google.com> <20100301180412.GF3852@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Mar 2010, Mel Gorman wrote:

> Can figures also be shown then as part of the patch? It would appear that
> one possibility would be to boot a machine with 1G and simply measure the
> time taken to complete 7 simultaneous kernel compiles (so that kswapd is
> active) and measure the number of pages direct reclaimed and reclaimed by
> kswapd. Rerun the test except that all the kernel builds are at a higher
> priority than kswapd.
> 

Ok, I'll collect those statistics.

> When all the priorities are the same, the reclaim figures should match
> with or without the patch. With the priorities higher, then the direct
> reclaims should be higher without this patch reflecting the fact that
> kswapd was starved of CPU.
> 

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
