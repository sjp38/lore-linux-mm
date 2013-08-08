Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id D10936B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:45 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/27] sched, numa: Comment fixlets
Date: Thu,  8 Aug 2013 15:00:14 +0100
Message-Id: <1375970439-5111-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Peter Zijlstra <peterz@infradead.org>

Fix a 80 column violation and a PTE vs PMD reference.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 8 ++++----
 mm/huge_memory.c    | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index bb456f4..679cfcf 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -988,10 +988,10 @@ void task_numa_work(struct callback_head *work)
 
 out:
 	/*
-	 * It is possible to reach the end of the VMA list but the last few VMAs are
-	 * not guaranteed to the vma_migratable. If they are not, we would find the
-	 * !migratable VMA on the next scan but not reset the scanner to the start
-	 * so check it now.
+	 * It is possible to reach the end of the VMA list but the last few
+	 * VMAs are not guaranteed to the vma_migratable. If they are not, we
+	 * would find the !migratable VMA on the next scan but not reset the
+	 * scanner to the start so check it now.
 	 */
 	if (vma)
 		mm->numa_scan_offset = start;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 243e710..45ef9dc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1317,7 +1317,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_unlock(&mm->page_table_lock);
 	lock_page(page);
 
-	/* Confirm the PTE did not while locked */
+	/* Confirm the PMD did not change while page_table_lock was released */
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		unlock_page(page);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
