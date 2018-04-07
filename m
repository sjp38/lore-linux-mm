Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FB416B0011
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 14:47:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i4so2871460wrh.4
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 11:47:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p54sor6780646edc.22.2018.04.07.11.47.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Apr 2018 11:47:54 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 1/3] mm: replace S_IRUGO with 0444
Date: Sat,  7 Apr 2018 19:47:24 +0100
Message-Id: <20180407184726.8634-1-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: konrad.wilk@oracle.com, labbott@redhat.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, guptap@codeaurora.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, rientjes@google.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, dave@stgolabs.net, hmclauchlan@fb.com, tglx@linutronix.de, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Fix checkpatch warnings about S_IRUGO being less readable than
providing the permissions octal as '0444'.

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/cleancache.c |  8 ++++----
 mm/cma_debug.c  | 12 ++++++------
 mm/dmapool.c    |  2 +-
 mm/frontswap.c  |  8 ++++----
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/mm/cleancache.c b/mm/cleancache.c
index f7b9fdc79d97..90d259e69496 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -307,11 +307,11 @@ static int __init init_cleancache(void)
 	struct dentry *root = debugfs_create_dir("cleancache", NULL);
 	if (root == NULL)
 		return -ENXIO;
-	debugfs_create_u64("succ_gets", S_IRUGO, root, &cleancache_succ_gets);
-	debugfs_create_u64("failed_gets", S_IRUGO,
+	debugfs_create_u64("succ_gets", 0444, root, &cleancache_succ_gets);
+	debugfs_create_u64("failed_gets", 0444,
 				root, &cleancache_failed_gets);
-	debugfs_create_u64("puts", S_IRUGO, root, &cleancache_puts);
-	debugfs_create_u64("invalidates", S_IRUGO,
+	debugfs_create_u64("puts", 0444, root, &cleancache_puts);
+	debugfs_create_u64("invalidates", 0444,
 				root, &cleancache_invalidates);
 #endif
 	return 0;
diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 275df8b5b22e..6494c7a7d257 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -178,17 +178,17 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 	debugfs_create_file("free", S_IWUSR, tmp, cma,
 				&cma_free_fops);
 
-	debugfs_create_file("base_pfn", S_IRUGO, tmp,
+	debugfs_create_file("base_pfn", 0444, tmp,
 				&cma->base_pfn, &cma_debugfs_fops);
-	debugfs_create_file("count", S_IRUGO, tmp,
+	debugfs_create_file("count", 0444, tmp,
 				&cma->count, &cma_debugfs_fops);
-	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
+	debugfs_create_file("order_per_bit", 0444, tmp,
 				&cma->order_per_bit, &cma_debugfs_fops);
-	debugfs_create_file("used", S_IRUGO, tmp, cma, &cma_used_fops);
-	debugfs_create_file("maxchunk", S_IRUGO, tmp, cma, &cma_maxchunk_fops);
+	debugfs_create_file("used", 0444, tmp, cma, &cma_used_fops);
+	debugfs_create_file("maxchunk", 0444, tmp, cma, &cma_maxchunk_fops);
 
 	u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
-	debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
+	debugfs_create_u32_array("bitmap", 0444, tmp, (u32 *)cma->bitmap, u32s);
 }
 
 static int __init cma_debugfs_init(void)
diff --git a/mm/dmapool.c b/mm/dmapool.c
index 4d90a64b2fdc..6d4b97e7e9e9 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -105,7 +105,7 @@ show_pools(struct device *dev, struct device_attribute *attr, char *buf)
 	return PAGE_SIZE - size;
 }
 
-static DEVICE_ATTR(pools, S_IRUGO, show_pools, NULL);
+static DEVICE_ATTR(pools, 0444, show_pools, NULL);
 
 /**
  * dma_pool_create - Creates a pool of consistent memory blocks, for dma.
diff --git a/mm/frontswap.c b/mm/frontswap.c
index fec8b5044040..3b41425d34cd 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -486,11 +486,11 @@ static int __init init_frontswap(void)
 	struct dentry *root = debugfs_create_dir("frontswap", NULL);
 	if (root == NULL)
 		return -ENXIO;
-	debugfs_create_u64("loads", S_IRUGO, root, &frontswap_loads);
-	debugfs_create_u64("succ_stores", S_IRUGO, root, &frontswap_succ_stores);
-	debugfs_create_u64("failed_stores", S_IRUGO, root,
+	debugfs_create_u64("loads", 0444, root, &frontswap_loads);
+	debugfs_create_u64("succ_stores", 0444, root, &frontswap_succ_stores);
+	debugfs_create_u64("failed_stores", 0444, root,
 				&frontswap_failed_stores);
-	debugfs_create_u64("invalidates", S_IRUGO,
+	debugfs_create_u64("invalidates", 0444,
 				root, &frontswap_invalidates);
 #endif
 	return 0;
-- 
2.16.2
