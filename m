Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 635776B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 10:38:12 -0400 (EDT)
Date: Wed, 31 Aug 2011 16:37:38 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch] mm: writeback: document bdi_min_ratio
Message-ID: <20110831143738.GB19122@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org

Looks like someone got distracted after adding the comment characters.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
---
 mm/page-writeback.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0e309cd..793e987 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -305,7 +305,9 @@ static unsigned long task_min_dirty_limit(unsigned long bdi_dirty)
 }
 
 /*
- *
+ * bdi_min_ratio keeps the sum of the minimum dirty shares of all
+ * registered backing devices, which, for obvious reasons, can not
+ * exceed 100%.
  */
 static unsigned int bdi_min_ratio;
 
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
