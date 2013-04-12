Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B66BD6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:11:30 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:11:29 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 12B5138C8029
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:11:27 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1BRpf26214410
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:11:27 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1BQ2E019189
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:11:26 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH] mm/vmstat: add note on safety of drain_zonestat
Date: Thu, 11 Apr 2013 18:10:58 -0700
Message-Id: <1365729058-29514-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

---
 mm/vmstat.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1d8ed1..2b93877 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -495,6 +495,10 @@ void refresh_cpu_vm_stats(int cpu)
 			atomic_long_add(global_diff[i], &vm_stat[i]);
 }
 
+/*
+ * this is only called if !populated_zone(zone), which implies no other users of
+ * pset->vm_stat_diff[] exsist.
+ */
 void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
 {
 	int i;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
