Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1046B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 07:32:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y192so36323360pgd.0
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 04:32:29 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id i188si12763340pgc.443.2017.10.05.04.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 04:32:28 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [PATCH] mm/slob: remove an unnecessary check for __GFP_ZERO
Date: Thu, 5 Oct 2017 19:32:21 +0800
Message-ID: <1507203141-11959-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

Current flow guarantees a valid pointer when handling
the __GFP_ZERO case. So remove the unnecessary NULL pointer
check.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/slob.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slob.c b/mm/slob.c
index a8bd6fa..a72649c 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -329,7 +329,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
-	if (unlikely((gfp & __GFP_ZERO) && b))
+	if (unlikely(gfp & __GFP_ZERO))
 		memset(b, 0, size);
 	return b;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
