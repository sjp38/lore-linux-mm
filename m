Date: Tue, 10 Jul 2007 15:50:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/10] Remove the SLOB allocator for 2.6.23
In-Reply-To: <20070710224046.GV11115@waste.org>
Message-ID: <Pine.LNX.4.64.0707101549520.5919@schroedinger.engr.sgi.com>
References: <20070708075119.GA16631@elte.hu> <20070708110224.9cd9df5b.akpm@linux-foundation.org>
 <4691A415.6040208@yahoo.com.au> <84144f020707090404l657a62c7x89d7d06b3dd6c34b@mail.gmail.com>
 <Pine.LNX.4.64.0707090907010.13970@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0707101049230.23040@sbz-30.cs.Helsinki.FI> <469342DC.8070007@yahoo.com.au>
 <84144f020707100231p5013e1aer767562c26fc52eeb@mail.gmail.com>
 <20070710120224.GP11115@waste.org> <Pine.LNX.4.64.0707101510410.5490@schroedinger.engr.sgi.com>
 <20070710224046.GV11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com, corey.d.gough@intel.com, Denis Vlasenko <vda.linux@googlemail.com>, Erik Andersen <andersen@codepoet.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007, Matt Mackall wrote:

> Without the parameter, as the other way doesn't compile in -mm1.

here is the patch that went into mm after mm1 was released.

---
 mm/slub.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: linux-2.6.22-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/slub.c	2007-07-06 13:28:57.000000000 -0700
+++ linux-2.6.22-rc6-mm1/mm/slub.c	2007-07-06 13:29:01.000000000 -0700
@@ -1868,7 +1868,9 @@ static void init_kmem_cache_node(struct 
 	atomic_long_set(&n->nr_slabs, 0);
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+#ifdef CONFIG_SLUB_DEBUG
 	INIT_LIST_HEAD(&n->full);
+#endif
 }
 
 #ifdef CONFIG_NUMA
@@ -1898,8 +1900,10 @@ static struct kmem_cache_node * __init e
 	page->freelist = get_freepointer(kmalloc_caches, n);
 	page->inuse++;
 	kmalloc_caches->node[node] = n;
+#ifdef CONFIG_SLUB_DEBUG
 	init_object(kmalloc_caches, n, 1);
 	init_tracking(kmalloc_caches, n);
+#endif
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
 	add_partial(n, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
