Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9F84F6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 06:57:13 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 2/2] mm: tlb_fast_mode check missing in tlb_finish_mmu()
Date: Fri, 31 May 2013 16:23:50 +0530
Message-ID: <1369997630-6522-3-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1369997630-6522-1-git-send-email-vgupta@synopsys.com>
References: <1369997630-6522-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>, Vineet  Gupta <Vineet.Gupta1@synopsys.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>

This removes some unused generated code for tlb_fast_mode() == true

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org <linux-arch@vger.kernel.org>
---
 mm/memory.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index d9d5fd9..569ffe1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -269,6 +269,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
 
+	if (tlb_fast_mode(tlb))
+		return;
+
 	for (batch = tlb->local.next; batch; batch = next) {
 		next = batch->next;
 		free_pages((unsigned long)batch, 0);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
