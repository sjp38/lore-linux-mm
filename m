Date: Tue, 21 Nov 2006 12:37:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061121203713.30802.86878.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
References: <20061121203647.30802.20845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/6] Move fs_cachep  to linux/fs_struct.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Move fs_cachep declaration to linux/fs_struct.h.

fs_cachep is only used in kernel/exit.c and in kernel/fork.c.

It is used to store fs_struct items so it should be placed in linux/fs_struct.h

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc5-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/slab.h	2006-11-21 14:15:25.356525757 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/slab.h	2006-11-21 14:17:18.977722945 -0600
@@ -298,7 +298,6 @@ static inline void kmem_set_shrinker(kme
 
 /* System wide caches */
 extern kmem_cache_t	*names_cachep;
-extern kmem_cache_t	*fs_cachep;
 
 #endif	/* __KERNEL__ */
 
Index: linux-2.6.19-rc5-mm2/include/linux/fs_struct.h
===================================================================
--- linux-2.6.19-rc5-mm2.orig/include/linux/fs_struct.h	2006-11-07 20:24:20.000000000 -0600
+++ linux-2.6.19-rc5-mm2/include/linux/fs_struct.h	2006-11-21 14:19:25.171312070 -0600
@@ -18,6 +18,8 @@ struct fs_struct {
 	.umask		= 0022, \
 }
 
+extern struct kmem_cache *fs_cachep;
+
 extern void exit_fs(struct task_struct *);
 extern void set_fs_altroot(void);
 extern void set_fs_root(struct fs_struct *, struct vfsmount *, struct dentry *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
