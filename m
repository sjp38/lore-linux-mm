Date: Mon, 7 May 2007 11:39:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Support concurrent local and remote frees and allocs on a slab.
In-Reply-To: <20070506122447.0d5b83e1.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705071137290.5793@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705052152060.29770@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705052243490.29846@schroedinger.engr.sgi.com>
 <20070506122447.0d5b83e1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 May 2007, Andrew Morton wrote:

> On Sat, 5 May 2007 22:45:26 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Sat, 5 May 2007, Christoph Lameter wrote:
> > 
> > > Hmmmm... I can take this even further and get another 20% if I take the 
> > > critical components of slab_alloc and slab_free and inline them into
> > > kfree, kmem_cache_alloc and friends. I went from 5.8MB without this 
> > > patch to now 8 MB/sec with this patch and the rather ugly inlining.
> > 
> > Hmmm... Nope. That was the effect of screwing up kfree so that no memory 
> > is ever freed. Interesting that this increases performance...
> 
> Yes, is is interesting, considering all our lovingly-crafted efforts to
> keep that sort of memory hot in the CPU cache.

I think the major performance improvement was to remove the overhead of 
kfree. Half of the effort is gone thus performance goes through the roof. 
Also this insures that SLUB always gets no partial slabs which increases 
performance further.

What is the problem with 21-mm1 btw? slab performance for both allocators 
dropped from ~6M/sec to ~4.5M/sec

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
