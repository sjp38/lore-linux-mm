From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 7/8] sparc64: mem_map/max_mapnr -- definition is specific to FLATMEM
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:41:21 +0100
Message-Id: <1207824081.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

The max_mapnr variable is only used FLATMEM memory model, as sparc64
only supports SPARSEMEM this variable is redundant.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/sparc64/mm/init.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)
diff --git a/arch/sparc64/mm/init.c b/arch/sparc64/mm/init.c
index f6a86a2..c218134 100644
--- a/arch/sparc64/mm/init.c
+++ b/arch/sparc64/mm/init.c
@@ -1330,8 +1330,6 @@ void __init paging_init(void)
 	pages_avail = 0;
 	last_valid_pfn = end_pfn = bootmem_init(&pages_avail, phys_base);
 
-	max_mapnr = last_valid_pfn;
-
 	kernel_physical_mapping_init();
 
 	real_setup_per_cpu_areas();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
