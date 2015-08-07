Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C87DA6B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:15:40 -0400 (EDT)
Received: by pawu10 with SMTP id u10so89820905paw.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:15:40 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id em1si17764367pbd.90.2015.08.07.07.15.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 07:15:39 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSP00S8KUA0LBB0@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 07 Aug 2015 23:15:36 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH 1/1] mm: compaction: include compact_nodes in compaction.h
Date: Fri, 07 Aug 2015 19:33:53 +0530
Message-id: <1438956233-28690-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.cz, riel@redhat.com, emunson@akamai.com, mgorman@suse.de, zhangyanfei@cn.fujitsu.com, rientjes@google.com, pintu.k@samsung.com
Cc: cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

This patch declares compact_nodes prototype in compaction.h
header file.
This will allow us to call compaction from other places.
For example, during system suspend, suppose we want to check
the fragmentation state of the system. Then based on certain
threshold, we can invoke compaction, when system is idle.
There could be other use cases.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 include/linux/compaction.h |    2 +-
 mm/compaction.c            |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index aa8f61c..800ff50 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -50,7 +50,7 @@ extern bool compaction_deferred(struct zone *zone, int order);
 extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
 extern bool compaction_restarting(struct zone *zone, int order);
-
+extern void compact_nodes(void);
 #else
 static inline unsigned long try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order, int alloc_flags,
diff --git a/mm/compaction.c b/mm/compaction.c
index 16e1b57..b793922 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1657,7 +1657,7 @@ static void compact_node(int nid)
 }
 
 /* Compact all nodes in the system */
-static void compact_nodes(void)
+void compact_nodes(void)
 {
 	int nid;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
