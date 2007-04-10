Date: Tue, 10 Apr 2007 14:10:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101333001.9522@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> It would be nice to get all this stuff user-documented, so there's one place to
> go to work out how to drive slub.

Ok. Some more writing to do.

> We should force -mm testers to use slub by default, while providing them a
> way of going back to slab if they hit problems.  Can you please cook up a
> -mm-only patch for that?

Will do.
 
> Could print_track() be simplified by using -mm's sprint_symbol()?

I thought sprint_symbol only gives the symbol? Does it give us the offset 
too?

> How come slab_lock() isn't needed if CONFIG_SMP=n, CONFIG_PREEMPT=y?  I
> think that bit_spin_lock() does the right thing, and the #ifdef CONFIG_SMP
> in there should be removed.

Right.... 

> The use of slab_trylock() could do with some commentary: under what
> circumstances can it fail, what action do we take when it fails, why is
> this OK, etc.

There is some comment when it is used in get_partial_node().

> There are a bunch of functions which need to be called with local irqs
> disabled for locking reasons.  Documenting this (perhaps with
> VM_BUG_ON(!irqs_disabled()?) would be good.

Ok.

> calculate_order() is an important function.  The mapping between
> object-size and what-size-slab-will-use is something which regularly comes
> up, as it affects the reliability of the allocations of those objects, and
> their cost, and their page allocator fragmentation effects, etc.  Hence I
> think calculate_order() needs comprehensive commenting.  Rather than none ;)

Ok.
 
> What does that 65536 mean in kmem_cache_open? (Needs comment?)
> 
> Where do I go to learn what "s->defrag_ratio = 100;" means?

Hmmm... There are some comments in get_any_partial() but I can clarify 
that.

> Why is kmem_cache_close() non-static and exported to modules? 

Leftover from a time when kmem_cache_open was exported. Needs fix.
 
> Please check that all printks have suitable facility levels (KERN_FOO).

> I queued a pile of little cleanups, which you have been spammed with.  To
> resync, a rollup up to and including the slub patches is at
> http://userweb.kernel.org/~akpm/cl.gz (against 2.6.21-rc6).

> Teeny, teeny maximally-fine-grained little patches from now on, please. 
> Otherwise my whole house of cards will collapse.

Allright.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
