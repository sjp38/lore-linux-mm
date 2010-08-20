Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 262656B02FB
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:51:54 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L7G00MDB3EEDC50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 10:51:50 +0100 (BST)
Received: from pikus.localdomain ([10.89.8.241])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7G008IB3CR4S@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 10:51:50 +0100 (BST)
Date: Fri, 20 Aug 2010 11:50:41 +0200
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCH/RFCv4 1/6] lib: rbtree: rb_root_init() function added
In-reply-to: <cover.1282286941.git.m.nazarewicz@samsung.com>
Message-id: 
 <0b02e05fc21e70a3af39e65e628d117cd89d70a1.1282286941.git.m.nazarewicz@samsung.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Added a rb_root_init() function which initialises a rb_root
structure as a red-black tree with at most one element.  The
rationale is that using rb_root_init(root, node) is more
straightforward and cleaner then first initialising and
empty tree followed by an insert operation.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/rbtree.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/rbtree.h b/include/linux/rbtree.h
index 7066acb..5b6dc66 100644
--- a/include/linux/rbtree.h
+++ b/include/linux/rbtree.h
@@ -130,6 +130,17 @@ static inline void rb_set_color(struct rb_node *rb, int color)
 }
 
 #define RB_ROOT	(struct rb_root) { NULL, }
+
+static inline void rb_root_init(struct rb_root *root, struct rb_node *node)
+{
+	root->rb_node = node;
+	if (node) {
+		node->rb_parent_color = RB_BLACK; /* black, no parent */
+		node->rb_left  = NULL;
+		node->rb_right = NULL;
+	}
+}
+
 #define	rb_entry(ptr, type, member) container_of(ptr, type, member)
 
 #define RB_EMPTY_ROOT(root)	((root)->rb_node == NULL)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
