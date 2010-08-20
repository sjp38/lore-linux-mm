Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 033B46B0333
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 09:31:49 -0400 (EDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: update comments in nfs_commit_unstable_pages
Date: Fri, 20 Aug 2010 09:31:41 -0400
Message-Id: <1282311101-30650-1-git-send-email-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Wu Fengguang <fengguang.wu@gmail.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/write.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 35bd7d0..d417790 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1433,12 +1433,14 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 	int flags = FLUSH_SYNC;
 	int ret = 0;
 
-	/* Don't commit yet if this is a non-blocking flush and there are
-	 * lots of outstanding writes for this mapping.
-	 */
 	if (wbc->sync_mode == WB_SYNC_NONE) {
+		/* Don't commit yet if this is a non-blocking flush and there
+		 * are a lot of outstanding writes for this mapping.
+		 */
 		if (nfsi->ncommit <= (nfsi->npages >> 1))
 			goto out_mark_dirty;
+
+		/* don't wait for the COMMIT response */
 		flags = 0;
 	}
 
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
