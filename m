Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E56966B026C
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:32:27 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j185so39143940ith.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:32:27 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id c90si2750267ioa.243.2016.07.07.02.32.21
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:32:22 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 10/13] mm/swap_state.c: Remove trailing white space
Date: Thu,  7 Jul 2016 18:30:00 +0900
Message-Id: <1467883803-29132-11-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Trailing white space is not accepted in kernel coding style. Remove
them.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 mm/swap_state.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 69cb246..3fb7013 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -156,7 +156,7 @@ void __delete_from_swap_cache(struct page *page)
  * @page: page we want to move to swap
  *
  * Allocate swap space for the page and add the page to the
- * swap cache.  Caller needs to hold the page lock. 
+ * swap cache.  Caller needs to hold the page lock.
  */
 int add_to_swap(struct page *page, struct list_head *list)
 {
@@ -229,9 +229,9 @@ void delete_from_swap_cache(struct page *page)
 	page_cache_release(page);
 }
 
-/* 
- * If we are the only user, then try to free up the swap cache. 
- * 
+/*
+ * If we are the only user, then try to free up the swap cache.
+ *
  * Its ok to check for PageSwapCache without the page lock
  * here because we are going to recheck again inside
  * try_to_free_swap() _with_ the lock.
@@ -245,7 +245,7 @@ static inline void free_swap_cache(struct page *page)
 	}
 }
 
-/* 
+/*
  * Perform a free_page(), also freeing any swap cache associated with
  * this page if it is the last user of the page.
  */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
