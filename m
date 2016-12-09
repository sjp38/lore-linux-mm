Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 969696B0271
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:37 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so16720060pgq.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:37 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 73si32063268pfw.55.2016.12.08.21.16.36
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:36 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 11/15] pagemap.h: Remove trailing white space
Date: Fri,  9 Dec 2016 14:12:07 +0900
Message-Id: <1481260331-360-12-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
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
