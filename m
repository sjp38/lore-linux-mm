Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB98F6B0005
	for <linux-mm@kvack.org>; Mon, 16 May 2016 21:41:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 77so3955143pfz.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 18:41:14 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id l20si549145pfb.194.2016.05.16.18.41.12
        for <linux-mm@kvack.org>;
        Mon, 16 May 2016 18:41:13 -0700 (PDT)
From: Li Peng <lip@dtdream.com>
Subject: [PATCH] mm/slub.c: fix sysfs filename in comment
Date: Tue, 17 May 2016 09:40:42 +0800
Message-Id: <1463449242-5366-1-git-send-email-lip@dtdream.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Peng <lip@dtdream.com>

/sys/kernel/slab/xx/defrag_ratio should be remote_node_defrag_ratio.

Signed-off-by: Li Peng <lip@dtdream.com>
---
 mm/slub.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 4dbb109e..6ef1540 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1735,11 +1735,11 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 	 * may return off node objects because partial slabs are obtained
 	 * from other nodes and filled up.
 	 *
-	 * If /sys/kernel/slab/xx/defrag_ratio is set to 100 (which makes
-	 * defrag_ratio = 1000) then every (well almost) allocation will
-	 * first attempt to defrag slab caches on other nodes. This means
-	 * scanning over all nodes to look for partial slabs which may be
-	 * expensive if we do it every time we are trying to find a slab
+	 * If /sys/kernel/slab/xx/remote_node_defrag_ratio is set to 100
+	 * (which makes defrag_ratio = 1000) then every (well almost)
+	 * allocation will first attempt to defrag slab caches on other nodes.
+	 * This means scanning over all nodes to look for partial slabs which
+	 * may be expensive if we do it every time we are trying to find a slab
 	 * with available objects.
 	 */
 	if (!s->remote_node_defrag_ratio ||
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
