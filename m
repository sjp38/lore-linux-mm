Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1D1906B003A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:28:55 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 9 Apr 2013 17:28:54 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2CB9919D804A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:28:48 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39NSqUa124576
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 17:28:52 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39NSpAj007277
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 17:28:52 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 07/10] mm/page_alloc: relocate comment to be directly above code it refers to.
Date: Tue,  9 Apr 2013 16:28:16 -0700
Message-Id: <1365550099-6795-8-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2f2207..6e52e67 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3680,12 +3680,12 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 		mminit_verify_zonelist();
 		cpuset_init_current_mems_allowed();
 	} else {
-		/* we have to stop all cpus to guarantee there is no user
-		   of zonelist */
 #ifdef CONFIG_MEMORY_HOTPLUG
 		if (zone)
 			setup_zone_pageset(zone);
 #endif
+		/* we have to stop all cpus to guarantee there is no user
+		   of zonelist */
 		stop_machine(__build_all_zonelists, pgdat, NULL);
 		/* cpuset refresh routine should be here */
 	}
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
