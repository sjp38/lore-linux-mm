Date: Tue, 28 Nov 2006 16:44:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004452.11682.33585.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
References: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/8] Get rid of SLAB_USER
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Get rid of SLAB_USER

SLAB_USER is an alias of GFP_USER

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/crypto.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/crypto.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/crypto.c	2006-11-28 16:08:59.000000000 -0800
@@ -1333,7 +1333,7 @@
 		goto out;
 	}
 	/* Released in this function */
-	page_virt = kmem_cache_alloc(ecryptfs_header_cache_0, SLAB_USER);
+	page_virt = kmem_cache_alloc(ecryptfs_header_cache_0, GFP_USER);
 	if (!page_virt) {
 		ecryptfs_printk(KERN_ERR, "Out of memory\n");
 		rc = -ENOMEM;
@@ -1492,7 +1492,7 @@
 	    &ecryptfs_inode_to_private(ecryptfs_dentry->d_inode)->crypt_stat;
 
 	/* Read the first page from the underlying file */
-	page_virt = kmem_cache_alloc(ecryptfs_header_cache_1, SLAB_USER);
+	page_virt = kmem_cache_alloc(ecryptfs_header_cache_1, GFP_USER);
 	if (!page_virt) {
 		rc = -ENOMEM;
 		ecryptfs_printk(KERN_ERR, "Unable to allocate page_virt\n");
Index: linux-2.6.19-rc6-mm1/fs/ecryptfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ecryptfs/inode.c	2006-11-28 16:02:29.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ecryptfs/inode.c	2006-11-28 16:08:59.000000000 -0800
@@ -363,7 +363,7 @@
 	/* Released in this function */
 	page_virt =
 	    (char *)kmem_cache_alloc(ecryptfs_header_cache_2,
-				     SLAB_USER);
+				     GFP_USER);
 	if (!page_virt) {
 		rc = -ENOMEM;
 		ecryptfs_printk(KERN_ERR,
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 16:08:50.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 16:09:09.000000000 -0800
@@ -18,7 +18,6 @@
 
 /* flags for kmem_cache_alloc() */
 #define	SLAB_ATOMIC		GFP_ATOMIC
-#define	SLAB_USER		GFP_USER
 #define	SLAB_KERNEL		GFP_KERNEL
 #define	SLAB_DMA		GFP_DMA
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
