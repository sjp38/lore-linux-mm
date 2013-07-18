Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 66ABA6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 03:45:30 -0400 (EDT)
From: Libin <huawei.libin@huawei.com>
Subject: [PATCH] slub: Remove unnecessary page NULL check
Date: Thu, 18 Jul 2013 15:39:51 +0800
Message-ID: <1374133191-19012-1-git-send-email-huawei.libin@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux-foundation.org, penberg@kernel.org, akpm@linux-foundation.org, mpm@selenic.com, rostedt@goodmis.org, guohanjun@huawei.com, wujianguo@huawei.com

In commit 4d7868e6(slub: Do not dereference NULL pointer in node_match)
had added check for page NULL in node_match.  Thus, it is not needed
to check it before node_match, remove it.

Signed-off-by: Libin <huawei.libin@huawei.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 3b482c8..c911ca3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2375,7 +2375,7 @@ redo:
 
 	object = c->freelist;
 	page = c->page;
-	if (unlikely(!object || !page || !node_match(page, node)))
+	if (unlikely(!object || !node_match(page, node)))
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-- 
1.8.2.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
