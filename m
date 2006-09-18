Date: Mon, 18 Sep 2006 11:36:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060918183650.19679.81541.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
References: <20060918183614.19679.50359.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 7/8] Remove ZONE_DMA remains from parisc
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: Paul Mundt <lethal@linux-sh.org>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@SteelEye.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Russell King <rmk@arm.linux.org.uk>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Remove ZONE_DMA remains from parisc so that kernels are build without
ZONE_DMA.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/arch/parisc/Kconfig
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/parisc/Kconfig	2006-09-18 12:52:05.203892680 -0500
+++ linux-2.6.18-rc6-mm2/arch/parisc/Kconfig	2006-09-18 12:55:43.140754129 -0500
@@ -42,9 +42,6 @@ config TIME_LOW_RES
 	depends on SMP
 	default y
 
-config GENERIC_ISA_DMA
-	bool
-
 config GENERIC_HARDIRQS
 	def_bool y
 
Index: linux-2.6.18-rc6-mm2/arch/parisc/mm/init.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/arch/parisc/mm/init.c	2006-09-18 12:52:05.217565682 -0500
+++ linux-2.6.18-rc6-mm2/arch/parisc/mm/init.c	2006-09-18 12:55:43.153450483 -0500
@@ -808,9 +808,7 @@ void __init paging_init(void)
 	for (i = 0; i < npmem_ranges; i++) {
 		unsigned long zones_size[MAX_NR_ZONES] = { 0, };
 
-		/* We have an IOMMU, so all memory can go into a single
-		   ZONE_DMA zone. */
-		zones_size[ZONE_DMA] = pmem_ranges[i].pages;
+		zones_size[ZONE_NORMAL] = pmem_ranges[i].pages;
 
 #ifdef CONFIG_DISCONTIGMEM
 		/* Need to initialize the pfnnid_map before we can initialize

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
