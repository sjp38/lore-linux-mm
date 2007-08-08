Date: Wed, 8 Aug 2007 10:57:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <20070808103946.4cece16c.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708081050590.12652@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <20070806103658.603735000@chello.nl>
 <Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
 <20070808014435.GG30556@waste.org> <Pine.LNX.4.64.0708081004290.12652@schroedinger.engr.sgi.com>
 <20070808103946.4cece16c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Andrew Morton wrote:

> 3.  Perform page reclaim from hard IRQ context.  Pretty simple to
> implement, most of the work would be needed in the rmap code.  It might be
> better to make it opt-in via a new __GFP_flag.

In a hardirq context one is bound to a processor and through the slab 
allocator to a slab from which one allocates objects. The slab is per cpu 
and so the slab is reserved for the current context. Nothing can take 
objects away from it. The modifications here would not be needed for that 
context.

I think in general irq context reclaim is doable. Cannot see obvious 
issues on a first superficial pass through rmap.c. The irq holdoff would 
be pretty long though which may make it unacceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
