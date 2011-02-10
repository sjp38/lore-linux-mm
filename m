Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 05E158D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 23:58:09 -0500 (EST)
Received: by gxk5 with SMTP id 5so445922gxk.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 20:58:08 -0800 (PST)
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Subject: [PATCH v2] mm: Fix out-of-date comments which refers non-existent functions
Date: Thu, 10 Feb 2011 13:56:28 +0900
Message-Id: <1297313788-10905-1-git-send-email-ozaki.ryota@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Jiri Kosina <trivial@kernel.org>

From: Ryota Ozaki <ozaki.ryota@gmail.com>

do_file_page and do_no_page don't exist anymore, but some comments
still refers them. The patch fixes them by replacing them with
existing ones.

Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Jiri Kosina <trivial@kernel.org>
---
 arch/alpha/include/asm/cacheflush.h |    2 +-
 arch/avr32/mm/cache.c               |    2 +-
 mm/memory.c                         |    6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

Change from v1: Fix two files other than mm/memory.c as well.

diff --git a/arch/alpha/include/asm/cacheflush.h b/arch/alpha/include/asm/cacheflush.h
index 012f124..a9cb6aa 100644
--- a/arch/alpha/include/asm/cacheflush.h
+++ b/arch/alpha/include/asm/cacheflush.h
@@ -63,7 +63,7 @@ extern void flush_icache_user_range(struct vm_area_struct *vma,
 		struct page *page, unsigned long addr, int len);
 #endif
 
-/* This is used only in do_no_page and do_swap_page.  */
+/* This is used only in __do_fault and do_swap_page.  */
 #define flush_icache_page(vma, page) \
   flush_icache_user_range((vma), (page), 0, 0)
 
diff --git a/arch/avr32/mm/cache.c b/arch/avr32/mm/cache.c
index 24a74d1..6a46ecd 100644
--- a/arch/avr32/mm/cache.c
+++ b/arch/avr32/mm/cache.c
@@ -113,7 +113,7 @@ void flush_icache_range(unsigned long start, unsigned long end)
 }
 
 /*
- * This one is called from do_no_page(), do_swap_page() and install_page().
+ * This one is called from __do_fault() and do_swap_page().
  */
 void flush_icache_page(struct vm_area_struct *vma, struct page *page)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 31250fa..3fbf32a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2115,10 +2115,10 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
  * handle_pte_fault chooses page fault handler according to an entry
  * which was read non-atomically.  Before making any commitment, on
  * those architectures or configurations (e.g. i386 with PAE) which
- * might give a mix of unmatched parts, do_swap_page and do_file_page
+ * might give a mix of unmatched parts, do_swap_page and do_nonlinear_fault
  * must check under lock before unmapping the pte and proceeding
  * (but do_wp_page is only called after already making such a check;
- * and do_anonymous_page and do_no_page can safely check later on).
+ * and do_anonymous_page can safely check later on).
  */
 static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
 				pte_t *page_table, pte_t orig_pte)
@@ -2316,7 +2316,7 @@ reuse:
 		 * bit after it clear all dirty ptes, but before a racing
 		 * do_wp_page installs a dirty pte.
 		 *
-		 * do_no_page is protected similarly.
+		 * __do_fault is protected similarly.
 		 */
 		if (!page_mkwrite) {
 			wait_on_page_locked(dirty_page);
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
