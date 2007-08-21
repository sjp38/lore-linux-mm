Date: Tue, 21 Aug 2007 13:55:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 5/7] Laundry handling for direct reclaim
In-Reply-To: <20070821150650.GL11329@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708211354010.3082@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <20070820215316.994224842@sgi.com>
 <20070821150650.GL11329@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Mel Gorman wrote:

> > @@ -1156,6 +1156,7 @@ unsigned long try_to_free_pages(struct z
> >  		.swappiness = vm_swappiness,
> >  		.order = order,
> >  	};
> > +	LIST_HEAD(laundry);
> 
> Why is the laundry not made part of the scan_control?

That is one possibility. The other is to treat laundry as a lru type list 
under zone->lru_lock. This would allow the writeback process (whichever 
that is) to be independent of the producer of the laundry. Dirty pages 
could be isolated from an atomic context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
