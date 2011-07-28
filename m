Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5166B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 19:09:58 -0400 (EDT)
From: jhbird.choi@samsung.com
Subject: [PATCH] mm/memblock: small function definition fixes
Date: Fri, 29 Jul 2011 08:01:20 +0900
Message-Id: <1311894080-10231-1-git-send-email-jhbird.choi@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jonghwan Choi <jhbird.choi@samsung.com>

From: Jonghwan Choi <jhbird.choi@samsung.com>

warning: function 'memblock_memory_can_coalesce'
with external linkage has definition.

Signed-off-by: Jonghwan Choi <jhbird.choi@samsung.com>
---
 mm/memblock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index ccbf973..3314cb4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -267,7 +267,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type)
 	return 0;
 }
 
-extern int __init_memblock __weak memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
+int __init_memblock __weak memblock_memory_can_coalesce(phys_addr_t addr1, phys_addr_t size1,
 					  phys_addr_t addr2, phys_addr_t size2)
 {
 	return 1;
-- 
1.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
