From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC 01/22] Generic show_mem() implementation
Date: Wed,  2 Apr 2008 22:40:07 +0200
Message-ID: <1207168839586-git-send-email-hannes@saeurebad.de>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762041AbYDBVmW@vger.kernel.org>
In-Reply-To: <12071688283927-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org


Signed-off-by: Johannes Weiner <hannes@saeurebad.de>

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 729cdbd..efffa92 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -598,6 +598,9 @@ config ALPHA_LARGE_VMALLOC
 
 	  Say N unless you know you need gobs and gobs of vmalloc space.
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 config VERBOSE_MCHECK
 	bool "Verbose Machine Checks"
 
diff --git a/arch/arm/mm/Kconfig b/arch/arm/mm/Kconfig
index 76348f0..acad217 100644
--- a/arch/arm/mm/Kconfig
+++ b/arch/arm/mm/Kconfig
@@ -673,3 +673,6 @@ config OUTER_CACHE
 config CACHE_L2X0
 	bool
 	select OUTER_CACHE
+
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
diff --git a/arch/avr32/Kconfig b/arch/avr32/Kconfig
index c75d708..81e3360 100644
--- a/arch/avr32/Kconfig
+++ b/arch/avr32/Kconfig
@@ -146,6 +146,9 @@ source "kernel/Kconfig.preempt"
 config HAVE_ARCH_BOOTMEM_NODE
 	def_bool n
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 config ARCH_HAVE_MEMORY_PRESENT
 	def_bool n
 
diff --git a/arch/blackfin/Kconfig b/arch/blackfin/Kconfig
index 589c6ac..a8cc977 100644
--- a/arch/blackfin/Kconfig
+++ b/arch/blackfin/Kconfig
@@ -526,6 +526,9 @@ config BFIN_SCRATCH_REG_CYCLES
 
 endchoice
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 endmenu
 
 
diff --git a/arch/cris/Kconfig b/arch/cris/Kconfig
index 9389d38..217c658 100644
--- a/arch/cris/Kconfig
+++ b/arch/cris/Kconfig
@@ -108,6 +108,9 @@ config OOM_REBOOT
 
 source "kernel/Kconfig.preempt"
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source mm/Kconfig
 
 endmenu
diff --git a/arch/frv/Kconfig b/arch/frv/Kconfig
index a5aac1b..c1a5aac 100644
--- a/arch/frv/Kconfig
+++ b/arch/frv/Kconfig
@@ -107,6 +107,9 @@ config HIGHPTE
 	  with a lot of RAM, this can be wasteful of precious low memory.
 	  Setting this option will put user-space page tables in high memory.
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 choice
diff --git a/arch/h8300/Kconfig b/arch/h8300/Kconfig
index 085dc6e..70e63fc 100644
--- a/arch/h8300/Kconfig
+++ b/arch/h8300/Kconfig
@@ -22,6 +22,9 @@ config ZONE_DMA
 	bool
 	default y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 config FPU
 	bool
 	default n
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8fa3faf..b178caa 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -431,6 +431,9 @@ config HAVE_ARCH_NODEDATA_EXTENSION
 	def_bool y
 	depends on NUMA
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 config IA32_SUPPORT
 	bool "Support for Linux/x86 binaries"
 	help
diff --git a/arch/m32r/Kconfig b/arch/m32r/Kconfig
index de153de..2f51d8f 100644
--- a/arch/m32r/Kconfig
+++ b/arch/m32r/Kconfig
@@ -225,6 +225,9 @@ config ARCH_DISCONTIGMEM_ENABLE
 	depends on CHIP_M32700 || CHIP_M32102 || CHIP_VDEC2 || CHIP_OPSP || CHIP_M32104
 	default y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 config IRAM_START
diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 65db226..53b36a8 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -396,6 +396,9 @@ config NODES_SHIFT
 	default "3"
 	depends on !SINGLE_MEMORY_CHUNK
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 endmenu
diff --git a/arch/m68knommu/Kconfig b/arch/m68knommu/Kconfig
index 07eb4c4..7e921a3 100644
--- a/arch/m68knommu/Kconfig
+++ b/arch/m68knommu/Kconfig
@@ -671,6 +671,9 @@ config ROMKERNEL
 
 endchoice
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 endmenu
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 8724ed3..7c5a3c2 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -1736,6 +1736,9 @@ config NODES_SHIFT
 	default "6"
 	depends on NEED_MULTIPLE_NODES
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 config SMP
diff --git a/arch/mn10300/Kconfig b/arch/mn10300/Kconfig
index 6a6409a..a20b8f6 100644
--- a/arch/mn10300/Kconfig
+++ b/arch/mn10300/Kconfig
@@ -353,6 +353,9 @@ config MN10300_TTYSM2_CTS
 
 endmenu
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 menu "Power management options"
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index bc7a19d..9ec4fcd 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -240,6 +240,9 @@ config NODES_SHIFT
 	default "3"
 	depends on NEED_MULTIPLE_NODES
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "kernel/Kconfig.preempt"
 source "kernel/Kconfig.hz"
 source "mm/Kconfig"
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 1189d8d..8950e0c 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -350,6 +350,9 @@ config ARCH_SPARSEMEM_DEFAULT
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 config ARCH_MEMORY_PROBE
diff --git a/arch/ppc/Kconfig b/arch/ppc/Kconfig
index abc877f..db5e6a1 100644
--- a/arch/ppc/Kconfig
+++ b/arch/ppc/Kconfig
@@ -924,6 +924,9 @@ config HIGHMEM
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source kernel/Kconfig.hz
 source kernel/Kconfig.preempt
 source "mm/Kconfig"
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 1831833..6fb2b79 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -282,6 +282,9 @@ config WARN_STACK_SIZE
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 comment "Kernel preemption"
 
 source "kernel/Kconfig.preempt"
diff --git a/arch/sh/mm/Kconfig b/arch/sh/mm/Kconfig
index 5fd2184..b74c4e7 100644
--- a/arch/sh/mm/Kconfig
+++ b/arch/sh/mm/Kconfig
@@ -138,6 +138,9 @@ config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 choice
 	prompt "Kernel page size"
 	default PAGE_SIZE_8KB if X2TLB
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index c40343c..8fc06c3 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -266,6 +266,9 @@ config SUNOS_EMUL
 	  want to run SunOS binaries on an Ultra you must also say Y to
 	  "Kernel support for 32-bit a.out binaries" above.
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 endmenu
diff --git a/arch/sparc64/Kconfig b/arch/sparc64/Kconfig
index 463d1be..d74b027 100644
--- a/arch/sparc64/Kconfig
+++ b/arch/sparc64/Kconfig
@@ -267,6 +267,9 @@ config ARCH_SPARSEMEM_ENABLE
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 config ISA
diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index dba8e05..f3b75af 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -86,6 +86,10 @@ config STATIC_LINK
 	  2.75G) for UML.
 
 source "arch/um/Kconfig.arch"
+
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 source "kernel/time/Kconfig"
 
diff --git a/arch/v850/Kconfig b/arch/v850/Kconfig
index 4379f43..a4d8e72 100644
--- a/arch/v850/Kconfig
+++ b/arch/v850/Kconfig
@@ -56,6 +56,9 @@ config ARCH_HAS_ILOG2_U64
 config ARCH_SUPPORTS_AOUT
 	def_bool y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 # Turn off some random 386 crap that can affect device config
 config ISA
 	bool
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 6c70fed..47bb585 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -939,6 +939,9 @@ config ARCH_MEMORY_PROBE
 	def_bool X86_64
 	depends on MEMORY_HOTPLUG
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 config HIGHPTE
diff --git a/arch/xtensa/Kconfig b/arch/xtensa/Kconfig
index 9fc8551..0e3b68c 100644
--- a/arch/xtensa/Kconfig
+++ b/arch/xtensa/Kconfig
@@ -163,6 +163,9 @@ config XTENSA_ISS_NETWORK
 	depends on XTENSA_PLATFORM_ISS
 	default y
 
+config HAVE_ARCH_SHOW_MEM
+	def_bool y
+
 source "mm/Kconfig"
 
 endmenu
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 402a504..0eef95f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -45,6 +45,7 @@
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
 #include <linux/memcontrol.h>
+#include <linux/nmi.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1889,6 +1890,58 @@ void show_free_areas(void)
 	show_swap_cache_info();
 }
 
+#ifndef CONFIG_HAVE_ARCH_SHOW_MEM
+void show_mem(void)
+{
+	pg_data_t *pgdat;
+	int total = 0, reserved = 0, shared = 0, highmem = 0, swapcache = 0;
+
+	printk(KERN_INFO "Mem-Info:\n");
+	show_free_areas();
+
+	for_each_online_pgdat(pgdat) {
+		unsigned long i, flags;
+
+		pgdat_resize_lock(pgdat, &flags);
+		for (i = 0; i < pgdat->node_spanned_pages; i++) {
+			struct page *page;
+			unsigned long pfn = pgdat->node_start_pfn + i;
+
+			if (unlikely((i % MAX_ORDER_NR_PAGES) == 0))
+				touch_nmi_watchdog();
+
+			if (!pfn_valid(pfn))
+				continue;
+
+			page = pfn_to_page(pfn);
+
+			if (PageHighMem(page))
+				highmem++;
+
+			if (PageReserved(page))
+				reserved++;
+			else if (PageSwapCache(page))
+				swapcache++;
+			else if (page_count(page) > 1)
+				shared += page_count(page) - 1;
+
+			total++;
+		}
+		pgdat_resize_unlock(pgdat, &flags);
+	}
+
+	printk(KERN_INFO "%d pages RAM\n", total);
+#ifdef CONFIG_HIGHMEM
+	printk(KERN_INFO "%d pages HighMem\n", highmem);
+#endif
+	printk(KERN_INFO "%d pages reserved\n", reserved);
+	printk(KERN_INFO "%d pages shared\n", shared);
+#ifdef CONFIG_SWAP
+	printk(KERN_INFO "%d pages swapcache\n", swapcache);
+#endif
+}
+#endif /* !CONFIG_HAVE_ARCH_SHOW_MEM */
+
 /*
  * Builds allocation fallback zone lists.
  *
-- 
1.5.2.2
