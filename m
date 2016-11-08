Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D54D6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 23:49:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so61945657pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 20:49:19 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id i4si29071853paf.279.2016.11.07.20.40.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 20:40:15 -0800 (PST)
Received: from epcpsbgm2new.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OGB02W7S3N1RRE0@mailout2.samsung.com> for linux-mm@kvack.org;
 Tue, 08 Nov 2016 13:40:13 +0900 (KST)
From: Ashish Kalra <ashish.kalra@samsung.com>
Subject: [PATCH] mm: dmapool: Fixed following warnings
Date: Tue, 08 Nov 2016 10:07:52 +0530
Message-id: <1478579872-881-1-git-send-email-ashish.kalra@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Joe Perches <joe@perches.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ashish Kalra <ashish.kalra@samsung.com>, shailesh pandey <p.shailesh@samsung.com>, vidushi.koul@samsung.com

From: AshishKalra <ashish.kalra@samsung.com>

WARNING: Prefer 'unsigned int' to bare use of 'unsigned'
WARNING: Symbolic permissions 'S_IRUGO' are not preferred. Consider using octal permissions '0444'.
WARNING: Missing a blank line after declarations
Warning were detected with checkpatch.pl

Signed-off-by: AshishKalra <ashish.kalra@samsung.com>
---
 mm/dmapool.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index abcbfe8..9fde077 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -67,8 +67,8 @@ struct dma_page {		/* cacheable header for 'allocation' bytes */
 static ssize_t
 show_pools(struct device *dev, struct device_attribute *attr, char *buf)
 {
-	unsigned temp;
-	unsigned size;
+	unsigned int temp;
+	unsigned int size;
 	char *next;
 	struct dma_page *page;
 	struct dma_pool *pool;
@@ -82,8 +82,8 @@ struct dma_page {		/* cacheable header for 'allocation' bytes */
 
 	mutex_lock(&pools_lock);
 	list_for_each_entry(pool, &dev->dma_pools, pools) {
-		unsigned pages = 0;
-		unsigned blocks = 0;
+		unsigned int pages = 0;
+		unsigned int blocks = 0;
 
 		spin_lock_irq(&pool->lock);
 		list_for_each_entry(page, &pool->page_list, page_list) {
@@ -105,7 +105,7 @@ struct dma_page {		/* cacheable header for 'allocation' bytes */
 	return PAGE_SIZE - size;
 }
 
-static DEVICE_ATTR(pools, S_IRUGO, show_pools, NULL);
+static DEVICE_ATTR(pools, 0444, show_pools, NULL);
 
 /**
  * dma_pool_create - Creates a pool of consistent memory blocks, for dma.
@@ -210,6 +210,7 @@ static void pool_initialise_page(struct dma_pool *pool, struct dma_page *page)
 
 	do {
 		unsigned int next = offset + pool->size;
+
 		if (unlikely((next + pool->size) >= next_boundary)) {
 			next = next_boundary;
 			next_boundary += pool->boundary;
@@ -286,6 +287,7 @@ void dma_pool_destroy(struct dma_pool *pool)
 
 	while (!list_empty(&pool->page_list)) {
 		struct dma_page *page;
+
 		page = list_entry(pool->page_list.next,
 				  struct dma_page, page_list);
 		if (is_page_busy(page)) {
@@ -443,6 +445,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 	}
 	{
 		unsigned int chain = page->offset;
+
 		while (chain < pool->allocation) {
 			if (chain != offset) {
 				chain = *(int *)(page->vaddr + chain);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
