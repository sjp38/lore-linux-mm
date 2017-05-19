Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7B9831F8
	for <linux-mm@kvack.org>; Fri, 19 May 2017 17:01:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u187so67923755pgb.0
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:21 -0700 (PDT)
Received: from mail-pg0-f51.google.com (mail-pg0-f51.google.com. [74.125.83.51])
        by mx.google.com with ESMTPS id i9si9047669pgn.205.2017.05.19.14.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 14:01:20 -0700 (PDT)
Received: by mail-pg0-f51.google.com with SMTP id q125so43125858pgq.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 14:01:20 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH 2/3] mm/slub: Mark slab_free_hook() as __maybe_unused
Date: Fri, 19 May 2017 14:00:35 -0700
Message-Id: <20170519210036.146880-3-mka@chromium.org>
In-Reply-To: <20170519210036.146880-1-mka@chromium.org>
References: <20170519210036.146880-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>

The function is only used when certain configuration option are enabled.
Adding the attribute fixes the following warning when building with
clang:

mm/slub.c:1258:20: error: unused function 'slab_free_hook'
    [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 66e1046435b7..23a8eb83efff 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1328,7 +1328,7 @@ static inline void kfree_hook(const void *x)
 	kasan_kfree_large(x);
 }
 
-static inline void *slab_free_hook(struct kmem_cache *s, void *x)
+static inline void *__maybe_unused slab_free_hook(struct kmem_cache *s, void *x)
 {
 	void *freeptr;
 
-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
