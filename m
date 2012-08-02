Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1961F6B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:45:26 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:45:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
In-Reply-To: <501A8BE4.4060206@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020941150.23049@router.home>
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com> <alpine.DEB.2.00.1208020912340.23049@router.home> <501A8BE4.4060206@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> It also works okay both before the patches are applied, and with slab.

Ok. I am seeing the same problem when using the following patch. That is
pretty early during boot and so there may be issues with sysfs that the
patchset caused. Looking into it.

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-08-02 09:36:04.855637689 -0500
+++ linux-2.6/mm/slub.c	2012-08-02 09:42:04.358089667 -0500
@@ -3768,6 +3768,16 @@
 		caches, cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
+
+	{ struct kmem_cache *qq;
+
+		qq = create_kmalloc_cache("qq", 800, 0);
+		kmem_cache_destroy(qq);
+
+		qq = create_kmalloc_cache("qq", 800, 0);
+		kmem_cache_destroy(qq);
+	}
+
 }

 void __init kmem_cache_init_late(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
