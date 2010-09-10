Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 249F46B007B
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 00:25:39 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/4] hugetlb, rmap: add BUG_ON(!PageLocked) in hugetlb_add_anon_rmap()
Date: Fri, 10 Sep 2010 13:23:06 +0900
Message-Id: <1284092586-1179-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Confirming page lock is held in hugetlb_add_anon_rmap() may be useful
to detect possible future problems.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/rmap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git v2.6.36-rc3/mm/rmap.c v2.6.36-rc3/mm/rmap.c
index 2854857..9d2ba01 100644
--- v2.6.36-rc3/mm/rmap.c
+++ v2.6.36-rc3/mm/rmap.c
@@ -1582,6 +1582,8 @@ void hugepage_add_anon_rmap(struct page *page,
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	int first;
+
+	BUG_ON(!PageLocked(page));
 	BUG_ON(!anon_vma);
 	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	first = atomic_inc_and_test(&page->_mapcount);
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
