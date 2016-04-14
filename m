Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A61596B0277
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:22:00 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so92970727pac.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:22:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 128si12390657pfu.156.2016.04.14.07.21.58
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:21:58 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 12/29] radix-tree: Remove restriction on multi-order entries
Date: Thu, 14 Apr 2016 10:16:33 -0400
Message-Id: <1460643410-30196-13-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

Now that sibling pointers are handled explicitly, there is no purpose
served by restricting the order to be >= RADIX_TREE_MAP_SHIFT.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index b3364b9..6900f7b 100644
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
