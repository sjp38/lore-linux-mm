Date: Sun, 23 Nov 2008 18:51:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] radix-tree: document wrap-around issue of
	radix_tree_next_hole()
Message-ID: <20081123105155.GA14524@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trivial Patch Monkey <trivial@kernel.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

And some 80-line cleanups.

Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
---
 lib/radix-tree.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -640,13 +640,14 @@ EXPORT_SYMBOL(radix_tree_tag_get);
  *
  *	Returns: the index of the hole if found, otherwise returns an index
  *	outside of the set specified (in which case 'return - index >= max_scan'
- *	will be true).
+ *	will be true). In rare cases of index wrap-around, 0 will be returned.
  *
  *	radix_tree_next_hole may be called under rcu_read_lock. However, like
- *	radix_tree_gang_lookup, this will not atomically search a snapshot of the
- *	tree at a single point in time. For example, if a hole is created at index
- *	5, then subsequently a hole is created at index 10, radix_tree_next_hole
- *	covering both indexes may return 10 if called under rcu_read_lock.
+ *	radix_tree_gang_lookup, this will not atomically search a snapshot of
+ *	the tree at a single point in time. For example, if a hole is created
+ *	at index 5, then subsequently a hole is created at index 10,
+ *	radix_tree_next_hole covering both indexes may return 10 if called
+ *	under rcu_read_lock.
  */
 unsigned long radix_tree_next_hole(struct radix_tree_root *root,
 				unsigned long index, unsigned long max_scan)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
