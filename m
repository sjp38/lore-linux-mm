Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6326B02E5
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:16:21 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id n31so10731363qtc.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:16:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor12468864qtf.67.2017.11.22.13.16.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Nov 2017 13:16:20 -0800 (PST)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH v2 08/11] export radix_tree_iter_tag_set
Date: Wed, 22 Nov 2017 16:16:03 -0500
Message-Id: <1511385366-20329-9-git-send-email-josef@toxicpanda.com>
In-Reply-To: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

From: Josef Bacik <jbacik@fb.com>

We use this in btrfs for metadata writeback.

Acked-by: Matthew Wilcox <mawilcox@microsoft.com>
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 lib/radix-tree.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 8b1feca1230a..0c1cde9fcb69 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1459,6 +1459,7 @@ void radix_tree_iter_tag_set(struct radix_tree_root *root,
 {
 	node_tag_set(root, iter->node, tag, iter_offset(iter));
 }
+EXPORT_SYMBOL(radix_tree_iter_tag_set);
 
 static void node_tag_clear(struct radix_tree_root *root,
 				struct radix_tree_node *node,
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
