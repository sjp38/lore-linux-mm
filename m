Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 377AB6B0266
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:10 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id td3so40431412pab.2
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:10 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id r86si6878769pfb.219.2016.04.06.14.21.52
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 12/30] radix-tree: Remove restriction on multi-order entries
Date: Wed,  6 Apr 2016 17:21:21 -0400
Message-Id: <1459977699-2349-13-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

Now that sibling pointers are handled explicitly, there is no purpose
served by restricting the order to be >= RADIX_TREE_MAP_SHIFT.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 554986599c63..f2a314cf42cc 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -483,8 +483,6 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 	unsigned int height, shift, offset;
 	int error;
 
-	BUG_ON((0 < order) && (order < RADIX_TREE_MAP_SHIFT));
-
 	/* Make sure the tree is high enough.  */
 	if (index > radix_tree_maxindex(root->height)) {
 		error = radix_tree_extend(root, index, order);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
