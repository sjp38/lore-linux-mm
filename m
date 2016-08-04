Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E70B6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 08:18:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so145627663wml.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 05:18:32 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id g14si5593962ljg.42.2016.08.04.05.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 05:18:31 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id l89so14756384lfi.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 05:18:31 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: fix a typo in a comment
Date: Thu,  4 Aug 2016 18:18:24 +0600
Message-Id: <20160804121824.18100-1-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Dennis Chen <dennis.chen@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

s/accomodate/accommodate

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index ff5ff3b..1f065da 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -482,7 +482,7 @@ static void __init_memblock memblock_merge_regions(struct memblock_type *type)
  * @flags:	flags of the new region
  *
  * Insert new memblock region [@base,@base+@size) into @type at @idx.
- * @type must already have extra room to accomodate the new region.
+ * @type must already have extra room to accommodate the new region.
  */
 static void __init_memblock memblock_insert_region(struct memblock_type *type,
 						   int idx, phys_addr_t base,
@@ -544,7 +544,7 @@ repeat:
 	/*
 	 * The following is executed twice.  Once with %false @insert and
 	 * then with %true.  The first counts the number of regions needed
-	 * to accomodate the new area.  The second actually inserts them.
+	 * to accommodate the new area.  The second actually inserts them.
 	 */
 	base = obase;
 	nr_new = 0;
-- 
2.8.0.rc3.1353.gea9bdc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
