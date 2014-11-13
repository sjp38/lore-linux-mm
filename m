Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1FF6B00DC
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 22:08:52 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id w7so10255058qcr.26
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 19:08:52 -0800 (PST)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id v77si15156478qgd.45.2014.11.12.19.08.51
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 19:08:51 -0800 (PST)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id CA867101383
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 22:08:47 -0500 (EST)
From: Seth Jennings <sjennings@variantweb.net>
Subject: [PATCH] zbud, zswap: change module author email
Date: Wed, 12 Nov 2014 21:08:46 -0600
Message-Id: <1415848126-9775-1-git-send-email-sjennings@variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, trivial@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Old email no longer viable.

Signed-off-by: Seth Jennings <sjennings@variantweb.net>
---
 mm/zbud.c  | 2 +-
 mm/zswap.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/zbud.c b/mm/zbud.c
index db8de74..4e387be 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -619,5 +619,5 @@ module_init(init_zbud);
 module_exit(exit_zbud);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
+MODULE_AUTHOR("Seth Jennings <sjennings@variantweb.net>");
 MODULE_DESCRIPTION("Buddy Allocator for Compressed Pages");
diff --git a/mm/zswap.c b/mm/zswap.c
index ea064c1..c154306 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -951,5 +951,5 @@ error:
 late_initcall(init_zswap);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
+MODULE_AUTHOR("Seth Jennings <sjennings@variantweb.net>");
 MODULE_DESCRIPTION("Compressed cache for swap pages");
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
