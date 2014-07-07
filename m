Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC95900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:34 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id b8so2812692lan.12
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:33 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id f5si34297529lah.84.2014.07.07.05.00.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:33 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/8] slub: remove kmemcg id from create_unique_id
Date: Mon, 7 Jul 2014 16:00:09 +0400
Message-ID: <314566c1c65e0d0b391539d828a6c499ca291ef6.1404733720.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function is never called for memcg caches, because they are
unmergeable, so remove the dead code.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1821e2096cbb..81f3823f3e03 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5153,12 +5153,6 @@ static char *create_unique_id(struct kmem_cache *s)
 		*p++ = '-';
 	p += sprintf(p, "%07d", s->size);
 
-#ifdef CONFIG_MEMCG_KMEM
-	if (!is_root_cache(s))
-		p += sprintf(p, "-%08d",
-				memcg_cache_id(s->memcg_params->memcg));
-#endif
-
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
 	return name;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
