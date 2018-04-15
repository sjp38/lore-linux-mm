Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9A8A6B0011
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 11:00:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i128so7891862pfg.2
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 08:00:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v14si7969262pgq.266.2018.04.15.08.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 15 Apr 2018 08:00:21 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/12] dma-mapping: move the NEED_DMA_MAP_STATE config symbol to lib/Kconfig
Date: Sun, 15 Apr 2018 16:59:41 +0200
Message-Id: <20180415145947.1248-7-hch@lst.de>
In-Reply-To: <20180415145947.1248-1-hch@lst.de>
References: <20180415145947.1248-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: x86@kernel.org, linux-block@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-ide@vger.kernel.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

This way we have one central definition of it, and user can select it as
needed.  Note that we now also always select it when CONFIG_DMA_API_DEBUG
is select, which fixes some incorrect checks in a few network drivers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/Kconfig          | 4 +---
 arch/arm/Kconfig            | 4 +---
 arch/arm64/Kconfig          | 4 +---
 arch/ia64/Kconfig           | 4 +---
 arch/mips/Kconfig           | 3 ---
 arch/parisc/Kconfig         | 4 +---
 arch/s390/Kconfig           | 4 +---
 arch/sh/Kconfig             | 4 +---
 arch/sparc/Kconfig          | 4 +---
 arch/unicore32/Kconfig      | 4 +---
 arch/x86/Kconfig            | 6 ++----
 drivers/iommu/Kconfig       | 1 +
 include/linux/dma-mapping.h | 2 +-
 lib/Kconfig                 | 3 +++
 lib/Kconfig.debug           | 1 +
 15 files changed, 17 insertions(+), 35 deletions(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 8e6a67ecf069..1fd9645b0c67 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -10,6 +10,7 @@ config ALPHA
 	select HAVE_OPROFILE
 	select HAVE_PCSPKR_PLATFORM
 	select HAVE_PERF_EVENTS
+	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 	select VIRT_TO_BUS
 	select GENERIC_IRQ_PROBE
@@ -68,9 +69,6 @@ config ZONE_DMA
 config ARCH_DMA_ADDR_T_64BIT
 	def_bool y
 
-config NEED_DMA_MAP_STATE
-       def_bool y
-
 config GENERIC_ISA_DMA
 	bool
 	default y
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 602c8320282f..aa1c187d756d 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -96,6 +96,7 @@ config ARM
 	select HAVE_VIRT_CPU_ACCOUNTING_GEN
 	select IRQ_FORCED_THREADING
 	select MODULES_USE_ELF_REL
+	select NEED_DMA_MAP_STATE
 	select NO_BOOTMEM
 	select OF_EARLY_FLATTREE if OF
 	select OF_RESERVED_MEM if OF
@@ -221,9 +222,6 @@ config ARCH_MAY_HAVE_PC_FDC
 config ZONE_DMA
 	bool
 
-config NEED_DMA_MAP_STATE
-       def_bool y
-
 config ARCH_SUPPORTS_UPROBES
 	def_bool y
 
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3b441c5587f1..940adfb9a2bc 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -133,6 +133,7 @@ config ARM64
 	select IRQ_FORCED_THREADING
 	select MODULES_USE_ELF_RELA
 	select MULTI_IRQ_HANDLER
+	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 	select NO_BOOTMEM
 	select OF
@@ -241,9 +242,6 @@ config HAVE_GENERIC_GUP
 config ARCH_DMA_ADDR_T_64BIT
 	def_bool y
 
-config NEED_DMA_MAP_STATE
-	def_bool y
-
 config SMP
 	def_bool y
 
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 333917676f7f..0e42731adaf1 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -54,6 +54,7 @@ config IA64
 	select MODULES_USE_ELF_RELA
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_AUDITSYSCALL
+	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 	default y
 	help
@@ -82,9 +83,6 @@ config MMU
 config ARCH_DMA_ADDR_T_64BIT
 	def_bool y
 
-config NEED_DMA_MAP_STATE
-	def_bool y
-
 config SWIOTLB
        bool
 
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 225c95da23ce..47d72c64d687 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -1122,9 +1122,6 @@ config DMA_NONCOHERENT
 	bool
 	select NEED_DMA_MAP_STATE
 
-config NEED_DMA_MAP_STATE
-	bool
-
 config SYS_HAS_EARLY_PRINTK
 	bool
 
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 491912f9b978..47047f0cbe35 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -51,6 +51,7 @@ config PARISC
 	select GENERIC_CLOCKEVENTS
 	select ARCH_NO_COHERENT_DMA_MMAP
 	select CPU_NO_EFFICIENT_FFS
+	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 
 	help
@@ -112,9 +113,6 @@ config PM
 config STACKTRACE_SUPPORT
 	def_bool y
 
-config NEED_DMA_MAP_STATE
-	def_bool y
-
 config ISA_DMA_API
 	bool
 
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 4fa47b1445a2..f682dd8d381d 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -695,6 +695,7 @@ menuconfig PCI
 	select PCI_MSI
 	select IOMMU_HELPER
 	select IOMMU_SUPPORT
+	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 
 	help
@@ -720,9 +721,6 @@ config PCI_DOMAINS
 config HAS_IOMEM
 	def_bool PCI
 
-config NEED_DMA_MAP_STATE
-	def_bool PCI
-
 config CHSC_SCH
 	def_tristate m
 	prompt "Support for CHSC subchannels"
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index e127e0cbe30f..9417f70e008e 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -50,6 +50,7 @@ config SUPERH
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
+	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 
 	help
@@ -162,9 +163,6 @@ config DMA_COHERENT
 config DMA_NONCOHERENT
 	def_bool !DMA_COHERENT
 
-config NEED_DMA_MAP_STATE
-	def_bool DMA_NONCOHERENT
-
 config PGTABLE_LEVELS
 	default 3 if X2TLB
 	default 2
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index e79badc8a682..be770b511ddd 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -44,6 +44,7 @@ config SPARC
 	select ARCH_HAS_SG_CHAIN
 	select CPU_NO_EFFICIENT_FFS
 	select LOCKDEP_SMALL if LOCKDEP
+	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 
 config SPARC32
@@ -144,9 +145,6 @@ config ZONE_DMA
 	bool
 	default y if SPARC32
 
-config NEED_DMA_MAP_STATE
-	def_bool y
-
 config GENERIC_ISA_DMA
 	bool
 	default y if SPARC32
diff --git a/arch/unicore32/Kconfig b/arch/unicore32/Kconfig
index 462e59a7ae78..82195714d20b 100644
--- a/arch/unicore32/Kconfig
+++ b/arch/unicore32/Kconfig
@@ -19,6 +19,7 @@ config UNICORE32
 	select ARCH_WANT_FRAME_POINTERS
 	select GENERIC_IOMAP
 	select MODULES_USE_ELF_REL
+	select NEED_DMA_MAP_STATE
 	help
 	  UniCore-32 is 32-bit Instruction Set Architecture,
 	  including a series of low-power-consumption RISC chip
@@ -61,9 +62,6 @@ config ARCH_MAY_HAVE_PC_FDC
 config ZONE_DMA
 	def_bool y
 
-config NEED_DMA_MAP_STATE
-       def_bool y
-
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 491a723bc2b3..414043303ea1 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -28,6 +28,7 @@ config X86_64
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_SOFT_DIRTY
 	select MODULES_USE_ELF_RELA
+	select NEED_DMA_MAP_STATE
 	select X86_DEV_DMA_OPS
 
 #
@@ -235,10 +236,6 @@ config ARCH_MMAP_RND_COMPAT_BITS_MAX
 config SBUS
 	bool
 
-config NEED_DMA_MAP_STATE
-	def_bool y
-	depends on X86_64 || INTEL_IOMMU || DMA_API_DEBUG || SWIOTLB
-
 config GENERIC_ISA_DMA
 	def_bool y
 	depends on ISA_DMA_API
@@ -921,6 +918,7 @@ config CALGARY_IOMMU_ENABLED_BY_DEFAULT
 # need this always selected by IOMMU for the VIA workaround
 config SWIOTLB
 	def_bool y if X86_64
+	select NEED_DMA_MAP_STATE
 	---help---
 	  Support for software bounce buffers used on x86-64 systems
 	  which don't have a hardware IOMMU. Using this PCI devices
diff --git a/drivers/iommu/Kconfig b/drivers/iommu/Kconfig
index df171cb85822..5b714a062fa7 100644
--- a/drivers/iommu/Kconfig
+++ b/drivers/iommu/Kconfig
@@ -146,6 +146,7 @@ config INTEL_IOMMU
 	select DMA_DIRECT_OPS
 	select IOMMU_API
 	select IOMMU_IOVA
+	select NEED_DMA_MAP_STATE
 	select DMAR_TABLE
 	help
 	  DMA remapping (DMAR) devices support enables independent address
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index f8ab1c0f589e..14269d25498b 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -839,7 +839,7 @@ static inline int dma_mmap_wc(struct device *dev,
 #define dma_mmap_writecombine dma_mmap_wc
 #endif
 
-#if defined(CONFIG_NEED_DMA_MAP_STATE) || defined(CONFIG_DMA_API_DEBUG)
+#ifdef CONFIG_NEED_DMA_MAP_STATE
 #define DEFINE_DMA_UNMAP_ADDR(ADDR_NAME)        dma_addr_t ADDR_NAME
 #define DEFINE_DMA_UNMAP_LEN(LEN_NAME)          __u32 LEN_NAME
 #define dma_unmap_addr(PTR, ADDR_NAME)           ((PTR)->ADDR_NAME)
diff --git a/lib/Kconfig b/lib/Kconfig
index aeb7fae16bc2..ce9fa962d59b 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -432,6 +432,9 @@ config SGL_ALLOC
 config NEED_SG_DMA_LENGTH
 	bool
 
+config NEED_DMA_MAP_STATE
+	bool
+
 config IOMMU_HELPER
 	bool
 
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index c40c7b734cd1..685ed2dd4384 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1635,6 +1635,7 @@ config PROVIDE_OHCI1394_DMA_INIT
 config DMA_API_DEBUG
 	bool "Enable debugging of DMA-API usage"
 	depends on HAVE_DMA_API_DEBUG
+	select NEED_DMA_MAP_STATE
 	help
 	  Enable this option to debug the use of the DMA API by device drivers.
 	  With this option you will be able to detect common bugs in device
-- 
2.17.0
