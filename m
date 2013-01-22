Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 1FCB76B000A
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 12:12:41 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/6] mm: numa: Fix minor typo in numa_next_scan
Date: Tue, 22 Jan 2013 17:12:37 +0000
Message-Id: <1358874762-19717-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1358874762-19717-1-git-send-email-mgorman@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

s/me/be/ and clarify the comment a bit when we're changing it anyway.

Suggested-by: Simon Jeons <simon.jeons@gmail.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f8f5162a..47047cb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -414,9 +414,9 @@ struct mm_struct {
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 	/*
-	 * numa_next_scan is the next time when the PTEs will me marked
-	 * pte_numa to gather statistics and migrate pages to new nodes
-	 * if necessary
+	 * numa_next_scan is the next time that the PTEs will be marked
+	 * pte_numa. NUMA hinting faults will gather statistics and migrate
+	 * pages to new nodes if necessary.
 	 */
 	unsigned long numa_next_scan;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
