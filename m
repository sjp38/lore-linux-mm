Date: Mon, 6 Aug 2007 10:56:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/10] foundations for reserve-based allocation
In-Reply-To: <20070806102922.907530000@chello.nl>
Message-ID: <Pine.LNX.4.64.0708061052160.24256@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Peter Zijlstra wrote:

> We want a guarantee for N bytes from kmalloc(), this translates to a demand
> on the slab allocator for 2*N+m (due to the power-of-two nature of kmalloc 
> slabs), where m is the meta-data needed by the allocator itself.

The guarantee occurs in what context? Looks like its global here but 
allocations may be restricted to a cpuset context? What happens in a 
GFP_THISNODE allocation? Or a memory policy restricted allocations?

> So we need functions translating our demanded kmalloc space into a page
> reserve limit, and then need to provide a reserve of pages.

Only kmalloc? What about skb heads and such?

> And we need to ensure that once we hit the reserve, the slab allocator honours
> the reserve's access. That is, a regular allocation may not get objects from
> a slab allocated from the reserves.

>From a cpuset we may hit the reserves since cpuset memory is out and then 
the rest of the system fails allocations?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
