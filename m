Date: Mon, 18 Sep 2006 11:36:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060918183655.19679.51633.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 8/8] Remove ZONE_DMA remains from sh/sh64
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@SteelEye.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

sh / sh64: Remove ZONE_DMA remains.

Both arches do not need ZONE_DMA

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/arch/sh/mm/init.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/sh/mm/init.c	2006-09-18 12:54:04.733274009 -0500
+++ linux-2.6.18-rc6-mm2/arch/sh/mm/init.c	2006-09-18 12:58:58.563038661 -0500
@@ -156,7 +156,6 @@ void __init paging_init(void)
 	 * Setup some defaults for the zone sizes.. these should be safe
 	 * regardless of distcontiguous memory or MMU settings.
 	 */
-	zones_size[ZONE_DMA] = 0 >> PAGE_SHIFT;
 	zones_size[ZONE_NORMAL] = __MEMORY_SIZE >> PAGE_SHIFT;
 #ifdef CONFIG_HIGHMEM
 	zones_size[ZONE_HIGHMEM] = 0 >> PAGE_SHIFT;
Index: linux-2.6.18-rc6-mm2/arch/sh64/mm/init.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/sh64/mm/init.c	2006-09-18 12:54:04.745970361 -0500
+++ linux-2.6.18-rc6-mm2/arch/sh64/mm/init.c	2006-09-18 12:58:58.577688302 -0500
@@ -118,10 +118,7 @@ void __init paging_init(void)
 
 	mmu_context_cache = MMU_CONTEXT_FIRST_VERSION;
 
-        /*
-	 * All memory is good as ZONE_NORMAL (fall-through) and ZONE_DMA.
-         */
-	zones_size[ZONE_DMA] = MAX_LOW_PFN - START_PFN;
+	zones_size[ZONE_NORMAL] = MAX_LOW_PFN - START_PFN;
 	NODE_DATA(0)->node_mem_map = NULL;
 	free_area_init_node(0, NODE_DATA(0), zones_size, __MEMORY_START >> PAGE_SHIFT, 0);
 }
Index: linux-2.6.18-rc6-mm2/arch/sh64/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/sh64/Kconfig	2006-09-18 12:33:04.000000000 -0500
+++ linux-2.6.18-rc6-mm2/arch/sh64/Kconfig	2006-09-18 13:01:07.919367272 -0500
@@ -36,9 +36,6 @@ config GENERIC_CALIBRATE_DELAY
 config RWSEM_XCHGADD_ALGORITHM
 	bool
 
-config GENERIC_ISA_DMA
-	bool
-
 source init/Kconfig
 
 menu "System type"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
