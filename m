Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 031636B0032
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 04:23:57 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/2] mm, nobootmem: clean-up of free_low_memory_core_early()
Date: Mon, 22 Apr 2013 17:25:12 +0900
Message-Id: <1366619113-28017-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Remove unused argument and make function static,
because there is no user outside of nobootmem.c

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index cdc3bab..5f0b0e1 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -44,7 +44,6 @@ extern unsigned long init_bootmem_node(pg_data_t *pgdat,
 				       unsigned long endpfn);
 extern unsigned long init_bootmem(unsigned long addr, unsigned long memend);
 
-extern unsigned long free_low_memory_core_early(int nodeid);
 extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
 extern unsigned long free_all_bootmem(void);
 
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 5e07d36..a31be7a 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -120,7 +120,7 @@ static unsigned long __init __free_memory_core(phys_addr_t start,
 	return end_pfn - start_pfn;
 }
 
-unsigned long __init free_low_memory_core_early(int nodeid)
+static unsigned long __init free_low_memory_core_early(void)
 {
 	unsigned long count = 0;
 	phys_addr_t start, end, size;
@@ -170,7 +170,7 @@ unsigned long __init free_all_bootmem(void)
 	 *  because in some case like Node0 doesn't have RAM installed
 	 *  low ram will be on Node1
 	 */
-	return free_low_memory_core_early(MAX_NUMNODES);
+	return free_low_memory_core_early();
 }
 
 /**
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
