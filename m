Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9113F6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 21:48:58 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so316975pdi.11
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 18:48:58 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id dl2si13136111pbc.108.2014.07.15.18.48.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 18:48:57 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so341629pad.0
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 18:48:57 -0700 (PDT)
From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: [PATCH] mm: remove the unused gfp arg to shmem_add_to_page_cache
Date: Wed, 16 Jul 2014 09:48:44 +0800
Message-Id: <1405475324-13567-1-git-send-email-shhuiw@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: linux-mm@kvack.org

The gfp arg is not used in shmem_add_to_page_cache.
Remove this unused arg.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/shmem.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 1140f49..63cc6af 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -280,7 +280,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
  */
 static int shmem_add_to_page_cache(struct page *page,
 				   struct address_space *mapping,
-				   pgoff_t index, gfp_t gfp, void *expected)
+				   pgoff_t index, void *expected)
 {
 	int error;
 
@@ -643,7 +643,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 	 */
 	if (!error)
 		error = shmem_add_to_page_cache(*pagep, mapping, index,
-						GFP_NOWAIT, radswap);
+						radswap);
 	if (error != -ENOMEM) {
 		/*
 		 * Truncation and eviction use free_swap_and_cache(), which
@@ -1089,7 +1089,7 @@ repeat:
 						gfp & GFP_RECLAIM_MASK);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
-						gfp, swp_to_radix_entry(swap));
+						swp_to_radix_entry(swap));
 			/*
 			 * We already confirmed swap under page lock, and make
 			 * no memory allocation here, so usually no possibility
@@ -1152,7 +1152,7 @@ repeat:
 		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
-							gfp, NULL);
+							NULL);
 			radix_tree_preload_end();
 		}
 		if (error) {
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
