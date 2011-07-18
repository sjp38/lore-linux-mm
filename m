Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 836109000C2
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 07:19:08 -0400 (EDT)
From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] mm: make CONFIG_NUMA depend on CONFIG_SYSFS
Date: Mon, 18 Jul 2011 19:18:29 +0800
Message-Id: <1310987909-3129-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, WANG Cong <amwang@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On ppc, we got this build error with randconfig:

drivers/built-in.o:(.toc1+0xf90): undefined reference to `vmstat_text': 1 errors in 1 logs

This is due to that it enabled CONFIG_NUMA but not CONFIG_SYSFS.

And the user-space tool numactl depends on sysfs files too.
So, I think it is very reasonable to make CONFIG_NUMA depend on CONFIG_SYSFS.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org


---
 arch/alpha/Kconfig   |    1 +
 arch/ia64/Kconfig    |    1 +
 arch/m32r/Kconfig    |    1 +
 arch/mips/Kconfig    |    1 +
 arch/powerpc/Kconfig |    1 +
 arch/sh/mm/Kconfig   |    1 +
 arch/sparc/Kconfig   |    1 +
 arch/tile/Kconfig    |    1 +
 arch/x86/Kconfig     |    1 +
 9 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 60219bf..44439ec 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -570,6 +570,7 @@ source "mm/Kconfig"
 config NUMA
 	bool "NUMA Support (EXPERIMENTAL)"
 	depends on DISCONTIGMEM && BROKEN
+	depends on SYSFS
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 38280ef..b12fac3 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -450,6 +450,7 @@ config ARCH_DISCONTIGMEM_DEFAULT
 config NUMA
 	bool "NUMA support"
 	depends on !IA64_HP_SIM && !FLATMEM
+	depends on SYSFS
 	default y if IA64_SGI_SN2
 	select ACPI_NUMA if ACPI
 	help
diff --git a/arch/m32r/Kconfig b/arch/m32r/Kconfig
index 85b44e8..21e668d 100644
--- a/arch/m32r/Kconfig
+++ b/arch/m32r/Kconfig
@@ -325,6 +325,7 @@ config NR_CPUS
 config NUMA
 	bool "Numa Memory Allocation Support"
 	depends on SMP && BROKEN
+	depends on SYSFS
 	default n
 
 config NODES_SHIFT
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 653da62..760d0d6 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -2072,6 +2072,7 @@ config ARCH_SPARSEMEM_ENABLE
 config NUMA
 	bool "NUMA Support"
 	depends on SYS_SUPPORTS_NUMA
+	depends on SYSFS
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option improves performance on systems with more
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2729c66..32e1bc1 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -392,6 +392,7 @@ config IRQ_ALL_CPUS
 config NUMA
 	bool "NUMA support"
 	depends on PPC64
+	depends on SYSFS
 	default y if SMP && PPC_PSERIES
 
 config NODES_SHIFT
diff --git a/arch/sh/mm/Kconfig b/arch/sh/mm/Kconfig
index c3e61b3..7928c9a 100644
--- a/arch/sh/mm/Kconfig
+++ b/arch/sh/mm/Kconfig
@@ -111,6 +111,7 @@ config VSYSCALL
 config NUMA
 	bool "Non Uniform Memory Access (NUMA) Support"
 	depends on MMU && SYS_SUPPORTS_NUMA && EXPERIMENTAL
+	depends on SYSFS
 	default n
 	help
 	  Some SH systems have many various memories scattered around
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 253986b..2a38c5d 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -338,6 +338,7 @@ endchoice
 config NUMA
 	bool "NUMA support"
 	depends on SPARC64 && SMP
+	depends on SYSFS
 
 config NODES_SHIFT
 	int
diff --git a/arch/tile/Kconfig b/arch/tile/Kconfig
index 0249b8b..fa7d219 100644
--- a/arch/tile/Kconfig
+++ b/arch/tile/Kconfig
@@ -187,6 +187,7 @@ config HIGHMEM
 config NUMA
 	bool # "NUMA Memory Allocation and Scheduler Support"
 	depends on SMP && DISCONTIGMEM
+	depends on SYSFS
 	default y
 	---help---
 	  NUMA memory allocation is required for TILE processors
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index da34972..be0c229 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1146,6 +1146,7 @@ config DIRECT_GBPAGES
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
 	depends on SMP
+	depends on SYSFS
 	depends on X86_64 || (X86_32 && HIGHMEM64G && (X86_NUMAQ || X86_BIGSMP || X86_SUMMIT && ACPI) && EXPERIMENTAL)
 	default y if (X86_NUMAQ || X86_SUMMIT || X86_BIGSMP)
 	---help---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
