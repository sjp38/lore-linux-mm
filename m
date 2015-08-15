Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id A76AF6B0253
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 12:50:02 -0400 (EDT)
Received: by lagz9 with SMTP id z9so58512483lag.3
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 09:50:01 -0700 (PDT)
Received: from mail-la0-x232.google.com (mail-la0-x232.google.com. [2a00:1450:4010:c03::232])
        by mx.google.com with ESMTPS id ur5si8257828lbb.107.2015.08.15.09.50.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 09:50:01 -0700 (PDT)
Received: by lagz9 with SMTP id z9so58512300lag.3
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 09:50:00 -0700 (PDT)
From: Alexander Kuleshov <kuleshovmail@gmail.com>
Subject: [PATCH] mm/memblock: rename local variable of memblock_type to 'type'
Date: Sat, 15 Aug 2015 22:49:38 +0600
Message-Id: <1439657378-9464-1-git-send-email-kuleshovmail@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Robin Holt <holt@sgi.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Kuleshov <kuleshovmail@gmail.com>

Since the e3239ff92a1 commit (memblock: Rename memblock_region
to memblock_type and memblock_property to memblock_region), all
local variables of the membock_type type were renamed to 'type'.
This commit renames all remaining local variables with the
memblock_type type to the same view.

Signed-off-by: Alexander Kuleshov <kuleshovmail@gmail.com>
---
 mm/memblock.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 87108e7..cf6b109 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -611,14 +611,14 @@ static int __init_memblock memblock_add_region(phys_addr_t base,
 						int nid,
 						unsigned long flags)
 {
-	struct memblock_type *_rgn = &memblock.memory;
+	struct memblock_type *type = &memblock.memory;
 
 	memblock_dbg("memblock_add: [%#016llx-%#016llx] flags %#02lx %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size - 1,
 		     flags, (void *)_RET_IP_);
 
-	return memblock_add_range(_rgn, base, size, nid, flags);
+	return memblock_add_range(type, base, size, nid, flags);
 }
 
 int __init_memblock memblock_add(phys_addr_t base, phys_addr_t size)
@@ -831,10 +831,10 @@ void __init_memblock __next_reserved_mem_region(u64 *idx,
 					   phys_addr_t *out_start,
 					   phys_addr_t *out_end)
 {
-	struct memblock_type *rsv = &memblock.reserved;
+	struct memblock_type *type = &memblock.reserved;
 
-	if (*idx >= 0 && *idx < rsv->cnt) {
-		struct memblock_region *r = &rsv->regions[*idx];
+	if (*idx >= 0 && *idx < type->cnt) {
+		struct memblock_region *r = &type->regions[*idx];
 		phys_addr_t base = r->base;
 		phys_addr_t size = r->size;
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
