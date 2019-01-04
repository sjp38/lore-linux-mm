Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 05/25] mm, compaction: Rename map_pages to split_map_pages
Date: Fri,  4 Jan 2019 12:49:51 +0000
Message-Id: <20190104125011.16071-6-mgorman@techsingularity.net>
In-Reply-To: <20190104125011.16071-1-mgorman@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>
List-ID: <linux-mm.kvack.org>

It's non-obvious that high-order free pages are split into order-0 pages
from the function name. Fix it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/compaction.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7acb43f07303..3afa4e9188b6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -66,7 +66,7 @@ static unsigned long release_freepages(struct list_head *freelist)
 	return high_pfn;
 }
 
-static void map_pages(struct list_head *list)
+static void split_map_pages(struct list_head *list)
 {
 	unsigned int i, order, nr_pages;
 	struct page *page, *next;
@@ -644,7 +644,7 @@ isolate_freepages_range(struct compact_control *cc,
 	}
 
 	/* __isolate_free_page() does not map the pages */
-	map_pages(&freelist);
+	split_map_pages(&freelist);
 
 	if (pfn < end_pfn) {
 		/* Loop terminated early, cleanup. */
@@ -1141,7 +1141,7 @@ static void isolate_freepages(struct compact_control *cc)
 	}
 
 	/* __isolate_free_page() does not map the pages */
-	map_pages(freelist);
+	split_map_pages(freelist);
 
 	/*
 	 * Record where the free scanner will restart next time. Either we
-- 
2.16.4
