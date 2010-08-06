Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5098F6B02B8
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:37 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765BA2F011485
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:10 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FWq81208404
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FV1V016352
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 13/43] memblock: Remove obsolete accessors
Date: Fri,  6 Aug 2010 15:14:54 +1000
Message-Id: <1281071724-28740-14-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |   23 -----------------------
 1 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c914112..7d70fdd 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -64,29 +64,6 @@ extern int memblock_find(struct memblock_region *res);
 
 extern void memblock_dump_all(void);
 
-/* Obsolete accessors */
-static inline u64
-memblock_size_bytes(struct memblock_type *type, unsigned long region_nr)
-{
-	return type->regions[region_nr].size;
-}
-static inline u64
-memblock_size_pages(struct memblock_type *type, unsigned long region_nr)
-{
-	return memblock_size_bytes(type, region_nr) >> PAGE_SHIFT;
-}
-static inline u64
-memblock_start_pfn(struct memblock_type *type, unsigned long region_nr)
-{
-	return type->regions[region_nr].base >> PAGE_SHIFT;
-}
-static inline u64
-memblock_end_pfn(struct memblock_type *type, unsigned long region_nr)
-{
-	return memblock_start_pfn(type, region_nr) +
-	       memblock_size_pages(type, region_nr);
-}
-
 /*
  * pfn conversion functions
  *
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
