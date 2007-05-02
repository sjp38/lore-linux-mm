Date: Wed, 2 May 2007 11:53:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <20070502114233.30143b0b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705021144110.1119@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705020955550.32271@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021903320.20615@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021124040.646@schroedinger.engr.sgi.com>
 <20070502114233.30143b0b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Andrew Morton wrote:

> > This is a sensitive piece of the kernel as you say and we better allow the 
> > running of two allocator for some time to make sure that it behaves in all 
> > load situations. The design is fundamentally different so its performance 
> > characteristics may diverge significantly and perhaps there will be corner 
> > cases for each where they do the best job.
> 
> eek.  We'd need to fix those corner cases then.  Our endgame
> here really must be rm mm/slab.c.

First we need to discover them and I doubt that mm covers much more than 
development loads. I hope we can get to a point where we have SLUB be 
the primarily allocator soon but I would expect various performance issues 
to show up.

On the other hand: I am pretty sure that SLUB can replace SLOB completely 
given SLOBs limitations and SLUBs more efficient use of space. SLOB needs 
8 bytes of overhead. SLUB needs none. We may just have to #ifdef out the 
debugging support to make the code be of similar size to SLOB too. SLOB is 
a general problem because its features are not compatible to SLAB. F.e. it 
does not support DESTROY_BY_RCU and does not do reclaim the right way etc 
etc. SLUB may turn out to be the ideal embedded slab allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
