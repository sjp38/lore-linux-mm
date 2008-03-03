Date: Mon, 3 Mar 2008 12:28:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [git pull] slub cleanup and fixes
Message-ID: <Pine.LNX.4.64.0803031224410.3664@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

A seris of patches is available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slab-linus

Christoph Lameter (9):
      Revert "unique end pointer" patch
      slub: rename slab_objects to show_slab_objects
      slub: Remove objsize check in kmem_cache_flags()
      slub: Remove useless checks in alloc_debug_processing
      slub: Use the objsize from the kmem_cache_cpu structure
      slub: Remove BUG_ON() from ksize and omit checks for !SLUB_DEBUG
      slub: Rearrange #ifdef CONFIG_SLUB_DEBUG in calculate_sizes()
      slub: Fix up comments
      slub: Add kmalloc_large_node() to support kmalloc_node fallback

Cyrill Gorcunov (1):
      slub: fix possible NULL pointer dereference

Pekka J Enberg (1):
      slub: look up object from the freelist once

 include/linux/mm_types.h |    5 +-
 include/linux/slub_def.h |    4 +-
 mm/slub.c                |  204 
++++++++++++++++++++--------------------------
 3 files changed, 92 insertions(+), 121 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
