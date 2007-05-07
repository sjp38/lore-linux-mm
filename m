Date: Mon, 7 May 2007 11:58:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Support concurrent local and remote frees and allocs on a slab.
In-Reply-To: <20070507115438.a271580a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705071156570.6080@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705052152060.29770@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705052243490.29846@schroedinger.engr.sgi.com>
 <20070506122447.0d5b83e1.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705071137290.5793@schroedinger.engr.sgi.com>
 <20070507115438.a271580a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2007, Andrew Morton wrote:

> > I think the major performance improvement was to remove the overhead of 
> > kfree. Half of the effort is gone thus performance goes through the roof. 
> > Also this insures that SLUB always gets no partial slabs which increases 
> > performance further.
> 
> Well sure.  But there should have been a performance *decrease* because
> every piece of memory we get from slab is now cache-cold.  If slab was
> recycling objects, one would expect that to not happen.

No the memory that slub returns is designed to be in increasing memory 
order. The prefetch logic on most modern chips will eliminate the cache 
cold effect.

> So I'm assuming that you have producer and consumer running on separate
> CPUs and we don't get any decent cache reuse anyway.

This was on UP.

> > What is the problem with 21-mm1 btw? slab performance for both allocators 
> > dropped from ~6M/sec to ~4.5M/sec
> 
> That's news to me.  You're the slab guy ;)
> 
> Are you sure the slowdown is due to slab, or did networking break?

Both slab allocators are affected. I poked around but nothing sprang to 
my mind. Seems its networking.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
