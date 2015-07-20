Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id CDB8A9003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 11:29:17 -0400 (EDT)
Received: by lbbyj8 with SMTP id yj8so97602119lbb.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 08:29:17 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id ng4si18208680lbc.115.2015.07.20.08.29.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 08:29:15 -0700 (PDT)
Subject: [PATCH v2] mm/slub: allow merging when SLAB_DEBUG_FREE is set
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 20 Jul 2015 18:29:13 +0300
Message-ID: <20150720152913.14239.69304.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

This patch fixes creation of new kmem-caches after enabling sanity_checks
for existing mergeable kmem-caches in runtime: before that patch creation
fails because unique name in sysfs already taken by existing kmem-cache.

Unlike to other debug options this doesn't change object layout and could
be enabled and disabled at any time.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/slab_common.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3e5f8f29c286..86831105a09f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -37,8 +37,7 @@ struct kmem_cache *kmem_cache;
 		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOLEAKTRACE | \
 		SLAB_FAILSLAB)
 
-#define SLAB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
-		SLAB_CACHE_DMA | SLAB_NOTRACK)
+#define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | SLAB_NOTRACK)
 
 /*
  * Merge control. If this is set then no merging of slab caches will occur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
