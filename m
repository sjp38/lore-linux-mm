Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A6E696B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:55:36 -0400 (EDT)
Date: Fri, 22 Oct 2010 11:55:13 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101022155513.GA26790@infradead.org>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
 <20101021235854.GD3270@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101021235854.GD3270@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 10:58:54AM +1100, Nick Piggin wrote:
> Again, I really think it needs to be per zone. Something like inode
> cache could still have lots of allocations in ZONE_NORMAL with plenty
> of memory free there, but a DMA zone shortage could cause it to trash
> the caches.

I think making shrinking decision per-zone is fine.  But do we need to
duplicate all the lru lists and infrastructure per-zone for that instead
of simply per-zone?   Even with per-node lists we can easily skip over
items from the wrong zone.

Given that we have up to 6 zones per node currently, and we would mostly
use one with a few fallbacks that seems like a lot of overkill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
