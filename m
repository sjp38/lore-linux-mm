Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 45C566B01F0
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 22:59:48 -0400 (EDT)
Received: by qyk33 with SMTP id 33so4942400qyk.28
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 19:59:47 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] mempolicy:add GFP_THISNODE when allocing new page
Date: Tue,  6 Apr 2010 10:59:37 +0800
Message-Id: <1270522777-9216-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

In funtion migrate_pages(), if the dest node have no
enough free pages,it will fallback to other nodes.
Add GFP_THISNODE to avoid this, the same as what
funtion new_page_node() do in migrate.c.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/mempolicy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 08f40a2..fc5ddf5 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -842,7 +842,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)
 {
-	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
+	return alloc_pages_exact_node(node,
+				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
 }
 
 /*
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
