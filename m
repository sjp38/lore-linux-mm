Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1766C6B0075
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 15:32:34 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so1749262pdj.30
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:32:33 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id il1si213436pbb.73.2014.07.16.12.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 12:32:33 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so1854917pab.40
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 12:32:32 -0700 (PDT)
Date: Wed, 16 Jul 2014 12:30:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: remove the unused gfp arg to shmem_add_to_page_cache
In-Reply-To: <1405475324-13567-1-git-send-email-shhuiw@gmail.com>
Message-ID: <alpine.LSU.2.11.1407161224100.3872@eggly.anvils>
References: <1405475324-13567-1-git-send-email-shhuiw@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

From: Wang Sheng-Hui <shhuiw@gmail.com>

The gfp arg is not used in shmem_add_to_page_cache.
Remove this unused arg.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
Yes, this version was fine: thank you.
Andrew, please add to mmotm (no hurry) - thank you.

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
