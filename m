Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 66CF16B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 14:16:29 -0400 (EDT)
Received: by lbbvu2 with SMTP id vu2so18008001lbb.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:16:28 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id xv11si9982128lab.53.2015.09.15.11.16.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 11:16:28 -0700 (PDT)
Received: by lbcao8 with SMTP id ao8so90078691lbc.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:16:27 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: Make memblock_remove_range() static
Date: Wed, 16 Sep 2015 00:15:25 +0600
Message-Id: <1442340925-15887-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Wei Yang <weiyang@linux.vnet.ibm.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

The memblock_remove_range() function is only used in the
mm/memblock.c, so we can do it static.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 include/linux/memblock.h | 4 ----
 mm/memblock.c            | 2 +-
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c518eb5..24daf8f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -89,10 +89,6 @@ int memblock_add_range(struct memblock_type *type,
 		       phys_addr_t base, phys_addr_t size,
 		       int nid, unsigned long flags);
 
-int memblock_remove_range(struct memblock_type *type,
-			  phys_addr_t base,
-			  phys_addr_t size);
-
 void __next_mem_range(u64 *idx, int nid, ulong flags,
 		      struct memblock_type *type_a,
 		      struct memblock_type *type_b, phys_addr_t *out_start,
diff --git a/mm/memblock.c b/mm/memblock.c
index 1c7b647..d300f13 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -706,7 +706,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 	return 0;
 }
 
-int __init_memblock memblock_remove_range(struct memblock_type *type,
+static int __init_memblock memblock_remove_range(struct memblock_type *type,
 					  phys_addr_t base, phys_addr_t size)
 {
 	int start_rgn, end_rgn;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
