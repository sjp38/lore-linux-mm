Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3392B6B0262
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:02 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fe3so40461545pab.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o86si6895970pfa.162.2016.04.06.14.21.52
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 07/30] radix-tree: remove unused looping macros
Date: Wed,  6 Apr 2016 17:21:16 -0400
Message-Id: <1459977699-2349-8-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Matthew Wilcox <willy@linux.intel.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

radix_tree_for_each_chunk() and radix_tree_for_each_chunk_slot()
have never been used in the kernel since their introduction in 2012,
so remove them.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h | 28 ----------------------------
 1 file changed, 28 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 5ce5a1e0ecc5..e1512a607709 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -479,34 +479,6 @@ radix_tree_next_slot(void **slot, struct radix_tree_iter *iter, unsigned flags)
 }
 
 /**
- * radix_tree_for_each_chunk - iterate over chunks
- *
- * @slot:	the void** variable for pointer to chunk first slot
- * @root:	the struct radix_tree_root pointer
- * @iter:	the struct radix_tree_iter pointer
- * @start:	iteration starting index
- * @flags:	RADIX_TREE_ITER_* and tag index
- *
- * Locks can be released and reacquired between iterations.
- */
-#define radix_tree_for_each_chunk(slot, root, iter, start, flags)	\
-	for (slot = radix_tree_iter_init(iter, start) ;			\
-	      (slot = radix_tree_next_chunk(root, iter, flags)) ;)
-
-/**
- * radix_tree_for_each_chunk_slot - iterate over slots in one chunk
- *
- * @slot:	the void** variable, at the beginning points to chunk first slot
- * @iter:	the struct radix_tree_iter pointer
- * @flags:	RADIX_TREE_ITER_*, should be constant
- *
- * This macro is designed to be nested inside radix_tree_for_each_chunk().
- * @slot points to the radix tree slot, @iter->index contains its index.
- */
-#define radix_tree_for_each_chunk_slot(slot, iter, flags)		\
-	for (; slot ; slot = radix_tree_next_slot(slot, iter, flags))
-
-/**
  * radix_tree_for_each_slot - iterate over non-empty slots
  *
  * @slot:	the void** variable for pointer to slot
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
