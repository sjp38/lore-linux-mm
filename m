Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 18450600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:40:54 -0500 (EST)
From: Yehuda Sadeh <yehuda@hq.newdream.net>
Subject: [PATCH] mm/page-writeback: export account_page_dirtied()
Date: Tue,  8 Dec 2009 13:41:59 -0800
Message-Id: <1260308519-16899-1-git-send-email-yehuda@hq.newdream.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Yehuda Sadeh <yehuda@hq.newdream.net>, linux-kernel@vger.kernel.org, sage@newdream.net
List-ID: <linux-mm.kvack.org>

The ceph filesystem implementation of set_page_dirty is based on
__set_page_dirty_nobuffers(), and needs to use account_page_dirtied(). It
uses its own implementation as it needs to set the page private bit and
value under the tree lock. This exports it using EXPORT_SYMBOL_GPL.

Signed-off-by: Yehuda Sadeh <yehuda@hq.newdream.net>
---
 mm/page-writeback.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a3b1409..4f8412a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1095,6 +1095,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
 }
+EXPORT_SYMBOL_GPL(account_page_dirtied);
 
 /*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
