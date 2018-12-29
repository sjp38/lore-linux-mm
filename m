Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3A58E0001
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 01:26:22 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s70so28954795qks.4
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 22:26:22 -0800 (PST)
Received: from zg8tmtyylji0my4xnjqunzqa.icoremail.net (zg8tmtyylji0my4xnjqunzqa.icoremail.net. [162.243.164.74])
        by mx.google.com with SMTP id r1si5327991qkd.250.2018.12.28.22.26.20
        for <linux-mm@kvack.org>;
        Fri, 28 Dec 2018 22:26:20 -0800 (PST)
From: Peng Wang <rocking@whu.edu.cn>
Subject: [PATCH] mm/slub.c: freelist is ensured to be NULL when new_slab() fails
Date: Sat, 29 Dec 2018 14:25:12 +0800
Message-Id: <20181229062512.30469-1-rocking@whu.edu.cn>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peng Wang <rocking@whu.edu.cn>

new_slab_objects() will return immediately if freelist is not NULL.

         if (freelist)
                 return freelist;

One more assignment operation could be avoided.

Signed-off-by: Peng Wang <rocking@whu.edu.cn>
---
 mm/slub.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 36c0befeebd8..cf2ef4ababff 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2463,8 +2463,7 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 		stat(s, ALLOC_SLAB);
 		c->page = page;
 		*pc = c;
-	} else
-		freelist = NULL;
+	}
 
 	return freelist;
 }
-- 
2.19.1
