From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 16/23] FS: XFS slab defragmentation
Date: Tue, 06 Nov 2007 17:11:46 -0800
Message-ID: <20071107011230.435257780@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757977AbXKGBRi@vger.kernel.org>
Content-Disposition: inline; filename=0019-slab_defrag_xfs.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Support inode defragmentation for xfs

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 fs/xfs/linux-2.6/xfs_super.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/fs/xfs/linux-2.6/xfs_super.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_super.c	2007-11-06 12:57:26.000000000 -0800
+++ linux-2.6/fs/xfs/linux-2.6/xfs_super.c	2007-11-06 12:57:34.000000000 -0800
@@ -374,6 +374,7 @@ xfs_init_zones(void)
 	xfs_ioend_zone = kmem_zone_init(sizeof(xfs_ioend_t), "xfs_ioend");
 	if (!xfs_ioend_zone)
 		goto out_destroy_vnode_zone;
+	kmem_cache_setup_defrag(xfs_vnode_zone, get_inodes, kick_inodes);
 
 	xfs_ioend_pool = mempool_create_slab_pool(4 * MAX_BUF_PER_PAGE,
 						  xfs_ioend_zone);

-- 
