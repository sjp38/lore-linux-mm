Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 292286B0248
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:30 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id um1so810998pbc.36
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:29 -0800 (PST)
Received: from psmtp.com ([74.125.245.195])
        by mx.google.com with SMTP id gn4si8108426pbc.21.2013.11.08.15.43.28
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:28 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 20/24] mm/memory_hotplug: Use memblock apis for early memory allocations
Date: Fri, 8 Nov 2013 18:41:56 -0500
Message-ID: <1383954120-24368-21-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Correct ensure_zone_is_initialized() function description according
to the introduced memblock APIs for early memory allocations.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f7bda5e..3ffe114 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -267,7 +267,7 @@ static void fix_zone_id(struct zone *zone, unsigned long start_pfn,
 }
 
 /* Can fail with -ENOMEM from allocating a wait table with vmalloc() or
- * alloc_bootmem_node_nopanic() */
+ * alloc_bootmem_node_nopanic()/memblock_virt_alloc_node_nopanic() */
 static int __ref ensure_zone_is_initialized(struct zone *zone,
 			unsigned long start_pfn, unsigned long num_pages)
 {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
