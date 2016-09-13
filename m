Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1890E6B0269
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:48:28 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id wk8so35545261pab.3
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:48:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c16si26793829pfk.80.2016.09.13.02.48.11
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 02:48:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 11/15] pagemap.h: Remove trailing white space
Date: Tue, 13 Sep 2016 18:45:10 +0900
Message-Id: <1473759914-17003-12-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Trailing white space is not accepted in kernel coding style. Remove
them.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/pagemap.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9735410..0cf6980 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -485,7 +485,7 @@ static inline void wake_up_page(struct page *page, int bit)
 	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
 }
 
-/* 
+/*
  * Wait for a page to be unlocked.
  *
  * This must be called with the caller "holding" the page,
@@ -498,7 +498,7 @@ static inline void wait_on_page_locked(struct page *page)
 		wait_on_page_bit(compound_head(page), PG_locked);
 }
 
-/* 
+/*
  * Wait for a page to complete writeback
  */
 static inline void wait_on_page_writeback(struct page *page)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
