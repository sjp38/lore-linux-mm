Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BA0566B07D9
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:43:35 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 3-v6so16108457plc.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 21:43:35 -0800 (PST)
Received: from conuserg-07.nifty.com (conuserg-07.nifty.com. [210.131.2.74])
        by mx.google.com with ESMTPS id u2-v6si11961plk.39.2018.11.15.21.43.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 21:43:34 -0800 (PST)
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH] slab: fix 'dubious: x & !y' warning from Sparse
Date: Fri, 16 Nov 2018 14:40:29 +0900
Message-Id: <1542346829-31063-1-git-send-email-yamada.masahiro@socionext.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kernel@vger.kernel.org

Sparse reports:
./include/linux/slab.h:332:43: warning: dubious: x & !y

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 include/linux/slab.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 918f374..d395c73 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -329,7 +329,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
 	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
 	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
 	 */
-	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
+	return type_dma + (is_reclaimable && !is_dma) * KMALLOC_RECLAIM;
 }
 
 /*
-- 
2.7.4
