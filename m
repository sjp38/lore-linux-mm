From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/8] m32r: mem_map/max_mapnr -- definition is specific to FLATMEM
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:41:15 +0100
Message-Id: <1207824075.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The max_mapnr variable is only used FLATMEM memory model, use the
appropriate defines.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/m32r/mm/init.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)
diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index 2a3e8b5..f4a614f 100644
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -148,9 +148,9 @@ void __init mem_init(void)
 
 	num_physpages -= hole_pages;
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 	max_mapnr = num_physpages;
-#endif	/* CONFIG_DISCONTIGMEM */
+#endif	/* CONFIG_FLATMEM */
 
 #ifdef CONFIG_MMU
 	high_memory = (void *)__va(PFN_PHYS(MAX_LOW_PFN(0)));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
