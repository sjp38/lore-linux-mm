Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBD526B0288
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d64-v6so6688949pfd.13
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b5-v6si11944166ple.417.2018.06.16.19.01.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:18 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 56/74] shmem: Comment fixups
Date: Sat, 16 Jun 2018 19:00:34 -0700
Message-Id: <20180617020052.4759-57-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Remove the last mentions of radix tree from various comments.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/shmem.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index bffb87854852..5f14acf95eff 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -766,7 +766,7 @@ void shmem_unlock_mapping(struct address_space *mapping)
 }
 
 /*
- * Remove range of pages and swap entries from radix tree, and free them.
+ * Remove range of pages and swap entries from page cache, and free them.
  * If !unfalloc, truncate or punch hole; if unfalloc, undo failed fallocate.
  */
 static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
@@ -1146,10 +1146,10 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 		 * We needed to drop mutex to make that restrictive page
 		 * allocation, but the inode might have been freed while we
 		 * dropped it: although a racing shmem_evict_inode() cannot
-		 * complete without emptying the radix_tree, our page lock
+		 * complete without emptying the page cache, our page lock
 		 * on this swapcache page is not enough to prevent that -
 		 * free_swap_and_cache() of our swap entry will only
-		 * trylock_page(), removing swap from radix_tree whatever.
+		 * trylock_page(), removing swap from page cache whatever.
 		 *
 		 * We must not proceed to shmem_add_to_page_cache() if the
 		 * inode has been freed, but of course we cannot rely on
@@ -1215,7 +1215,7 @@ int shmem_unuse(swp_entry_t swap, struct page *page)
 			false);
 	if (error)
 		goto out;
-	/* No radix_tree_preload: swap entry keeps a place for page in tree */
+	/* No memory allocation: swap entry occupies the slot for the page */
 	error = -EAGAIN;
 
 	mutex_lock(&shmem_swaplist_mutex);
@@ -1889,7 +1889,7 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, inode,
 		spin_unlock_irq(&info->lock);
 		goto repeat;
 	}
-	if (error == -EEXIST)	/* from above or from radix_tree_insert */
+	if (error == -EEXIST)
 		goto repeat;
 	return error;
 }
@@ -2501,7 +2501,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 }
 
 /*
- * llseek SEEK_DATA or SEEK_HOLE through the radix_tree.
+ * llseek SEEK_DATA or SEEK_HOLE through the page cache.
  */
 static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 				    pgoff_t index, pgoff_t end, int whence)
-- 
2.17.1
