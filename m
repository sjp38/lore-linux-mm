Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7C0DD6B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 14:44:07 -0400 (EDT)
Date: Fri, 16 Oct 2009 11:43:57 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH] mm/vmscan: change comment generic_file_write to
 __generic_file_aio_write
In-Reply-To: <1251238688-20751-1-git-send-email-macli@brc.ubc.ca>
Message-ID: <alpine.DEB.2.00.0910161141560.24787@kernalhack.brc.ubc.ca>
References: <1251238688-20751-1-git-send-email-macli@brc.ubc.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Commit 543ade1fc9 (Streamline generic_file_* interfaces and filemap cleanups)
removed generic_file_write() in filemap. Change the comment in vmscan
pageout() to __generic_file_aio_write().

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 64e4388..34ed10f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -358,7 +358,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 	 * stalls if we need to run get_block().  We could test
 	 * PagePrivate for that.
 	 *
-	 * If this process is currently in generic_file_write() against
+	 * If this process is currently in __generic_file_aio_write() against
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
