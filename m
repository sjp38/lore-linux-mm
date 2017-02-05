Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 703DC6B026F
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:36 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id i34so31200473qkh.6
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:36 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id n72si18806895qke.210.2017.02.05.08.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:35 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 14/14] mm: memory_hotplug: memory hotremove supports thp migration
Date: Sun,  5 Feb 2017 11:12:52 -0500
Message-Id: <20170205161252.85004-15-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

This patch enables thp migration for memory hotremove.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
ChangeLog v1->v2:
- base code switched from alloc_migrate_target to new_node_page()
---
 mm/memory_hotplug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9cb4c83151a8..e988ea15cc99 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1593,10 +1593,10 @@ static struct page *new_node_page(struct page *page, unsigned long private,
 		gfp_mask |= __GFP_HIGHMEM;
 
 	if (!nodes_empty(nmask))
-		new_page = __alloc_pages_nodemask(gfp_mask, 0,
+		new_page = __alloc_pages_nodemask(gfp_mask, order,
 					node_zonelist(nid, gfp_mask), &nmask);
 	if (!new_page)
-		new_page = __alloc_pages(gfp_mask, 0,
+		new_page = __alloc_pages(gfp_mask, order,
 					node_zonelist(nid, gfp_mask));
 
 	if (new_page && order == hpage_order(page))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
