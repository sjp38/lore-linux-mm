Date: Tue, 21 Nov 2006 12:37:03 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061121203703.30802.49792.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
References: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/6] Move files_cachep to include/file.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Move files_cachep to linux/file.h

Proper place is in file.h since files_cachep uses are rated to file I/O.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/file.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/file.h	2006-11-17 23:19:18.242851325 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/file.h	2006-11-21 14:15:08.151906351 -0600
@@ -101,4 +101,6 @@ struct files_struct *get_files_struct(st
 void FASTCALL(put_files_struct(struct files_struct *fs));
 void reset_files_struct(struct task_struct *, struct files_struct *);
 
+extern struct kmem_cache *files_cachep;
+
 #endif /* __LINUX_FILE_H */
Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-21 14:13:54.237282393 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-21 14:14:41.154444046 -0600
@@ -298,7 +298,6 @@ static inline void kmem_set_shrinker(kme
 
 /* System wide caches */
 extern kmem_cache_t	*names_cachep;
-extern kmem_cache_t	*files_cachep;
 extern kmem_cache_t	*filp_cachep;
 extern kmem_cache_t	*fs_cachep;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
