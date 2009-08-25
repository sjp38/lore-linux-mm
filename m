Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 10DFB6B00E5
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:18:00 -0400 (EDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH] mm/vmscan: change generic_file_write() comment to do_sync_write()
Date: Tue, 25 Aug 2009 15:18:08 -0700
Message-Id: <1251238688-20751-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Vincent Li <macli@brc.ubc.ca>
List-ID: <linux-mm.kvack.org>

Commit 543ade1fc9 (Streamline generic_file_* interfaces and filemap cleanups)
removed generic_file_write() in filemap. For consistency, change the comment in
vmscan pageout() to do_sync_write().

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1219ceb..5e03c22 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -358,7 +358,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	 * stalls if we need to run get_block().  We could test
 	 * PagePrivate for that.
 	 *
-	 * If this process is currently in generic_file_write() against
+	 * If this process is currently in do_sync_write() against
 	 * this page's queue, we can perform writeback even if that
 	 * will block.
 	 *
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
