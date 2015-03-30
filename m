Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id E67546B006E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 19:48:01 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so4013005igb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 16:48:01 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0020.hostedemail.com. [216.40.44.20])
        by mx.google.com with ESMTP id kv2si10235488igb.19.2015.03.30.16.48.01
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 16:48:01 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 21/25] slub: Use bool function return values of true/false not 1/0
Date: Mon, 30 Mar 2015 16:46:19 -0700
Message-Id: <e5d4c7a9a3496ac77ad5a07ce7f917b694053558.1427759010.git.joe@perches.com>
In-Reply-To: <cover.1427759009.git.joe@perches.com>
References: <cover.1427759009.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

Use the normal return values for bool functions

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/slub.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 90227ad..520354d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -376,7 +376,7 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 		if (cmpxchg_double(&page->freelist, &page->counters,
 				   freelist_old, counters_old,
 				   freelist_new, counters_new))
-			return 1;
+			return true;
 	} else
 #endif
 	{
@@ -386,7 +386,7 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 			page->freelist = freelist_new;
 			set_page_slub_counters(page, counters_new);
 			slab_unlock(page);
-			return 1;
+			return true;
 		}
 		slab_unlock(page);
 	}
@@ -398,7 +398,7 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 	pr_info("%s %s: cmpxchg double redo ", n, s->name);
 #endif
 
-	return 0;
+	return false;
 }
 
 static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
@@ -412,7 +412,7 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		if (cmpxchg_double(&page->freelist, &page->counters,
 				   freelist_old, counters_old,
 				   freelist_new, counters_new))
-			return 1;
+			return true;
 	} else
 #endif
 	{
@@ -426,7 +426,7 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 			set_page_slub_counters(page, counters_new);
 			slab_unlock(page);
 			local_irq_restore(flags);
-			return 1;
+			return true;
 		}
 		slab_unlock(page);
 		local_irq_restore(flags);
@@ -439,7 +439,7 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 	pr_info("%s %s: cmpxchg double redo ", n, s->name);
 #endif
 
-	return 0;
+	return false;
 }
 
 #ifdef CONFIG_SLUB_DEBUG
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
