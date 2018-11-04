Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F13E36B0003
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 07:50:33 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 33-v6so6714899pld.19
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 04:50:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k14-v6sor13659178pgc.11.2018.11.04.04.50.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Nov 2018 04:50:33 -0800 (PST)
From: Yangtao Li <tiny.windzz@gmail.com>
Subject: [PATCH] mm, slab: remove unnecessary unlikely()
Date: Sun,  4 Nov 2018 07:50:28 -0500
Message-Id: <20181104125028.3572-1-tiny.windzz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yangtao Li <tiny.windzz@gmail.com>

WARN_ON() already contains an unlikely(), so it's not necessary to use
unlikely.

Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>
---
 mm/slab_common.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 7eb8dc136c1c..4f54684f5435 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1029,10 +1029,8 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 
 		index = size_index[size_index_elem(size)];
 	} else {
-		if (unlikely(size > KMALLOC_MAX_CACHE_SIZE)) {
-			WARN_ON(1);
+		if (WARN_ON(size > KMALLOC_MAX_CACHE_SIZE))
 			return NULL;
-		}
 		index = fls(size - 1);
 	}
 
-- 
2.17.0
