Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 95D776B009F
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 06:07:30 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBHB9E9U021234
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Dec 2008 20:09:14 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 00AFE45DE61
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:09:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFAED45DE51
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:09:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B10C71DB803F
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:09:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 66B8C1DB803A
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 20:09:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] remove CONFIG_OUT_OF_LINE_PFN_TO_PAGE
Message-Id: <20081217200812.FF1E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Dec 2008 20:09:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Now, any architecture don't use CONFIG_OUT_OF_LINE_PFN_TO_PAGE at all.
it can be removed.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/asm-generic/memory_model.h |    7 -------
 mm/page_alloc.c                    |   13 -------------
 2 files changed, 20 deletions(-)

Index: b/include/asm-generic/memory_model.h
===================================================================
--- a/include/asm-generic/memory_model.h
+++ b/include/asm-generic/memory_model.h
@@ -69,15 +69,8 @@
 })
 #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
 
-#ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
-struct page;
-/* this is useful when inlined pfn_to_page is too big */
-extern struct page *pfn_to_page(unsigned long pfn);
-extern unsigned long page_to_pfn(struct page *page);
-#else
 #define page_to_pfn __page_to_pfn
 #define pfn_to_page __pfn_to_page
-#endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
 
 #endif /* __ASSEMBLY__ */
 
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4593,19 +4593,6 @@ void *__init alloc_large_system_hash(con
 	return table;
 }
 
-#ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
-struct page *pfn_to_page(unsigned long pfn)
-{
-	return __pfn_to_page(pfn);
-}
-unsigned long page_to_pfn(struct page *page)
-{
-	return __page_to_pfn(page);
-}
-EXPORT_SYMBOL(pfn_to_page);
-EXPORT_SYMBOL(page_to_pfn);
-#endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
-
 /* Return a pointer to the bitmap storing bits affecting a block of pages */
 static inline unsigned long *get_pageblock_bitmap(struct zone *zone,
 							unsigned long pfn)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
