Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A97016B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 04:36:30 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kq14so3571020pab.37
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 01:36:30 -0800 (PST)
Received: from mail-pb0-x22f.google.com (mail-pb0-x22f.google.com [2607:f8b0:400e:c01::22f])
        by mx.google.com with ESMTPS id ra2si10027951pab.153.2014.03.03.01.36.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 01:36:29 -0800 (PST)
Received: by mail-pb0-f47.google.com with SMTP id up15so3538057pbc.20
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 01:36:28 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH] mm: zswap: remove unnecessary parentheses
Date: Mon,  3 Mar 2014 18:37:56 +0900
Message-Id: <1393839476-24989-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

Fix following trivial checkpatch error:
	ERROR: return is not a function, parentheses are not required

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/zswap.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index c0c9b7c..34b75cc 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -204,7 +204,7 @@ static struct kmem_cache *zswap_entry_cache;
 static int zswap_entry_cache_create(void)
 {
 	zswap_entry_cache = KMEM_CACHE(zswap_entry, 0);
-	return (zswap_entry_cache == NULL);
+	return zswap_entry_cache == NULL;
 }
 
 static void zswap_entry_cache_destory(void)
@@ -408,8 +408,8 @@ cleanup:
 **********************************/
 static bool zswap_is_full(void)
 {
-	return (totalram_pages * zswap_max_pool_percent / 100 <
-		zswap_pool_pages);
+	return totalram_pages * zswap_max_pool_percent / 100 <
+		zswap_pool_pages;
 }
 
 /*********************************
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
