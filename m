Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3C49F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 16:00:00 -0400 (EDT)
Received: by qkep139 with SMTP id p139so1070692qke.3
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 13:00:00 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id 3si32937609qhx.74.2015.08.18.12.59.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 12:59:59 -0700 (PDT)
Received: by qgj62 with SMTP id 62so126173386qgj.2
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 12:59:58 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zpool: remove no-op module init/exit
Date: Tue, 18 Aug 2015 15:59:46 -0400
Message-Id: <1439927986-30766-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>

Remove zpool_init() and zpool_exit(); they do nothing other than
print "loaded" and "unloaded".

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zpool.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/mm/zpool.c b/mm/zpool.c
index d8cf7cd..8f670d3 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -353,20 +353,6 @@ u64 zpool_get_total_size(struct zpool *zpool)
 	return zpool->driver->total_size(zpool->pool);
 }
 
-static int __init init_zpool(void)
-{
-	pr_info("loaded\n");
-	return 0;
-}
-
-static void __exit exit_zpool(void)
-{
-	pr_info("unloaded\n");
-}
-
-module_init(init_zpool);
-module_exit(exit_zpool);
-
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Dan Streetman <ddstreet@ieee.org>");
 MODULE_DESCRIPTION("Common API for compressed memory storage");
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
