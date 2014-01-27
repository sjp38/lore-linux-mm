Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 87B656B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 12:57:19 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so3027787bkg.33
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 09:57:18 -0800 (PST)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id e5si59511bko.56.2014.01.27.09.57.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 09:57:18 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so6163069pbb.23
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 09:57:16 -0800 (PST)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] mm: Fix warning on make htmldocs caused by slab.c
Date: Tue, 28 Jan 2014 02:57:08 +0900
Message-Id: <1390845428-6289-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, trivial@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Masanari Iida <standby24x7@gmail.com>

This patch fixed following errors while make htmldocs
Warning(/mm/slab.c:1956): No description found for parameter 'page'
Warning(/mm/slab.c:1956): Excess function parameter 'slabp' description in 'slab_destroy'

Incorrect function parameter "slabp" was set instead of "page"

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 mm/slab.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index eb043bf..b264214 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1946,7 +1946,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 /**
  * slab_destroy - destroy and release all objects in a slab
  * @cachep: cache pointer being destroyed
- * @slabp: slab pointer being destroyed
+ * @page: page pointer being destroyed
  *
  * Destroy all the objs in a slab, and release the mem back to the system.
  * Before calling the slab must have been unlinked from the cache.  The
-- 
1.9.rc0.19.gb594c97

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
