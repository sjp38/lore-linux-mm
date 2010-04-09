Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D17666B0206
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 22:00:05 -0400 (EDT)
Received: by pvg11 with SMTP id 11so1760704pvg.14
        for <linux-mm@kvack.org>; Thu, 08 Apr 2010 19:00:04 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] readahead.c : fix comment
Date: Fri,  9 Apr 2010 10:03:36 +0800
Message-Id: <1270778616-31508-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

fix the wrong comment for page_cache_async_readahead().

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/readahead.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index dfa9a1a..77506a2 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -523,7 +523,7 @@ EXPORT_SYMBOL_GPL(page_cache_sync_readahead);
  * @req_size: hint: total size of the read which the caller is performing in
  *            pagecache pages
  *
- * page_cache_async_ondemand() should be called when a page is used which
+ * page_cache_async_readahead() should be called when a page is used which
  * has the PG_readahead flag; this is a marker to suggest that the application
  * has used up enough of the readahead window that we should start pulling in
  * more pages.
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
