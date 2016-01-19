Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE676B0254
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:42 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id n128so176174813pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:42 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id q76si47996391pfq.27.2016.01.19.06.25.39
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:39 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 4/8] radix_tree: Convert some variables to unsigned types
Date: Tue, 19 Jan 2016 09:25:29 -0500
Message-Id: <1453213533-6040-5-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

None of these can ever be negative, and it removes a few -Wsign-compare
warnings.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 357b556..7a984ad 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -64,7 +64,7 @@ static struct kmem_cache *radix_tree_node_cachep;
  * Per-cpu pool of preloaded nodes
  */
 struct radix_tree_preload {
-	int nr;
+	unsigned nr;
 	/* nodes->private_data points to next preallocated node */
 	struct radix_tree_node *nodes;
 };
@@ -130,7 +130,7 @@ static inline int root_tag_get(struct radix_tree_root *root, unsigned int tag)
  */
 static inline int any_tag_set(struct radix_tree_node *node, unsigned int tag)
 {
-	int idx;
+	unsigned idx;
 	for (idx = 0; idx < RADIX_TREE_TAG_LONGS; idx++) {
 		if (node->tags[tag][idx])
 			return 1;
@@ -1453,7 +1453,7 @@ static __init unsigned long __maxindex(unsigned int height)
 
 	if (shift < 0)
 		return ~0UL;
-	if (shift >= BITS_PER_LONG)
+	if ((unsigned)shift >= BITS_PER_LONG)
 		return 0UL;
 	return ~0UL >> shift;
 }
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
