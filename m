Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78C776B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 01:30:50 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id b202so347591764oii.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 22:30:50 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0085.outbound.protection.outlook.com. [104.47.2.85])
        by mx.google.com with ESMTPS id v66si30448679oif.296.2016.11.29.22.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 22:30:49 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH extra ] mm: hugetlb: add description for alloc_gigantic_page()
Date: Wed, 30 Nov 2016 14:30:31 +0800
Message-ID: <1480487431-26181-1-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, vbabka@suze.cz, Huang Shijie <shijie.huang@arm.com>

This patch adds the description for function alloc_gigantic_page().

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3faec05..0d4bb8a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1089,6 +1089,12 @@ static bool zone_spans_last_pfn(const struct zone *zone,
 	return zone_spans_pfn(zone, last_pfn);
 }
 
+/*
+ * Allocate a gigantic page from @nid node.
+ *
+ * Scan the zones of @nid node, and try to allocate a number of contiguous
+ * pages (1 << order).
+ */
 static struct page *alloc_gigantic_page(int nid, unsigned int order)
 {
 	unsigned long nr_pages = 1 << order;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
