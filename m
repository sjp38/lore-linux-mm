Date: Tue, 21 Aug 2007 14:00:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 5/7] Laundry handling for direct reclaim
In-Reply-To: <20070821151907.GM11329@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708211359340.3082@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <20070820215316.994224842@sgi.com>
 <20070821151907.GM11329@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Mel Gorman wrote:

> > +		nr_reclaimed += shrink_zones(priority, zones, &sc, &laundry);
> >  		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
> >  		if (reclaim_state) {
> >  			nr_reclaimed += reclaim_state->reclaimed_slab;
> >  			reclaim_state->reclaimed_slab = 0;
> >  		}
> > +
> >  		total_scanned += sc.nr_scanned;
> > +
> 
> Could this not isolate a load of dirty pages on the laundry list and then
> shortly later go to sleep in congestion_wait() ? It would appear that with
> writeout deferred that the going to sleep is going to do nothing to help
> the situation.

Yep that seems to be the problem that Peter saw. We need to throttle 
later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
