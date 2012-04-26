Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A42BD6B00E7
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:54:11 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id gg6so999112lbb.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:54:11 -0700 (PDT)
Subject: [PATCH 05/12] mm/vmscan: push zone pointer into
 update_isolated_counts()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:54:08 +0400
Message-ID: <20120426075408.18961.80580.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

ditto

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/vmscan.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 44d5821..814948ad9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1206,12 +1206,11 @@ putback_inactive_pages(struct mem_cgroup_zone *mz,
 }
 
 static noinline_for_stack void
-update_isolated_counts(struct mem_cgroup_zone *mz,
+update_isolated_counts(struct zone *zone,
 		       struct list_head *page_list,
 		       unsigned long *nr_anon,
 		       unsigned long *nr_file)
 {
-	struct zone *zone = mz->zone;
 	unsigned int count[NR_LRU_LISTS] = { 0, };
 	unsigned long nr_active = 0;
 	struct page *page;
@@ -1306,7 +1305,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	if (nr_taken == 0)
 		return 0;
 
-	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);
+	update_isolated_counts(zone, &page_list, &nr_anon, &nr_file);
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
 						&nr_dirty, &nr_writeback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
