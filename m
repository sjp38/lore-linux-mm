Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 173756B0389
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 05:00:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z67so125523502pgb.0
        for <linux-mm@kvack.org>; Sun, 19 Feb 2017 02:00:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r17si5306744pgh.258.2017.02.19.02.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Feb 2017 02:00:12 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1J9sL32050308
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 05:00:11 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28pmkwh12p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 19 Feb 2017 05:00:11 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 19 Feb 2017 05:00:10 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/thp/autonuma: Use TNF flag instead of vm fault.
Date: Sun, 19 Feb 2017 15:29:55 +0530
Message-Id: <1487498395-9544-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We are using wrong flag value in task_numa_falt function. This can result in
us doing wrong numa fault statistics update, because we update num_pages_migrate
and numa_fault_locality etc based on the flag argument passed.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5f3ad65c85de..8f1d93257fb9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1333,7 +1333,7 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 
 	if (page_nid != -1)
 		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR,
-				vmf->flags);
+				flags);
 
 	return 0;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
