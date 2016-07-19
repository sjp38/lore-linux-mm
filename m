Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C79FF6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 08:03:47 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w207so26268370oiw.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:03:47 -0700 (PDT)
Received: from m12-15.163.com (m12-15.163.com. [220.181.12.15])
        by mx.google.com with ESMTP id b185si13155668itb.24.2016.07.19.05.03.45
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 05:03:47 -0700 (PDT)
From: Wei Yongjun <weiyj_lk@163.com>
Subject: [PATCH -next] mm/slab: use list_move instead of list_del/list_add
Date: Tue, 19 Jul 2016 12:02:52 +0000
Message-Id: <1468929772-9174-1-git-send-email-weiyj_lk@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using list_move() instead of list_del() + list_add().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 mm/slab.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 32c2296..cc6d816 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3452,8 +3452,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		n->free_objects -= cachep->num;
 
 		page = list_last_entry(&n->slabs_free, struct page, lru);
-		list_del(&page->lru);
-		list_add(&page->lru, list);
+		list_move(&page->lru, list);
 	}
 }
 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
