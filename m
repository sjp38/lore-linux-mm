Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 6DB796B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 21:10:18 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/3] mips: zero out pg_data_t when it's allocated
Date: Tue, 24 Jul 2012 10:10:33 +0900
Message-Id: <1343092235-13399-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org

This patch is ready for next patch which try to remove zero-out
of pg_data_t in core MM part. At a glance, all archs except this part
already have done it so this patch makes consistent with other archs.

Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 arch/mips/sgi-ip27/ip27-memory.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-memory.c
index b105eca..cd8fcab 100644
--- a/arch/mips/sgi-ip27/ip27-memory.c
+++ b/arch/mips/sgi-ip27/ip27-memory.c
@@ -401,6 +401,7 @@ static void __init node_mem_init(cnodeid_t node)
 	 * Allocate the node data structures on the node first.
 	 */
 	__node_data[node] = __va(slot_freepfn << PAGE_SHIFT);
+	memset(__node_data[node], 0, PAGE_SIZE);
 
 	NODE_DATA(node)->bdata = &bootmem_node_data[node];
 	NODE_DATA(node)->node_start_pfn = start_pfn;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
