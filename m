Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6ED6B0082
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 15:35:29 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id uq10so11769973igb.1
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:35:29 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0230.hostedemail.com. [216.40.44.230])
        by mx.google.com with ESMTP id y8si20537269icp.202.2014.03.25.12.35.28
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 12:35:28 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/5] slab: Convert last uses of __FUNCTION__ to __func__
Date: Tue, 25 Mar 2014 12:35:07 -0700
Message-Id: <41f5cfd7a40408b2aad9a7d8cbb2162c4d4688d4.1395775901.git.joe@perches.com>
In-Reply-To: <cover.1395775901.git.joe@perches.com>
References: <cover.1395775901.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Just about all of these have been converted to __func__,
so convert the last uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/slab.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab.h b/mm/slab.h
index 3045316..0d13b70 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -249,7 +249,7 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 		return cachep;
 
 	pr_err("%s: Wrong slab cache. %s but object is from %s\n",
-		__FUNCTION__, cachep->name, s->name);
+	       __func__, cachep->name, s->name);
 	WARN_ON_ONCE(1);
 	return s;
 }
-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
