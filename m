Subject: Re: [RFC][PATCH 1/6] mm: slab allocation fairness
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0611301210190.24331@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101921.113055000@chello.nl> >
	 <Pine.LNX.4.64.0611301049220.23820@schroedinger.engr.sgi.com>
	 <1164913365.6588.156.camel@twins>
	 <Pine.LNX.4.64.0611301137120.24161@schroedinger.engr.sgi.com>
	 <1164915612.6588.171.camel@twins>
	 <Pine.LNX.4.64.0611301210190.24331@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 30 Nov 2006 21:15:15 +0100
Message-Id: <1164917715.6588.177.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-30 at 12:11 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > Sure, but there is nothing wrong with using a slab page with a lower
> > allocation rank when there is memory aplenty. 
> 
> What does "a slab page with a lower allocation rank" mean? Slab pages have 
> no allocation ranks that I am aware of.

I just added allocation rank and didn't you suggest tracking it for all
slab pages instead of per slab?

The rank is an expression of how hard it was to get that page, with 0
being the hardest allocation (ALLOC_NO_WATERMARK) and 16 the easiest
(ALLOC_WMARK_HIGH).

I store the rank of the last allocated page and retest the rank when a
gfp flag indicates a higher rank, that is when the current slab
allocation would have failed to grow the slab under the conditions of
the previous allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
