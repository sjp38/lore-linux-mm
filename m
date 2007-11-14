Message-Id: <20071114221022.125393125@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:17 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 11/17] FS: XFS slab defragmentation
Content-Disposition: inline; filename=0057-FS-XFS-slab-defragmentation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Support inode defragmentation for xfs

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/xfs/linux-2.6/xfs_super.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.24-rc2-mm1/fs/xfs/linux-2.6/xfs_super.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/fs/xfs/linux-2.6/xfs_super.c	2007-11-14 11:08:37.852011611 -0800
+++ linux-2.6.24-rc2-mm1/fs/xfs/linux-2.6/xfs_super.c	2007-11-14 12:19:41.386038485 -0800
@@ -375,6 +375,7 @@ xfs_init_zones(void)
 	xfs_ioend_zone = kmem_zone_init(sizeof(xfs_ioend_t), "xfs_ioend");
 	if (!xfs_ioend_zone)
 		goto out_destroy_vnode_zone;
+	kmem_cache_setup_defrag(xfs_vnode_zone, get_inodes, kick_inodes);
 
 	xfs_ioend_pool = mempool_create_slab_pool(4 * MAX_BUF_PER_PAGE,
 						  xfs_ioend_zone);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
