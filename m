Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A5C046B0037
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 10:12:31 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kp12so4015939pab.21
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 07:12:30 -0700 (PDT)
Message-ID: <51C06AC9.2010505@gmail.com>
Date: Tue, 18 Jun 2013 22:12:25 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: Remove unused function __put_page
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

This function is nowhere used, and it has a confusing name with
put_page in mm/swap.c. So better to remove it.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/internal.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 8562de0..4390ac6 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -32,11 +32,6 @@ static inline void set_page_refcounted(struct page *page)
 	set_page_count(page, 1);
 }
 
-static inline void __put_page(struct page *page)
-{
-	atomic_dec(&page->_count);
-}
-
 static inline void __get_page_tail_foll(struct page *page,
 					bool get_page_head)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
