Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD196B0038
	for <linux-mm@kvack.org>; Sat, 29 Aug 2015 03:37:40 -0400 (EDT)
Received: by padhm10 with SMTP id hm10so29485621pad.3
        for <linux-mm@kvack.org>; Sat, 29 Aug 2015 00:37:40 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id qv6si13997572pbb.35.2015.08.29.00.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 29 Aug 2015 00:37:39 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH 1/1] mm: fix type information of memoryless node
Date: Sat, 29 Aug 2015 15:34:45 +0800
Message-ID: <1440833685-32372-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir
 Davydov <vdavydov@parallels.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

For a memoryless node, the output of get_pfn_range_for_nid are all zero.
It will display mem from 0 to -1.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b5240b..5839f31 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5455,7 +5455,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 	pr_info("Initmem setup node %d [mem %#018Lx-%#018Lx]\n", nid,
-		(u64)start_pfn << PAGE_SHIFT, ((u64)end_pfn << PAGE_SHIFT) - 1);
+		(u64)start_pfn << PAGE_SHIFT,
+		end_pfn ? ((u64)end_pfn << PAGE_SHIFT) - 1 : 0);
 #endif
 	calculate_node_totalpages(pgdat, start_pfn, end_pfn,
 				  zones_size, zholes_size);
--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
