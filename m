Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD6FB6B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 13:12:35 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e1-v6so8438406pld.23
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:12:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t15-v6sor2698834pgu.388.2018.06.25.10.12.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 10:12:34 -0700 (PDT)
From: Athira-Selvan <thisisathi@gmail.com>
Subject: [PATCH] mm:mempool:fixed coding style errors and warnings.
Date: Mon, 25 Jun 2018 22:42:17 +0530
Message-Id: <1529946737-7693-1-git-send-email-thisisathi@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: jthumshirn@suse.de, tglx@linutronix.de, kent.overstreet@gmail.com, linux-mm@kvack.org, thisisathi@gmail.com

This patch fixes checkpatch.pl:
WARNING: Missing a blank line after declarations
ERROR: missing space brfore ','

Signed-off-by: Athira Selvam <thisisathi@gmail.com>
---
 mm/mempool.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/mempool.c b/mm/mempool.c
index b54f2c2..c3a7b7b 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -152,6 +152,7 @@ void mempool_exit(mempool_t *pool)
 {
 	while (pool->curr_nr) {
 		void *element = remove_element(pool, GFP_KERNEL);
+
 		pool->free(element, pool->pool_data);
 	}
 	kfree(pool->elements);
@@ -248,7 +249,7 @@ EXPORT_SYMBOL(mempool_init);
 mempool_t *mempool_create(int min_nr, mempool_alloc_t *alloc_fn,
 				mempool_free_t *free_fn, void *pool_data)
 {
-	return mempool_create_node(min_nr,alloc_fn,free_fn, pool_data,
+	return mempool_create_node(min_nr, alloc_fn, free_fn, pool_data,
 				   GFP_KERNEL, NUMA_NO_NODE);
 }
 EXPORT_SYMBOL(mempool_create);
@@ -500,6 +501,7 @@ EXPORT_SYMBOL(mempool_free);
 void *mempool_alloc_slab(gfp_t gfp_mask, void *pool_data)
 {
 	struct kmem_cache *mem = pool_data;
+
 	VM_BUG_ON(mem->ctor);
 	return kmem_cache_alloc(mem, gfp_mask);
 }
@@ -508,6 +510,7 @@ EXPORT_SYMBOL(mempool_alloc_slab);
 void mempool_free_slab(void *element, void *pool_data)
 {
 	struct kmem_cache *mem = pool_data;
+
 	kmem_cache_free(mem, element);
 }
 EXPORT_SYMBOL(mempool_free_slab);
@@ -519,6 +522,7 @@ EXPORT_SYMBOL(mempool_free_slab);
 void *mempool_kmalloc(gfp_t gfp_mask, void *pool_data)
 {
 	size_t size = (size_t)pool_data;
+
 	return kmalloc(size, gfp_mask);
 }
 EXPORT_SYMBOL(mempool_kmalloc);
@@ -536,6 +540,7 @@ EXPORT_SYMBOL(mempool_kfree);
 void *mempool_alloc_pages(gfp_t gfp_mask, void *pool_data)
 {
 	int order = (int)(long)pool_data;
+
 	return alloc_pages(gfp_mask, order);
 }
 EXPORT_SYMBOL(mempool_alloc_pages);
@@ -543,6 +548,7 @@ EXPORT_SYMBOL(mempool_alloc_pages);
 void mempool_free_pages(void *element, void *pool_data)
 {
 	int order = (int)(long)pool_data;
+
 	__free_pages(element, order);
 }
 EXPORT_SYMBOL(mempool_free_pages);
-- 
2.7.4
