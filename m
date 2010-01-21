Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 117386B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 18:35:11 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o0LNZ9vc002354
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:35:09 -0800
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by kpbe16.cbf.corp.google.com with ESMTP id o0LNXVgg025677
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:34:41 -0800
Received: by pxi9 with SMTP id 9so382336pxi.24
        for <linux-mm@kvack.org>; Thu, 21 Jan 2010 15:34:41 -0800 (PST)
Date: Thu, 21 Jan 2010 15:34:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/7] Add /proc trigger for memory compaction
In-Reply-To: <20100121140948.GJ5154@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1001211514230.31073@chino.kir.corp.google.com>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-6-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001071352100.23894@chino.kir.corp.google.com> <20100120094813.GC5154@csn.ul.ie> <alpine.DEB.2.00.1001201241540.6440@chino.kir.corp.google.com>
 <20100121140948.GJ5154@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010, Mel Gorman wrote:

> > It would be helpful to be able to determine what is "compactable" at the 
> > same time by adding both global and per-node "compact_order" tunables that 
> > would default to HUGETLB_PAGE_ORDER. 
> 
> Well, rather than having a separate tunable, writing a number to
> /proc/sys/vm/compact could indicate the order if that trigger is now
> working system-wide. Would that be suitable?
> 

Do you think you'll eventually find a need to call try_to_compact_pages() 
with a higher order than the one passed to the page allocator to limit 
"compaction thrashing" from fragmented frees to a zone where we're 
constantly compacting order-1 pages, for instance?  I agree that memory 
compaction should always be used before direct reclaim for higher order 
allocations, but it may be more efficient to define a compact_min_order, 
tunable from userspace, that would avoid the need for constant order-1 
compactions from subsequent page allocations.

If that's a possibility, we may find a need for "compact_order", now 
renamed "compact_min_order", outside of the explicit trigger.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
