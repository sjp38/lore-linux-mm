Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 440F88E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:49:53 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x7so27528213pll.23
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 09:49:53 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d8si15638076pln.128.2019.01.04.09.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 09:49:51 -0800 (PST)
From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: [PATCH 4/5] x86/mpx: remove build infratsructure
Date: Fri,  4 Jan 2019 09:49:42 -0800
Message-Id: <1546624183-26543-5-git-send-email-dave.hansen@linux.intel.com>
In-Reply-To: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
References: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

MPX is being removed from the kernel due to a lack of support
in the toolchain going forward (gcc).

Remove the Kconfig option and the Makefile line.  This makes
arch/x86/mm/mpx.c and anything under an #ifdef for
X86_INTEL_MPX dead code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 arch/x86/Kconfig     | 28 ----------------------------
 arch/x86/mm/Makefile |  1 -
 2 files changed, 29 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e260460..b668833 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1880,34 +1880,6 @@ config X86_INTEL_UMIP
 	  specific cases in protected and virtual-8086 modes. Emulated
 	  results are dummy.
 
-config X86_INTEL_MPX
-	prompt "Intel MPX (Memory Protection Extensions)"
-	def_bool n
-	# Note: only available in 64-bit mode due to VMA flags shortage
-	depends on CPU_SUP_INTEL && X86_64
-	select ARCH_USES_HIGH_VMA_FLAGS
-	---help---
-	  MPX provides hardware features that can be used in
-	  conjunction with compiler-instrumented code to check
-	  memory references.  It is designed to detect buffer
-	  overflow or underflow bugs.
-
-	  This option enables running applications which are
-	  instrumented or otherwise use MPX.  It does not use MPX
-	  itself inside the kernel or to protect the kernel
-	  against bad memory references.
-
-	  Enabling this option will make the kernel larger:
-	  ~8k of kernel text and 36 bytes of data on a 64-bit
-	  defconfig.  It adds a long to the 'mm_struct' which
-	  will increase the kernel memory overhead of each
-	  process and adds some branches to paths used during
-	  exec() and munmap().
-
-	  For details, see Documentation/x86/intel_mpx.txt
-
-	  If unsure, say N.
-
 config X86_INTEL_MEMORY_PROTECTION_KEYS
 	prompt "Intel Memory Protection Keys"
 	def_bool y
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd..8cc3639 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -45,7 +45,6 @@ obj-$(CONFIG_AMD_NUMA)		+= amdtopology.o
 obj-$(CONFIG_ACPI_NUMA)		+= srat.o
 obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 
-obj-$(CONFIG_X86_INTEL_MPX)			+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)	+= pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY)			+= kaslr.o
 obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
-- 
2.7.4
