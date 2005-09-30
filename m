From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073258.10631.74982.sendpatchset@cherry.local>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 05/07] i386: sparsemem on pc
Date: Fri, 30 Sep 2005 16:33:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
From: Magnus Damm <magnus@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch for enables and fixes sparsemem support on i386. This is the
same patch that was sent to linux-kernel on September 6:th 2005, but this 
patch includes up-porting to fit on top of the patches written by Dave Hansen.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 Kconfig        |    4 ++--
 kernel/setup.c |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

--- from-0002/arch/i386/Kconfig
+++ to-work/arch/i386/Kconfig	2005-09-28 16:32:47.000000000 +0900
@@ -762,7 +762,6 @@ config NUMA
 	depends on SMP && HIGHMEM64G && (X86_NUMAQ || X86_GENERICARCH || (X86_SUMMIT && ACPI))
 	default n if X86_PC
 	default y if (X86_NUMAQ || X86_SUMMIT)
-	select SPARSEMEM_STATIC
 
 # Need comments to help the hapless user trying to turn on NUMA support
 comment "NUMA (NUMA-Q) requires SMP, 64GB highmem support"
@@ -801,7 +800,8 @@ config ARCH_DISCONTIGMEM_DEFAULT
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
-	depends on NUMA
+	depends on NUMA || (X86_PC && EXPERIMENTAL)
+	select SPARSEMEM_STATIC
 
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
--- from-0006/arch/i386/kernel/setup.c
+++ to-work/arch/i386/kernel/setup.c	2005-09-28 16:32:47.000000000 +0900
@@ -390,6 +390,7 @@ int __init get_memcfg_numa_flat(void)
 	/* Run the memory configuration and find the top of memory. */
 	node_start_pfn[0] = 0;
 	node_end_pfn[0] = max_pfn;
+	memory_present(0, 0, max_pfn);
 
         /* Indicate there is one node available. */
 	nodes_clear(node_online_map);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
