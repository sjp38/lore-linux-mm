Date: Tue, 25 Nov 2008 00:47:33 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC PATCH] slab: __GFP_NOWARN not being propagated from
 mempool_alloc()
In-Reply-To: <E1L4jMt-0006OW-5J@pomaz-ex.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0811250038030.11825@melkki.cs.Helsinki.FI>
References: <E1L4jMt-0006OW-5J@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, cl@linux-foundation.org, david@fromorbit.com, peterz@infradead.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2008, Miklos Szeredi wrote:
> We see page allocation failure warnings on the mempool_alloc() path.
> See this lkml posting for example:
> 
> http://lkml.org/lkml/2008/10/27/100
> 
> The cause is that on NUMA, alloc_slabmgmt() clears __GFP_NOWARN,
> together with __GFP_THISNODE and __GFP_NORETRY.  But AFAICS it really
> only wants to clear __GFP_THISNODE.
> 
> Does this patch looks good?

Yes, it does but looking at mm/slab.c history I think we want something 
like the following instead. Christoph?

P.S. First one to test it gets a fabulous prize of a Tested-by tag in the 
patch description! How cool is that?

		Pekka
