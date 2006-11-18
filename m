Date: Fri, 17 Nov 2006 21:44:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061118054418.8884.30021.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
References: <20061118054342.8884.12804.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 7/7] Move names_cachep to fs.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

Move names_cachep to fs.h

The names_cachep is used for getname() and putname(). So lets
put it into fs.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-17 23:04:09.679562142 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-17 23:04:13.548058299 -0600
@@ -296,9 +296,6 @@ static inline void kmem_set_shrinker(kme
 
 #endif /* CONFIG_SLOB */
 
-/* System wide caches */
-extern kmem_cache_t	*names_cachep;
-
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_SLAB_H */
Index: linux-2.6.19-rc5-mm2/include/linux/fs.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/fs.h	2006-11-15 16:48:08.629815618 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/fs.h	2006-11-17 23:04:13.586147506 -0600
@@ -1558,6 +1558,8 @@ extern char * getname(const char __user 
 extern void __init vfs_caches_init_early(void);
 extern void __init vfs_caches_init(unsigned long);
 
+extern kmem_cache_t	*names_cachep;
+
 #define __getname()	kmem_cache_alloc(names_cachep, SLAB_KERNEL)
 #define __putname(name) kmem_cache_free(names_cachep, (void *)(name))
 #ifndef CONFIG_AUDITSYSCALL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
