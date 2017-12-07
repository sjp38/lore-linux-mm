Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C88B46B0038
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 05:18:58 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c3so3820691wrd.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 02:18:58 -0800 (PST)
Received: from xavier.telenet-ops.be (xavier.telenet-ops.be. [2a02:1800:120:4::f00:14])
        by mx.google.com with ESMTPS id s27si1502357eda.2.2017.12.07.02.18.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 02:18:57 -0800 (PST)
From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] mm/slab: Merge adjacent debug sections
Date: Thu,  7 Dec 2017 11:18:52 +0100
Message-Id: <1512641932-5221-1-git-send-email-geert+renesas@glider.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert+renesas@glider.be>

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 mm/slab.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 70be5823227dcb3e..dd8c6d33f59a11d1 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1569,9 +1569,6 @@ static void dump_line(char *data, int offset, int limit)
 		}
 	}
 }
-#endif
-
-#if DEBUG
 
 static void print_objinfo(struct kmem_cache *cachep, void *objp, int lines)
 {
@@ -1661,9 +1658,7 @@ static void check_poison_obj(struct kmem_cache *cachep, void *objp)
 		}
 	}
 }
-#endif
 
-#if DEBUG
 static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 						struct page *page)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
