Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DC2986B0024
	for <linux-mm@kvack.org>; Fri,  6 May 2011 07:33:18 -0400 (EDT)
Received: by pxi9 with SMTP id 9so2289104pxi.14
        for <linux-mm@kvack.org>; Fri, 06 May 2011 04:33:17 -0700 (PDT)
Subject: [PATCH]mm/compation.c: checking page in lru twice
From: "Figo.zhang" <figo1802@gmail.com>
Date: Fri, 06 May 2011 19:32:46 +0800
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1304681575.15473.4.camel@figo-desktop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, mel@csn.ul.ie
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, kamezawa.hiroyu@jp.fujisu.com, minchan.kim@gmail.com, Andrew Morton <akpm@osdl.org>, aarcange@redhat.com


in isolate_migratepages() have check page in LRU twice, the next one
at _isolate_lru_page(). 

Signed-off-by: Figo.zhang <figo1802@gmail.com> 
---

mm/compaction.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..ac605cb 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -321,9 +321,6 @@ static unsigned long isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
-		if (!PageLRU(page))
-			continue;
-
 		/*
 		 * PageLRU is set, and lru_lock excludes isolation,
 		 * splitting and collapsing (collapsing has already


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
