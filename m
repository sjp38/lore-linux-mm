Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 39E636B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 09:23:05 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3135917dak.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 06:23:04 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm: complement page reclaim comment
Date: Thu, 14 Jun 2012 21:22:38 +0800
Message-Id: <1339680158-26657-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, trivial@kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/vmscan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ed823df..603c96f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3203,6 +3203,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
  * Reasons page might not be evictable:
  * (1) page's mapping marked unevictable
  * (2) page is part of an mlocked VMA
+ * (3) page mapped into SHM_LOCK'd shared memory regions
  *
  */
 int page_evictable(struct page *page, struct vm_area_struct *vma)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
