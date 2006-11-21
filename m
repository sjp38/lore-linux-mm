Date: Tue, 21 Nov 2006 12:37:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061121203718.30802.61621.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
References: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 6/6] Move names_cachep to linux/fs.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Move names_cachep to linux/fs.h

The names_cachep is used for getname() and putname(). So lets
put it into fs.h near those two definitions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-21 14:17:18.977722945 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-21 14:23:10.722165644 -0600
@@ -296,9 +297,6 @@ static inline void kmem_set_shrinker(kme
 
 #endif /* CONFIG_SLOB */
 
-/* System wide caches */
-extern kmem_cache_t	*names_cachep;
-
 #endif	/* __KERNEL__ */
 
 #endif	/* _LINUX_SLAB_H */
Index: linux-2.6.19-rc5-mm2/include/linux/fs.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/fs.h	2006-11-17 23:19:17.403912377 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/fs.h	2006-11-21 14:21:02.104542714 -0600
@@ -1558,6 +1558,8 @@ extern char * getname(const char __user 
 extern void __init vfs_caches_init_early(void);
 extern void __init vfs_caches_init(unsigned long);
 
+extern struct kmem_cache *names_cachep;
+
 #define __getname()	kmem_cache_alloc(names_cachep, SLAB_KERNEL)
 #define __putname(name) kmem_cache_free(names_cachep, (void *)(name))
 #ifndef CONFIG_AUDITSYSCALL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
