Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 192106B0007
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 08:27:01 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f3-v6so14295503plf.1
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 05:27:01 -0700 (PDT)
Received: from dev31.localdomain ([103.244.59.4])
        by mx.google.com with ESMTP id x143si3636758pgx.157.2018.04.04.05.26.59
        for <linux-mm@kvack.org>;
        Wed, 04 Apr 2018 05:26:59 -0700 (PDT)
From: Huaisheng Ye <yehs1@lenovo.com>
Subject: [PATCH] mm/memblock: fix a typo in comment
Date: Wed,  4 Apr 2018 20:40:58 +0800
Message-Id: <1522845658-21439-1-git-send-email-yehs1@lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huaisheng Ye <yehs1@lenovo.com>

__next_reserved_mem_region is used by for_each_reserved_mem_region.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
---
 mm/memblock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 48376bd..5f36cab 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -810,7 +810,7 @@ int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
 }
 
 /**
- * __next_reserved_mem_region - next function for for_each_reserved_region()
+ * __next_reserved_mem_region - next function for for_each_reserved_mem_region()
  * @idx: pointer to u64 loop variable
  * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
  * @out_end: ptr to phys_addr_t for end address of the region, can be %NULL
-- 
1.8.3.1
