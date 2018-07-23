Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 813996B000C
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:58:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x21-v6so158138eds.2
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:58:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u6-v6si1253392edb.381.2018.07.23.01.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 01:58:05 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6N8sOwq137388
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:58:03 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kdaueb4su-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:58:02 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 23 Jul 2018 09:58:00 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] mm/mempool: add missing parameter description
Date: Mon, 23 Jul 2018 11:57:54 +0300
Message-Id: <1532336274-26228-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The kernel-doc for mempool_init function is missing the description of the
pool parameter. Add it.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 mm/mempool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/mempool.c b/mm/mempool.c
index b54f2c2..9e16b63 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -213,6 +213,7 @@ EXPORT_SYMBOL(mempool_init_node);
 
 /**
  * mempool_init - initialize a memory pool
+ * @pool:      pointer to the memory pool that should be initialized
  * @min_nr:    the minimum number of elements guaranteed to be
  *             allocated for this pool.
  * @alloc_fn:  user-defined element-allocation function.
-- 
2.7.4
