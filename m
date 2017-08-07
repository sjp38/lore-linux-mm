Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D6C9D6B039F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:14 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u199so89892761pgb.13
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:14 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id o188si4307403pfg.332.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 10/14] pagemap.h: Remove trailing white space
Date: Mon,  7 Aug 2017 16:12:57 +0900
Message-Id: <1502089981-21272-11-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
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
index baa9344..9717ca8 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -506,7 +506,7 @@ static inline int lock_page_or_retry(struct page *page, struct mm_struct *mm,
 extern void wait_on_page_bit(struct page *page, int bit_nr);
 extern int wait_on_page_bit_killable(struct page *page, int bit_nr);
 
-/* 
+/*
  * Wait for a page to be unlocked.
  *
  * This must be called with the caller "holding" the page,
@@ -526,7 +526,7 @@ static inline int wait_on_page_locked_killable(struct page *page)
 	return wait_on_page_bit_killable(compound_head(page), PG_locked);
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
