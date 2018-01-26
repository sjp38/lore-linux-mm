Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65E1A6B0022
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 07:09:19 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o28so137008pgn.6
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 04:09:19 -0800 (PST)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id c7-v6si3659709pll.674.2018.01.26.04.09.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 04:09:17 -0800 (PST)
From: <miles.chen@mediatek.com>
Subject: [PATCH] slub: remove obsolete comments of put_cpu_partial()
Date: Fri, 26 Jan 2018 20:09:10 +0800
Message-ID: <1516968550-1520-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

The commit d6e0b7fa1186 ("slub: make dead caches discard free
slabs immediately") makes put_cpu_partial() run with preemption
disabled and interrupts disabled when calling unfreeze_partials().

The comment: "put_cpu_partial() is done without interrupts disabled
and without preemption disabled" looks obsolete, so remove it.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/slub.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index cfd56e5a35fb..70447d39de90 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2220,9 +2220,7 @@ static void unfreeze_partials(struct kmem_cache *s,
 
 /*
  * Put a page that was just frozen (in __slab_free) into a partial page
- * slot if available. This is done without interrupts disabled and without
- * preemption disabled. The cmpxchg is racy and may put the partial page
- * onto a random cpus partial slot.
+ * slot if available.
  *
  * If we did not find a slot then simply move all the partials to the
  * per node partial list.
-- 
2.12.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
