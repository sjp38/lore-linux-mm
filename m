Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5DB6B02BA
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:38 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765BVc8000474
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:31 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FZ8H1208422
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FYVC017117
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 39/43] memblock: Export MEMBLOCK_ERROR
Date: Fri,  6 Aug 2010 15:15:20 +1000
Message-Id: <1281071724-28740-40-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

From: Yinghai Lu <yinghai@kernel.org>

will used by x86 memblock_x86_find_in_range_node and nobootmem replacement

Signed-off-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |    3 ++-
 mm/memblock.c            |    2 --
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index eed0f9b..1a9c29c 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -18,7 +18,8 @@
 
 #include <asm/memblock.h>
 
-#define INIT_MEMBLOCK_REGIONS 128
+#define INIT_MEMBLOCK_REGIONS	128
+#define MEMBLOCK_ERROR		(~(phys_addr_t)0)
 
 struct memblock_region {
 	phys_addr_t base;
diff --git a/mm/memblock.c b/mm/memblock.c
index c3703ab..85cfa1d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -27,8 +27,6 @@ int memblock_can_resize;
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS + 1];
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS + 1];
 
-#define MEMBLOCK_ERROR	(~(phys_addr_t)0)
-
 /* inline so we don't get a warning when pr_debug is compiled out */
 static inline const char *memblock_type_name(struct memblock_type *type)
 {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
