Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id E155B6B005A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:15:33 -0400 (EDT)
Message-Id: <20120802201532.052859834@linux.com>
Date: Thu, 02 Aug 2012 15:15:09 -0500
From: Christoph Lameter <cl@linux.com>
Subject: Common [03/19] Rename oops label
References: <20120802201506.266817615@linux.com>
Content-Disposition: inline; filename=remove_oops
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

The label is actually used for successful exits so change the name.

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
