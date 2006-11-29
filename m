Date: Tue, 28 Nov 2006 16:44:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004447.11682.82557.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
References: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/8] Get rid of SLAB_NOFS
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Get rid of SLAB_NOFS

SLAB_NOFS is an alias of GFP_NOFS.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/fs/nfs/read.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/read.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/read.c	2006-11-28 16:08:36.000000000 -0800
@@ -46,7 +46,7 @@
 struct nfs_read_data *nfs_readdata_alloc(size_t len)
 {
 	unsigned int pagecount = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, SLAB_NOFS);
+	struct nfs_read_data *p = mempool_alloc(nfs_rdata_mempool, GFP_NOFS);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
Index: linux-2.6.19-rc6-mm1/fs/nfs/write.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/nfs/write.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/nfs/write.c	2006-11-28 16:08:36.000000000 -0800
@@ -93,7 +93,7 @@
 
 struct nfs_write_data *nfs_commit_alloc(void)
 {
-	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, SLAB_NOFS);
+	struct nfs_write_data *p = mempool_alloc(nfs_commit_mempool, GFP_NOFS);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -112,7 +112,7 @@
 struct nfs_write_data *nfs_writedata_alloc(size_t len)
 {
 	unsigned int pagecount = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, SLAB_NOFS);
+	struct nfs_write_data *p = mempool_alloc(nfs_wdata_mempool, GFP_NOFS);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
Index: linux-2.6.19-rc6-mm1/fs/cifs/misc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/cifs/misc.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/cifs/misc.c	2006-11-28 16:08:36.000000000 -0800
@@ -153,7 +153,7 @@
    albeit slightly larger than necessary and maxbuffersize 
    defaults to this and can not be bigger */
 	ret_buf =
-	    (struct smb_hdr *) mempool_alloc(cifs_req_poolp, SLAB_KERNEL | SLAB_NOFS);
+	    (struct smb_hdr *) mempool_alloc(cifs_req_poolp, SLAB_KERNEL | GFP_NOFS);
 
 	/* clear the first few header bytes */
 	/* for most paths, more is cleared in header_assemble */
@@ -192,7 +192,7 @@
    albeit slightly larger than necessary and maxbuffersize 
    defaults to this and can not be bigger */
 	ret_buf =
-	    (struct smb_hdr *) mempool_alloc(cifs_sm_req_poolp, SLAB_KERNEL | SLAB_NOFS);
+	    (struct smb_hdr *) mempool_alloc(cifs_sm_req_poolp, SLAB_KERNEL | GFP_NOFS);
 	if (ret_buf) {
 	/* No need to clear memory here, cleared in header assemble */
 	/*	memset(ret_buf, 0, sizeof(struct smb_hdr) + 27);*/
Index: linux-2.6.19-rc6-mm1/fs/cifs/transport.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/cifs/transport.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/cifs/transport.c	2006-11-28 16:08:36.000000000 -0800
@@ -51,7 +51,7 @@
 	}
 	
 	temp = (struct mid_q_entry *) mempool_alloc(cifs_mid_poolp,
-						    SLAB_KERNEL | SLAB_NOFS);
+						    SLAB_KERNEL | GFP_NOFS);
 	if (temp == NULL)
 		return temp;
 	else {
Index: linux-2.6.19-rc6-mm1/fs/ext3/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ext3/super.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ext3/super.c	2006-11-28 16:08:36.000000000 -0800
@@ -445,7 +445,7 @@
 {
 	struct ext3_inode_info *ei;
 
-	ei = kmem_cache_alloc(ext3_inode_cachep, SLAB_NOFS);
+	ei = kmem_cache_alloc(ext3_inode_cachep, GFP_NOFS);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT3_FS_POSIX_ACL
Index: linux-2.6.19-rc6-mm1/fs/ext4/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ext4/super.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ext4/super.c	2006-11-28 16:08:36.000000000 -0800
@@ -495,7 +495,7 @@
 {
 	struct ext4_inode_info *ei;
 
-	ei = kmem_cache_alloc(ext4_inode_cachep, SLAB_NOFS);
+	ei = kmem_cache_alloc(ext4_inode_cachep, GFP_NOFS);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT4DEV_FS_POSIX_ACL
Index: linux-2.6.19-rc6-mm1/fs/hpfs/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/hpfs/super.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/hpfs/super.c	2006-11-28 16:08:36.000000000 -0800
@@ -160,7 +160,7 @@
 static struct inode *hpfs_alloc_inode(struct super_block *sb)
 {
 	struct hpfs_inode_info *ei;
-	ei = (struct hpfs_inode_info *)kmem_cache_alloc(hpfs_inode_cachep, SLAB_NOFS);
+	ei = (struct hpfs_inode_info *)kmem_cache_alloc(hpfs_inode_cachep, GFP_NOFS);
 	if (!ei)
 		return NULL;
 	ei->vfs_inode.i_version = 1;
Index: linux-2.6.19-rc6-mm1/fs/ntfs/attrib.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ntfs/attrib.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ntfs/attrib.c	2006-11-28 16:08:36.000000000 -0800
@@ -1272,7 +1272,7 @@
 {
 	ntfs_attr_search_ctx *ctx;
 
-	ctx = kmem_cache_alloc(ntfs_attr_ctx_cache, SLAB_NOFS);
+	ctx = kmem_cache_alloc(ntfs_attr_ctx_cache, GFP_NOFS);
 	if (ctx)
 		ntfs_attr_init_search_ctx(ctx, ni, mrec);
 	return ctx;
Index: linux-2.6.19-rc6-mm1/fs/ntfs/unistr.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ntfs/unistr.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ntfs/unistr.c	2006-11-28 16:08:36.000000000 -0800
@@ -266,7 +266,7 @@
 
 	/* We do not trust outside sources. */
 	if (likely(ins)) {
-		ucs = kmem_cache_alloc(ntfs_name_cache, SLAB_NOFS);
+		ucs = kmem_cache_alloc(ntfs_name_cache, GFP_NOFS);
 		if (likely(ucs)) {
 			for (i = o = 0; i < ins_len; i += wc_len) {
 				wc_len = nls->char2uni(ins + i, ins_len - i,
Index: linux-2.6.19-rc6-mm1/fs/ntfs/index.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ntfs/index.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ntfs/index.c	2006-11-28 16:08:36.000000000 -0800
@@ -38,7 +38,7 @@
 {
 	ntfs_index_context *ictx;
 
-	ictx = kmem_cache_alloc(ntfs_index_ctx_cache, SLAB_NOFS);
+	ictx = kmem_cache_alloc(ntfs_index_ctx_cache, GFP_NOFS);
 	if (ictx)
 		*ictx = (ntfs_index_context){ .idx_ni = idx_ni };
 	return ictx;
Index: linux-2.6.19-rc6-mm1/fs/ntfs/inode.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ntfs/inode.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ntfs/inode.c	2006-11-28 16:08:36.000000000 -0800
@@ -324,7 +324,7 @@
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = kmem_cache_alloc(ntfs_big_inode_cache, SLAB_NOFS);
+	ni = kmem_cache_alloc(ntfs_big_inode_cache, GFP_NOFS);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return VFS_I(ni);
@@ -349,7 +349,7 @@
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = kmem_cache_alloc(ntfs_inode_cache, SLAB_NOFS);
+	ni = kmem_cache_alloc(ntfs_inode_cache, GFP_NOFS);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return ni;
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/dlm/dlmfs.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/dlm/dlmfs.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/dlm/dlmfs.c	2006-11-28 16:08:36.000000000 -0800
@@ -276,7 +276,7 @@
 {
 	struct dlmfs_inode_private *ip;
 
-	ip = kmem_cache_alloc(dlmfs_inode_cache, SLAB_NOFS);
+	ip = kmem_cache_alloc(dlmfs_inode_cache, GFP_NOFS);
 	if (!ip)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/fs/ocfs2/super.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/ocfs2/super.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/ocfs2/super.c	2006-11-28 16:08:36.000000000 -0800
@@ -303,7 +303,7 @@
 {
 	struct ocfs2_inode_info *oi;
 
-	oi = kmem_cache_alloc(ocfs2_inode_cachep, SLAB_NOFS);
+	oi = kmem_cache_alloc(ocfs2_inode_cachep, GFP_NOFS);
 	if (!oi)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/fs/dquot.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/fs/dquot.c	2006-11-28 16:02:32.000000000 -0800
+++ linux-2.6.19-rc6-mm1/fs/dquot.c	2006-11-28 16:08:36.000000000 -0800
@@ -600,7 +600,7 @@
 {
 	struct dquot *dquot;
 
-	dquot = kmem_cache_alloc(dquot_cachep, SLAB_NOFS);
+	dquot = kmem_cache_alloc(dquot_cachep, GFP_NOFS);
 	if(!dquot)
 		return NODQUOT;
 
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 16:08:11.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 16:08:50.000000000 -0800
@@ -17,7 +17,6 @@
 #include	<linux/types.h>
 
 /* flags for kmem_cache_alloc() */
-#define	SLAB_NOFS		GFP_NOFS
 #define	SLAB_ATOMIC		GFP_ATOMIC
 #define	SLAB_USER		GFP_USER
 #define	SLAB_KERNEL		GFP_KERNEL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
