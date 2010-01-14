Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3A1596B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 10:18:44 -0500 (EST)
Date: Thu, 14 Jan 2010 09:18:40 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
In-Reply-To: <20100113002923.GF2985@ldl.fc.hp.com>
Message-ID: <alpine.DEB.2.00.1001140917110.14164@router.home>
References: <20100113002923.GF2985@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Try this


Subject: [SLUB] Size kmalloc_percpu correctly

We need kmalloc_percpu for all kmalloc caches not just for each shift
value.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-01-14 09:16:12.000000000 -0600
+++ linux-2.6/mm/slub.c	2010-01-14 09:16:27.000000000 -0600
@@ -2086,7 +2086,7 @@ init_kmem_cache_node(struct kmem_cache_n
 #endif
 }

-static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);

 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
