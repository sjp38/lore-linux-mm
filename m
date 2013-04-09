Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 1B44E6B005C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:29:01 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 9 Apr 2013 17:29:00 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5394E3E40039
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:28:44 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39NSu1K366872
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 17:28:56 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39NSuGM007899
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 17:28:56 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 10/10] mm/page_alloc: rename setup_pagelist_highmark() to match naming of pageset_set_batch()
Date: Tue,  9 Apr 2013 16:28:19 -0700
Message-Id: <1365550099-6795-11-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 334387e..66b8bc2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4018,7 +4018,7 @@ static void pageset_update_prep(struct per_cpu_pages *pcp)
 	smp_wmb();
 }
 
-/* a companion to setup_pagelist_highmark() */
+/* a companion to pageset_set_high() */
 static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp = &p->pcp;
@@ -4050,10 +4050,10 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 }
 
 /*
- * setup_pagelist_highmark() sets the high water mark for hot per_cpu_pagelist
+ * pageset_set_high() sets the high water mark for hot per_cpu_pagelist
  * to the value high for the pageset p.
  */
-static void setup_pagelist_highmark(struct per_cpu_pageset *p,
+static void pageset_set_high(struct per_cpu_pageset *p,
 				unsigned long high)
 {
 	struct per_cpu_pages *pcp;
@@ -4075,7 +4075,7 @@ static void __meminit zone_pageset_init(struct zone *zone, int cpu)
 
 	pageset_init(pcp);
 	if (percpu_pagelist_fraction)
-		setup_pagelist_highmark(pcp,
+		pageset_set_high(pcp,
 			(zone->managed_pages /
 				percpu_pagelist_fraction));
 	else
@@ -5526,8 +5526,8 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 		unsigned long  high;
 		high = zone->managed_pages / percpu_pagelist_fraction;
 		for_each_possible_cpu(cpu)
-			setup_pagelist_highmark(
-					per_cpu_ptr(zone->pageset, cpu), high);
+			pageset_set_high(per_cpu_ptr(zone->pageset, cpu),
+					 high);
 	}
 	mutex_unlock(&pcp_batch_high_lock);
 	return 0;
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
