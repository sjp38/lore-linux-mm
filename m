Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B01D96B038C
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 04:26:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y17so361267782pgh.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 01:26:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x185si14004374pgd.414.2017.03.14.01.26.22
        for <linux-mm@kvack.org>;
        Tue, 14 Mar 2017 01:26:23 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v6 11/15] pagemap.h: Remove trailing white space
Date: Tue, 14 Mar 2017 17:18:58 +0900
Message-ID: <1489479542-27030-12-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

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
