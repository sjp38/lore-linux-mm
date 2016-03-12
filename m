Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 050496B0005
	for <linux-mm@kvack.org>; Sat, 12 Mar 2016 03:05:19 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id x3so6167939pfb.1
        for <linux-mm@kvack.org>; Sat, 12 Mar 2016 00:05:18 -0800 (PST)
Received: from lucky1.263xmail.com (lucky1.263xmail.com. [211.157.147.133])
        by mx.google.com with ESMTP id tj5si7366901pab.33.2016.03.12.00.05.17
        for <linux-mm@kvack.org>;
        Sat, 12 Mar 2016 00:05:18 -0800 (PST)
From: Shawn Lin <shawn.lin@rock-chips.com>
Subject: [PATCH] mm/vmalloc: reuse PAGE_ALIGNED to check PAGE_SIZE aligned
Date: Sat, 12 Mar 2016 15:55:44 +0800
Message-Id: <1457769344-31275-1-git-send-email-shawn.lin@rock-chips.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Roman Pen <r.peniaev@gmail.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Shawn Lin <shawn.lin@rock-chips.com>

we have defined PAGE_ALIGNED in mm.h, so let's use it instead of
IS_ALIGNED for checking PAGE_SIZE aligned case.

Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
---

 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e86c24e..ae7d20b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1085,7 +1085,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	BUG_ON(!addr);
 	BUG_ON(addr < VMALLOC_START);
 	BUG_ON(addr > VMALLOC_END);
-	BUG_ON(!IS_ALIGNED(addr, PAGE_SIZE));
+	BUG_ON(!PAGE_ALIGNED(addr));
 
 	debug_check_no_locks_freed(mem, size);
 	vmap_debug_free_range(addr, addr+size);
-- 
2.3.7


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
