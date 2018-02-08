Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 634C06B0006
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:09:58 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z13so4472875qth.22
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:09:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h18si609232qke.333.2018.02.08.11.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 11:09:57 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w18J7p3R143902
	for <linux-mm@kvack.org>; Thu, 8 Feb 2018 14:09:56 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2g0s8nhqg1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Feb 2018 14:09:56 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 8 Feb 2018 19:09:53 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm/zpool: zpool_evictable: fix mismatch in parameter name and kernel-doc
Date: Thu,  8 Feb 2018 21:09:44 +0200
Message-Id: <1518116984-21141-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/zpool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zpool.c b/mm/zpool.c
index f8cb83e7699b..9d53a1ef8f1e 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -360,7 +360,7 @@ u64 zpool_get_total_size(struct zpool *zpool)
 
 /**
  * zpool_evictable() - Test if zpool is potentially evictable
- * @pool	The zpool to test
+ * @zpool	The zpool to test
  *
  * Zpool is only potentially evictable when it's created with struct
  * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
