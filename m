Date: Mon, 14 May 2007 19:49:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLAB: Move two remaining SLAB specific definitions to slab_def.h
Message-ID: <Pine.LNX.4.64.0705141948410.27741@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Two definitions remained in slab.h that are particular to the SLAB allocator.
Move to slab_def.h

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slab.h     |    3 ---
 include/linux/slab_def.h |    3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: slub/include/linux/slab.h
===================================================================
--- slub.orig/include/linux/slab.h	2007-05-14 17:43:58.000000000 -0700
+++ slub/include/linux/slab.h	2007-05-14 19:46:57.000000000 -0700
@@ -248,9 +248,6 @@ extern void *__kmalloc_node_track_caller
 
 #endif /* DEBUG_SLAB */
 
-extern const struct seq_operations slabinfo_op;
-ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
-
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SLAB_H */
 
Index: slub/include/linux/slab_def.h
===================================================================
--- slub.orig/include/linux/slab_def.h	2007-05-14 17:26:15.000000000 -0700
+++ slub/include/linux/slab_def.h	2007-05-14 19:46:57.000000000 -0700
@@ -109,4 +109,7 @@ found:
 
 #endif	/* CONFIG_NUMA */
 
+extern const struct seq_operations slabinfo_op;
+ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
+
 #endif	/* _LINUX_SLAB_DEF_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
