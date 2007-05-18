Date: Fri, 18 May 2007 11:26:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 06/10] xfs: inode defragmentation support
In-Reply-To: <20070518181119.997242349@sgi.com>
Message-ID: <Pine.LNX.4.64.0705181124430.11881@schroedinger.engr.sgi.com>
References: <20070518181040.465335396@sgi.com> <20070518181119.997242349@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Rats. Missing a piece due to the need to change the parameters of
kmem_zone_init_flags (Isnt it possible to use kmem_cache_create 
directly?).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: slub/fs/xfs/xfs_vfsops.c
===================================================================
--- slub.orig/fs/xfs/xfs_vfsops.c	2007-05-18 11:23:27.000000000 -0700
+++ slub/fs/xfs/xfs_vfsops.c	2007-05-17 22:14:34.000000000 -0700
@@ -109,13 +109,13 @@ xfs_init(void)
 	xfs_inode_zone =
 		kmem_zone_init_flags(sizeof(xfs_inode_t), "xfs_inode",
 					KM_ZONE_HWALIGN | KM_ZONE_RECLAIM |
-					KM_ZONE_SPREAD, NULL);
+					KM_ZONE_SPREAD, NULL, NULL);
 	xfs_ili_zone =
 		kmem_zone_init_flags(sizeof(xfs_inode_log_item_t), "xfs_ili",
-					KM_ZONE_SPREAD, NULL);
+					KM_ZONE_SPREAD, NULL, NULL);
 	xfs_chashlist_zone =
 		kmem_zone_init_flags(sizeof(xfs_chashlist_t), "xfs_chashlist",
-					KM_ZONE_SPREAD, NULL);
+					KM_ZONE_SPREAD, NULL, NULL);
 
 	/*
 	 * Allocate global trace buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
