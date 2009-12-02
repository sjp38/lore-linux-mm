Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D124C6007E3
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 17:06:18 -0500 (EST)
Date: Wed, 2 Dec 2009 16:05:51 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC,PATCH 2/2] dmapool: Honor GFP_* flags.
In-Reply-To: <200912022339.55552.roger.oksanen@cs.helsinki.fi>
Message-ID: <alpine.DEB.2.00.0912021558490.6282@router.home>
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi> <200912021523.39696.roger.oksanen@cs.helsinki.fi> <alpine.DEB.2.00.0912021358150.2547@router.home> <200912022339.55552.roger.oksanen@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Roger Oksanen wrote:

> That would fundamentally change how the pool allocator works. Currently it
> waits on its own wait queue for returned memory from dma_pool_free(..).

Plus it also has a timeout. What usually triggers first? Repeated attempts
and a timeout... All smells like heuristics that better be avoided.

> Waiting in the page allocator won't allow it to claim memory returned there.

If __GFP_WAIT is set then the page allocator can perform direct reclaim
getting you the memory you want!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
