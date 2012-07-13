Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id AF7856B0062
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:27 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3657088ggm.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:26 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 01/12] rbtree: reference Documentation/rbtree.txt for usage instructions
Date: Thu, 12 Jul 2012 17:31:46 -0700
Message-Id: <1342139517-3451-2-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

include/linux/rbtree.h included some basic usage instructions, while
Documentation/rbtree.txt had some more complete and easier to follow
instructions.  Replacing the former with a reference to the latter.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/rbtree.h |   67 +-----------------------------------------------
 1 files changed, 1 insertions(+), 66 deletions(-)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 033b507..e6a8077 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -23,72 +23,7 @@
   I know it's not the cleaner way,  but in C (not in C++) to get
   performances and genericity...
 
-  Some example of insert and search follows here. The search is a plain
-  normal search over an ordered tree. The insert instead must be implemented
-  in two steps: First, the code must insert the element in order as a red leaf
-  in the tree, and then the support library function rb_insert_color() must
-  be called. Such function will do the not trivial work to rebalance the
-  rbtree, if necessary.
-
------------------------------------------------------------------------
-static inline struct page * rb_search_page_cache(struct inode * inode,
-						 unsigned long offset)
-{
-	struct rb_node * n = inode->i_rb_page_cache.rb_node;
-	struct page * page;
-
-	while (n)
-	{
-		page = rb_entry(n, struct page, rb_page_cache);
-
-		if (offset < page->offset)
-			n = n->rb_left;
-		else if (offset > page->offset)
-			n = n->rb_right;
-		else
-			return page;
-	}
-	return NULL;
-}
-
-static inline struct page * __rb_insert_page_cache(struct inode * inode,
-						   unsigned long offset,
-						   struct rb_node * node)
-{
-	struct rb_node ** p = &inode->i_rb_page_cache.rb_node;
-	struct rb_node * parent = NULL;
-	struct page * page;
-
-	while (*p)
-	{
-		parent = *p;
-		page = rb_entry(parent, struct page, rb_page_cache);
-
-		if (offset < page->offset)
-			p = &(*p)->rb_left;
-		else if (offset > page->offset)
-			p = &(*p)->rb_right;
-		else
-			return page;
-	}
-
-	rb_link_node(node, parent, p);
-
-	return NULL;
-}
-
-static inline struct page * rb_insert_page_cache(struct inode * inode,
-						 unsigned long offset,
-						 struct rb_node * node)
-{
-	struct page * ret;
-	if ((ret = __rb_insert_page_cache(inode, offset, node)))
-		goto out;
-	rb_insert_color(node, &inode->i_rb_page_cache);
- out:
-	return ret;
-}
------------------------------------------------------------------------
+  See Documentation/rbtree.txt for documentation and samples.
 */
 
 #ifndef	_LINUX_RBTREE_H
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
