Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2D5C46B0088
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:51:00 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:59 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 11/12] mm: declare some external symbols
Date: Thu, 30 Sep 2010 12:50:20 +0900
Message-Id: <1285818621-29890-12-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Declare 'bdi_pending_list' and 'tag_pages_for_writeback()' to remove
following sparse warnings:

 mm/backing-dev.c:46:1: warning: symbol 'bdi_pending_list' was not declared. Should it be static?
 mm/page-writeback.c:825:6: warning: symbol 'tag_pages_for_writeback' was not declared. Should it be static?

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 include/linux/backing-dev.h |    1 +
 include/linux/writeback.h   |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index 35b0074..8b0ae8b 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -111,6 +111,7 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi);
 
 extern spinlock_t bdi_lock;
 extern struct list_head bdi_list;
+extern struct list_head bdi_pending_list;
 
 static inline int wb_has_dirty_io(struct bdi_writeback *wb)
 {
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 72a5d64..c7299d2 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -149,6 +149,8 @@ int write_cache_pages(struct address_space *mapping,
 int do_writepages(struct address_space *mapping, struct writeback_control *wbc);
 void set_page_dirty_balance(struct page *page, int page_mkwrite);
 void writeback_set_ratelimit(void);
+void tag_pages_for_writeback(struct address_space *mapping,
+			     pgoff_t start, pgoff_t end);
 
 /* pdflush.c */
 extern int nr_pdflush_threads;	/* Global so it can be exported to sysctl
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
