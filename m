From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 5/8] parisc: mem_map/max_mapnr -- definition is specific to FLATMEM
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:41:18 +0100
Message-Id: <1207824078.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The max_mapnr variable is only used FLATMEM memory model, use the
appropriate defines.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/parisc/mm/init.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 2c721e1..bd300d1 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -461,10 +461,11 @@ void __init mem_init(void)
 
 	high_memory = __va((max_pfn << PAGE_SHIFT));
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 	max_mapnr = page_to_pfn(virt_to_page(high_memory - 1)) + 1;
 	totalram_pages += free_all_bootmem();
-#else
+#endif
+#ifdef CONFIG_DISCONTIGMEM
 	{
 		int i;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
