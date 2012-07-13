Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id C62E96B0062
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:33:12 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:33:12 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 12/12] rbtree: coding style adjustments
Date: Thu, 12 Jul 2012 17:31:57 -0700
Message-Id: <1342139517-3451-13-git-send-email-walken@google.com>
In-Reply-To: <1342139517-3451-1-git-send-email-walken@google.com>
References: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Set comment and indentation style to be consistent with linux coding style
and the rest of the file, as suggested by Peter Zijlstra

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 lib/rbtree.c |   42 +++++++++++++++++++++++-------------------
 1 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/lib/rbtree.c b/lib/rbtree.c
index a38e473..0892670 100644
--- a/lib/rbtree.c
+++ b/lib/rbtree.c
@@ -363,8 +363,7 @@ void rb_erase(struct rb_node *node, struct rb_root *root)
 		child = node->rb_right;
 	else if (!node->rb_right)
 		child = node->rb_left;
-	else
-	{
+	else {
 		struct rb_node *old = node, *left;
 
 		node = node->rb_right;
@@ -406,17 +405,15 @@ void rb_erase(struct rb_node *node, struct rb_root *root)
 
 	if (child)
 		rb_set_parent(child, parent);
-	if (parent)
-	{
+	if (parent) {
 		if (parent->rb_left == node)
 			parent->rb_left = child;
 		else
 			parent->rb_right = child;
-	}
-	else
+	} else
 		root->rb_node = child;
 
- color:
+color:
 	if (color == RB_BLACK)
 		__rb_erase_color(child, parent, root);
 }
@@ -529,8 +526,10 @@ struct rb_node *rb_next(const struct rb_node *node)
 	if (RB_EMPTY_NODE(node))
 		return NULL;
 
-	/* If we have a right-hand child, go down and then left as far
-	   as we can. */
+	/*
+	 * If we have a right-hand child, go down and then left as far
+	 * as we can.
+	 */
 	if (node->rb_right) {
 		node = node->rb_right; 
 		while (node->rb_left)
@@ -538,12 +537,13 @@ struct rb_node *rb_next(const struct rb_node *node)
 		return (struct rb_node *)node;
 	}
 
-	/* No right-hand children.  Everything down and left is
-	   smaller than us, so any 'next' node must be in the general
-	   direction of our parent. Go up the tree; any time the
-	   ancestor is a right-hand child of its parent, keep going
-	   up. First time it's a left-hand child of its parent, said
-	   parent is our 'next' node. */
+	/*
+	 * No right-hand children. Everything down and left is smaller than us,
+	 * so any 'next' node must be in the general direction of our parent.
+	 * Go up the tree; any time the ancestor is a right-hand child of its
+	 * parent, keep going up. First time it's a left-hand child of its
+	 * parent, said parent is our 'next' node.
+	 */
 	while ((parent = rb_parent(node)) && node == parent->rb_right)
 		node = parent;
 
@@ -558,8 +558,10 @@ struct rb_node *rb_prev(const struct rb_node *node)
 	if (RB_EMPTY_NODE(node))
 		return NULL;
 
-	/* If we have a left-hand child, go down and then right as far
-	   as we can. */
+	/*
+	 * If we have a left-hand child, go down and then right as far
+	 * as we can.
+	 */
 	if (node->rb_left) {
 		node = node->rb_left; 
 		while (node->rb_right)
@@ -567,8 +569,10 @@ struct rb_node *rb_prev(const struct rb_node *node)
 		return (struct rb_node *)node;
 	}
 
-	/* No left-hand children. Go up till we find an ancestor which
-	   is a right-hand child of its parent */
+	/*
+	 * No left-hand children. Go up till we find an ancestor which
+	 * is a right-hand child of its parent.
+	 */
 	while ((parent = rb_parent(node)) && node == parent->rb_left)
 		node = parent;
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
