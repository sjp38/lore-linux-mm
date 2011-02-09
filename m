Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2138D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 09:44:07 -0500 (EST)
Received: by vxb41 with SMTP id 41so99043vxb.14
        for <linux-mm@kvack.org>; Wed, 09 Feb 2011 06:44:03 -0800 (PST)
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Subject: [PATCH] mm: Fix out-of-date comments which refers non-existent functions
Date: Wed,  9 Feb 2011 23:42:17 +0900
Message-Id: <1297262537-7425-1-git-send-email-ozaki.ryota@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

From: Ryota Ozaki <ozaki.ryota@gmail.com>

do_file_page and do_no_page don't exist anymore, but some comments
still refers them. The patch fixes them by replacing them with
existing ones.

Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
---
 mm/memory.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

I'm not familiar with the codes very much, so the fix may be wrong.

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
