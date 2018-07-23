Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E66A96B0008
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:14 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b8-v6so16709901oib.4
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 22:57:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o132-v6si5547528oih.401.2018.07.22.22.57.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jul 2018 22:57:13 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6N5s2L8060607
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:13 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kd7r4umve-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:12 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 23 Jul 2018 06:57:10 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/4] ia64: remove unused num_dma_physpages member from 'struct early_node_data'
Date: Mon, 23 Jul 2018 08:56:56 +0300
In-Reply-To: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532325418-22617-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Since commit 05e0caad3b7b ("[PATCH] Have ia64 use add_active_range() and
free_area_init_nodes") the num_dma_physpages member of 'struct
early_node_data' is calculated but never used. Remove it.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/ia64/mm/discontig.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 7d9bd20..6148ea8 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -38,9 +38,6 @@ struct early_node_data {
 	struct ia64_node_data *node_data;
 	unsigned long pernode_addr;
 	unsigned long pernode_size;
-#ifdef CONFIG_ZONE_DMA32
-	unsigned long num_dma_physpages;
-#endif
 	unsigned long min_pfn;
 	unsigned long max_pfn;
 };
@@ -669,11 +666,6 @@ static __init int count_node_pages(unsigned long start, unsigned long len, int n
 {
 	unsigned long end = start + len;
 
-#ifdef CONFIG_ZONE_DMA32
-	if (start <= __pa(MAX_DMA_ADDRESS))
-		mem_data[node].num_dma_physpages +=
-			(min(end, __pa(MAX_DMA_ADDRESS)) - start) >>PAGE_SHIFT;
-#endif
 	start = GRANULEROUNDDOWN(start);
 	end = GRANULEROUNDUP(end);
 	mem_data[node].max_pfn = max(mem_data[node].max_pfn,
-- 
2.7.4
