From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Sat, 28 Jun 2003 23:06:59 +0200
References: <200306250111.01498.phillips@arcor.de> <200306271800.53487.phillips@arcor.de> <Pine.LNX.4.53.0306291953490.20655@skynet>
In-Reply-To: <Pine.LNX.4.53.0306291953490.20655@skynet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306282306.59502.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 29 June 2003 21:25, Mel Gorman wrote:
> As you can see, order0 allocations were a *lot* more common, at least in
> my system.

Mel,

There's no question that that's the case today.  However, there are good 
reasons for using a largish filesystem blocksize, 16K for example, once it 
becomes possible to do so.  With an active volume mounted using 16K blocks, 
you'd see that the balance of allocations shifts towards order 2.  The size 
of the shift will be workload-dependent, ranging from almost no order 2 
allocations, to almost all.  To keep things interesting, it's quite possible 
for the balance to change suddenly and/or strongly.

> Because they are so common in comparison to other orders, I
> think that putting order0 in slabs of size 2^MAX_ORDER will make
> defragmentation *so* much easier, if not plain simple, because you can
> shuffle around order0 pages in the slabs to free up one slab which frees
> up one large 2^MAX_ORDER adjacent block of pages.

But how will you shuffle those pages around?

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
