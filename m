Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 55E7A6B0068
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:09:21 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 13 May 2013 15:09:20 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 44161C90045
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:09:18 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DJ9IP1199918
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:09:18 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DJ98Ze016084
	for <linux-mm@kvack.org>; Mon, 13 May 2013 15:09:09 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH RESEND v3 08/11] mm/page_alloc: relocate comment to be directly above code it refers to.
Date: Mon, 13 May 2013 12:08:20 -0700
Message-Id: <1368472103-3427-9-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1368472103-3427-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 696ce96..53c62c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3709,12 +3709,12 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
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
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
