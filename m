Message-Id: <20071227203403.385822449@sgi.com>
References: <20071227203253.297427289@sgi.com>
Date: Thu, 27 Dec 2007 12:33:04 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [11/17] FS: XFS slab defragmentation
Content-Disposition: inline; filename=0057-FS-XFS-slab-defragmentation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Support inode defragmentation for xfs

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/xfs/linux-2.6/xfs_super.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.24-rc6-mm1/fs/xfs/linux-2.6/xfs_super.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/xfs/linux-2.6/xfs_super.c	2007-12-26 17:47:05.835426348 -0800
+++ linux-2.6.24-rc6-mm1/fs/xfs/linux-2.6/xfs_super.c	2007-12-27 12:04:40.602327493 -0800
@@ -805,6 +805,7 @@ xfs_init_zones(void)
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
