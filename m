Date: Tue, 24 Jul 2007 15:10:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
Message-Id: <20070724151046.d8fbb7da.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707241234460.13653@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins>
	<20070723112143.GB19437@skynet.ie>
	<1185190711.8197.15.camel@twins>
	<Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com>
	<1185256869.8197.27.camel@twins>
	<Pine.LNX.4.64.0707240007100.3128@schroedinger.engr.sgi.com>
	<1185261894.8197.33.camel@twins>
	<Pine.LNX.4.64.0707240030110.3295@schroedinger.engr.sgi.com>
	<20070724120751.401bcbcb@schroedinger.engr.sgi.com>
	<20070724122542.d4ac734a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707241234460.13653@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@skynet.ie>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007 12:36:59 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 24 Jul 2007, Andrew Morton wrote:
> 
> > > __GFP_MOVABLE	The movability of a slab is determined by the
> > > 		options specified at kmem_cache_create time. If this is
> > > 		specified at kmalloc time then we will have some random
> > > 		slabs movable and others not. 
> > 
> > Yes, they seem inappropriate.  Especially the first two.
> 
> The third one would randomize __GFP_MOVABLE allocs from the page allocator 
> since one __GFP_MOVABLE alloc may allocate a slab that is then used for 
> !__GFP_MOVABLE allocs.
> 
> Maybe something like this? Note that we may get into some churn here 
> since slab allocations that any of these flags will BUG.
> 
> 
> 
> GFP_LEVEL_MASK: Remove __GFP_COLD, __GFP_COMP and __GFPMOVABLE
> 
> Add an explanation for the GFP_LEVEL_MASK and remove the flags
> that should not be passed through derived allocators.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

I think I'll duck this for now.  Otherwise I have a suspicion that I'll
be the first person to run it and I'm too old for such excitement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
