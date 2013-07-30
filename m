Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id F3BF96B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 02:49:22 -0400 (EDT)
Message-ID: <51F761E7.5090403@huawei.com>
Date: Tue, 30 Jul 2013 14:49:11 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hotplug: remove unnecessary BUG_ON in __offline_pages()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

I think we can remove "BUG_ON(start_pfn >= end_pfn)" in __offline_pages(),
because in memory_block_action() "nr_pages = PAGES_PER_SECTION * sections_per_block" 
is always greater than 0.

memory_block_action()
	offline_pages()
		__offline_pages()
			BUG_ON(start_pfn >= end_pfn)

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ca1dd3a..8e333f9 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1472,7 +1472,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	struct zone *zone;
 	struct memory_notify arg;
 
-	BUG_ON(start_pfn >= end_pfn);
 	/* at least, alignment against pageblock is necessary */
 	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
 		return -EINVAL;
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
