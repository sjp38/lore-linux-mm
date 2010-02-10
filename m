Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AB1A76B0082
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:03:52 -0500 (EST)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/13] NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background is set
Date: Wed, 10 Feb 2010 12:03:26 -0500
Message-Id: <1265821413-21618-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1265821413-21618-1-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-2-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-3-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-4-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-5-git-send-email-Trond.Myklebust@netapp.com>
 <1265821413-21618-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2f1d9a6..8533a2f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1420,7 +1420,7 @@ static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_contr
 		    NFS_PAGE_TAG_LOCKED))
 		goto out_mark_dirty;
 
-	if (wbc->nonblocking)
+	if (wbc->nonblocking || wbc->for_background)
 		flags = 0;
 	ret = nfs_commit_inode(inode, flags);
 	if (ret >= 0)
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
