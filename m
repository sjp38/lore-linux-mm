Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2C16B0038
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 04:11:04 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so42664498qkb.2
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 01:11:04 -0700 (PDT)
Received: from m12-11.163.com (m12-11.163.com. [220.181.12.11])
        by mx.google.com with ESMTP id x128si17716350qkx.50.2015.08.22.01.11.02
        for <linux-mm@kvack.org>;
        Sat, 22 Aug 2015 01:11:03 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 1/3] mm/page_alloc: fix a terrible misleading comment
Date: Sat, 22 Aug 2015 15:40:10 +0800
Message-Id: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The comment says that the per-cpu batchsize and zone watermarks
are determined by present_pages which is definitely wrong, they
are both calculated from managed_pages. Fix it.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b5240b..c22b133 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6003,7 +6003,7 @@ void __init mem_init_print_info(const char *str)
  * set_dma_reserve - set the specified number of pages reserved in the first zone
  * @new_dma_reserve: The number of pages to mark reserved
  *
- * The per-cpu batchsize and zone watermarks are determined by present_pages.
+ * The per-cpu batchsize and zone watermarks are determined by managed_pages.
  * In the DMA zone, a significant percentage may be consumed by kernel image
  * and other unfreeable allocations which can skew the watermarks badly. This
  * function may optionally be used to account for unfreeable pages in the
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
