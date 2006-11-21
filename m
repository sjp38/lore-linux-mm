Date: Tue, 21 Nov 2006 12:37:08 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061121203708.30802.99815.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
References: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/6] Move filep_cachep to include/file.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Move filp_cachep to linux/file.h

filp_cachep is only used in fs/file_table.c and in fs/dcache.c where
it is defined.

Move it to related definitions in linux/file.h.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-21 14:15:15.653534517 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-21 14:15:25.356525757 -0600
@@ -298,7 +298,6 @@ static inline void kmem_set_shrinker(kme
 
 /* System wide caches */
 extern kmem_cache_t	*names_cachep;
-extern kmem_cache_t	*filp_cachep;
 extern kmem_cache_t	*fs_cachep;
 
 #endif	/* __KERNEL__ */
Index: linux-2.6.19-rc5-mm2/include/linux/file.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/file.h	2006-11-21 14:15:08.000000000 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/file.h	2006-11-21 14:16:51.302466932 -0600
@@ -57,6 +57,8 @@ struct files_struct {
 
 #define files_fdtable(files) (rcu_dereference((files)->fdt))
 
+extern struct kmem_cache *filp_cachep;
+
 extern void FASTCALL(__fput(struct file *));
 extern void FASTCALL(fput(struct file *));
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
