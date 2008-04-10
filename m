From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 8/8] mem_map/max_mapnr are specific to the FLATMEM memory model
References: <20080410103306.GA29831@shadowen.org>
Date: Thu, 10 Apr 2008 11:41:22 +0100
Message-Id: <1207824082.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Johannes Weiner <hannes@saeurebad.de>, Andy Whitcroft <apw@shadowen.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

mem_map and max_mapnr are variables used in the FLATMEM memory model
only.  Ensure they are only defined when that memory model is enabled.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/memory.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)
diff --git a/mm/memory.c b/mm/memory.c
index 0d14d1e..091324e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -61,8 +61,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 
-#ifndef CONFIG_NEED_MULTIPLE_NODES
-/* use the per-pgdat data instead for discontigmem - mbligh */
+#ifdef CONFIG_FLATMEM
 unsigned long max_mapnr;
 struct page *mem_map;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
