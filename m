Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 44CAB82F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:32:39 -0500 (EST)
Received: by pacej9 with SMTP id ej9so45306394pac.2
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:32:39 -0800 (PST)
Received: from m50-138.163.com (m50-138.163.com. [123.125.50.138])
        by mx.google.com with ESMTP id pp8si4510489pbb.200.2015.11.18.05.32.37
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 05:32:38 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] memory-hotplug: use PFN_DOWN in should_add_memory_movable
Date: Wed, 18 Nov 2015 21:31:32 +0800
Message-Id: <a8c9ad77b0a3bebb49110b70e1aecb79e54ad49d.1447853330.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Vrabel <david.vrabel@citrix.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use PFN_DOWN() in should_add_memory_movable() to keep the consistency
of this file.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 67d488a..7c44ff7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1205,7 +1205,7 @@ static int check_hotplug_memory_range(u64 start, u64 size)
  */
 static int should_add_memory_movable(int nid, u64 start, u64 size)
 {
-	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long start_pfn = PFN_DOWN(start);
 	pg_data_t *pgdat = NODE_DATA(nid);
 	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
 
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
