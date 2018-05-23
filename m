Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7BED6B027E
	for <linux-mm@kvack.org>; Wed, 23 May 2018 10:45:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 62-v6so13145839pfw.21
        for <linux-mm@kvack.org>; Wed, 23 May 2018 07:45:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j91-v6si18500431pld.402.2018.05.23.07.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 07:45:13 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 23/34] xfs: remove the now unused XFS_BMAPI_IGSTATE flag
Date: Wed, 23 May 2018 16:43:46 +0200
Message-Id: <20180523144357.18985-24-hch@lst.de>
In-Reply-To: <20180523144357.18985-1-hch@lst.de>
References: <20180523144357.18985-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/libxfs/xfs_bmap.c | 6 ++----
 fs/xfs/libxfs/xfs_bmap.h | 3 ---
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
index 7b0e2b551e23..4b5e014417d2 100644
--- a/fs/xfs/libxfs/xfs_bmap.c
+++ b/fs/xfs/libxfs/xfs_bmap.c
@@ -3799,8 +3799,7 @@ xfs_bmapi_update_map(
 		   mval[-1].br_startblock != HOLESTARTBLOCK &&
 		   mval->br_startblock == mval[-1].br_startblock +
 					  mval[-1].br_blockcount &&
-		   ((flags & XFS_BMAPI_IGSTATE) ||
-			mval[-1].br_state == mval->br_state)) {
+		   mval[-1].br_state == mval->br_state) {
 		ASSERT(mval->br_startoff ==
 		       mval[-1].br_startoff + mval[-1].br_blockcount);
 		mval[-1].br_blockcount += mval->br_blockcount;
@@ -3845,7 +3844,7 @@ xfs_bmapi_read(
 
 	ASSERT(*nmap >= 1);
 	ASSERT(!(flags & ~(XFS_BMAPI_ATTRFORK|XFS_BMAPI_ENTIRE|
-			   XFS_BMAPI_IGSTATE|XFS_BMAPI_COWFORK)));
+			   XFS_BMAPI_COWFORK)));
 	ASSERT(xfs_isilocked(ip, XFS_ILOCK_SHARED|XFS_ILOCK_EXCL));
 
 	if (unlikely(XFS_TEST_ERROR(
@@ -4290,7 +4289,6 @@ xfs_bmapi_write(
 
 	ASSERT(*nmap >= 1);
 	ASSERT(*nmap <= XFS_BMAP_MAX_NMAP);
-	ASSERT(!(flags & XFS_BMAPI_IGSTATE));
 	ASSERT(tp != NULL ||
 	       (flags & (XFS_BMAPI_CONVERT | XFS_BMAPI_COWFORK)) ==
 			(XFS_BMAPI_CONVERT | XFS_BMAPI_COWFORK));
diff --git a/fs/xfs/libxfs/xfs_bmap.h b/fs/xfs/libxfs/xfs_bmap.h
index 2c233f9f1a26..a845fe57d1b5 100644
--- a/fs/xfs/libxfs/xfs_bmap.h
+++ b/fs/xfs/libxfs/xfs_bmap.h
@@ -80,8 +80,6 @@ struct xfs_extent_free_item
 #define XFS_BMAPI_METADATA	0x002	/* mapping metadata not user data */
 #define XFS_BMAPI_ATTRFORK	0x004	/* use attribute fork not data */
 #define XFS_BMAPI_PREALLOC	0x008	/* preallocation op: unwritten space */
-#define XFS_BMAPI_IGSTATE	0x010	/* Ignore state - */
-					/* combine contig. space */
 #define XFS_BMAPI_CONTIG	0x020	/* must allocate only one extent */
 /*
  * unwritten extent conversion - this needs write cache flushing and no additional
@@ -128,7 +126,6 @@ struct xfs_extent_free_item
 	{ XFS_BMAPI_METADATA,	"METADATA" }, \
 	{ XFS_BMAPI_ATTRFORK,	"ATTRFORK" }, \
 	{ XFS_BMAPI_PREALLOC,	"PREALLOC" }, \
-	{ XFS_BMAPI_IGSTATE,	"IGSTATE" }, \
 	{ XFS_BMAPI_CONTIG,	"CONTIG" }, \
 	{ XFS_BMAPI_CONVERT,	"CONVERT" }, \
 	{ XFS_BMAPI_ZERO,	"ZERO" }, \
-- 
2.17.0
