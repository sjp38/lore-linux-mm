Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 701AC6B033C
	for <linux-mm@kvack.org>; Wed, 24 May 2017 05:00:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q23so5050232pgn.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 02:00:57 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j17si23548703pfj.239.2017.05.24.02.00.55
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 02:00:56 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v7 12/16] pagemap.h: Remove trailing white space
Date: Wed, 24 May 2017 17:59:45 +0900
Message-Id: <1495616389-29772-13-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

Trailing white space is not accepted in kernel coding style. Remove
them.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/pagemap.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7dbe914..a8ee59a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -504,7 +504,7 @@ static inline void wake_up_page(struct page *page, int bit)
 	__wake_up_bit(page_waitqueue(page), &page->flags, bit);
 }
 
-/* 
+/*
  * Wait for a page to be unlocked.
  *
  * This must be called with the caller "holding" the page,
@@ -517,7 +517,7 @@ static inline void wait_on_page_locked(struct page *page)
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
