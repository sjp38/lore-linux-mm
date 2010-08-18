Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 449A06B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:32:56 -0400 (EDT)
Message-Id: <20100818162539.281413425@linux.com>
Date: Wed, 18 Aug 2010 11:25:39 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q Cleanup2 0/6] SLUB: Cleanups V2
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

V1->V2: Fixes as discussed with David.

These are just the 6 remaining cleanup patches (after the 2.6.36 merge
got the other in) in preparation for the Unified patches.

I think it may be best to first try to merge these and make sure that
they are fine before we go step by step through the unification patches.
I hope they can go into -next.

Patch 1

Uninline debug functions in hot paths. There is no point of the compiler
folding them in because they are typically unused.

Patch 2

Remove dynamic creation of DMA caches and create them statically
(will be turned dynamic by patch 4 but will then always be preallocated
on boot and not from the hotpath)

Patch 3

Remove static allocation of kmem_cache_cpu array and rely on the
percpu allocator to allocate memory for the array on bootup.

Patch 4

Remove static allocation of kmem_cache structure for kmalloc and friends.

Patch 5

Extract hooks for memory checkers.

Patch 6

Move gfpflag masking out of the allocator hotpath

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
