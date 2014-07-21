Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 46D966B0039
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 07:47:34 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so9064722pdb.31
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 04:47:33 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id l4si7020270pdo.48.2014.07.21.04.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 04:47:32 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/6] slub: remove kmemcg id from create_unique_id
Date: Mon, 21 Jul 2014 15:47:11 +0400
Message-ID: <b86712dab8660717e841bb7c9b8a79de91645d3a.1405941342.git.vdavydov@parallels.com>
In-Reply-To: <cover.1405941342.git.vdavydov@parallels.com>
References: <cover.1405941342.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function is never called for memcg caches, because they are
unmergeable, so remove the dead code.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2b068c3638aa..a1cdbad02f0c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5130,12 +5130,6 @@ static char *create_unique_id(struct kmem_cache *s)
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
