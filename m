Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 0F4936B0085
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 10:22:07 -0400 (EDT)
Message-Id: <20120809135633.964496457@linux.com>
Date: Thu, 09 Aug 2012 08:56:26 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common11r [03/20] Rename oops label
References: <20120809135623.574621297@linux.com>
Content-Disposition: inline; filename=remove_oops
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The label is actually used for successful exits so change the name.
Easy to do now before more users of this label surface.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-08-02 09:18:07.570384286 -0500
+++ linux-2.6/mm/slab_common.c	2012-08-02 09:18:53.311194644 -0500
@@ -89,7 +89,7 @@
 				name);
 			dump_stack();
 			s = NULL;
-			goto oops;
+			goto out_locked;
 		}
 	}
 
@@ -99,7 +99,7 @@
 	s = __kmem_cache_create(name, size, align, flags, ctor);
 
 #ifdef CONFIG_DEBUG_VM
-oops:
+out_locked:
 #endif
 	mutex_unlock(&slab_mutex);
 	put_online_cpus();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
