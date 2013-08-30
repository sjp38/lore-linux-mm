Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C1AFF6B003D
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 10:07:36 -0400 (EDT)
From: Jerome Marchand <jmarchan@redhat.com>
Subject: [PATCH] mm: compaction: update comment about zone lock in isolate_freepages_block
Date: Fri, 30 Aug 2013 16:07:28 +0200
Message-Id: <1377871648-9930-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de

Since commit f40d1e4 (mm: compaction: acquire the zone->lock as late as
possible), isolate_freepages_block() takes the zone->lock itself. The
function description however still states that the zone->lock must be
held.
This patch removes this outdated statement.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 mm/compaction.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 05ccb4c..9f9026f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -235,10 +235,9 @@ static bool suitable_migration_target(struct page *page)
 }
 
 /*
- * Isolate free pages onto a private freelist. Caller must hold zone->lock.
- * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
- * pages inside of the pageblock (even though it may still end up isolating
- * some pages).
+ * Isolate free pages onto a private freelist. If @strict is true, will abort
+ * returning 0 on any invalid PFNs or non-free pages inside of the pageblock
+ * (even though it may still end up isolating some pages).
  */
 static unsigned long isolate_freepages_block(struct compact_control *cc,
 				unsigned long blockpfn,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
