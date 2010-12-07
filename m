Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5DE366B008C
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 10:08:34 -0500 (EST)
Received: by iwn5 with SMTP id 5so1469iwn.14
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 07:08:33 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] compaction: Remove mem_cgroup_del_lru
Date: Wed,  8 Dec 2010 00:01:26 +0900
Message-Id: <1291734086-1405-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

del_page_from_lru_list alreay called mem_cgroup_del_lru.
So we need to call it again. It makes wrong stat of memcg and
even happen VM_BUG_ON hit.

Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 50b0a90..b0fbfdf 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -302,7 +302,6 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		/* Successfully isolated */
 		del_page_from_lru_list(zone, page, page_lru(page));
 		list_add(&page->lru, migratelist);
-		mem_cgroup_del_lru(page);
 		cc->nr_migratepages++;
 		nr_isolated++;
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
