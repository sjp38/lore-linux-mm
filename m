Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id EA0876B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:22:06 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id hm7so3069334lab.3
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 01:22:06 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id du1si240168lac.153.2014.01.20.01.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 01:22:05 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH TRIVIAL] memcg: remove unused code from kmem_cache_destroy_work_func
Date: Mon, 20 Jan 2014 13:22:03 +0400
Message-ID: <1390209723-11869-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7f1a356..7f1511d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3311,11 +3311,9 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 	 * So if we aren't down to zero, we'll just schedule a worker and try
 	 * again
 	 */
-	if (atomic_read(&cachep->memcg_params->nr_pages) != 0) {
+	if (atomic_read(&cachep->memcg_params->nr_pages) != 0)
 		kmem_cache_shrink(cachep);
-		if (atomic_read(&cachep->memcg_params->nr_pages) == 0)
-			return;
-	} else
+	else
 		kmem_cache_destroy(cachep);
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
