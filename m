From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20080118153549.12646.1915.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/2] Do not require CONFIG_HIGHMEM64G to set CONFIG_NUMA on x86
Date: Fri, 18 Jan 2008 15:35:49 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: linux-mm@kvack.org, apw@shadowen.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

There is nothing inherent in HIGHMEM64G required for CONFIG_NUMA to work. It
just limits potential testing coverage so remove the limitation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 arch/x86/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc8-fix-numa-boot/arch/x86/Kconfig linux-2.6.24-rc8-005_non64GB/arch/x86/Kconfig
--- linux-2.6.24-rc8-fix-numa-boot/arch/x86/Kconfig	2008-01-16 04:22:48.000000000 +0000
+++ linux-2.6.24-rc8-005_non64GB/arch/x86/Kconfig	2008-01-17 18:22:26.000000000 +0000
@@ -817,7 +817,7 @@ config X86_PAE
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support (EXPERIMENTAL)"
 	depends on SMP
-	depends on X86_64 || (X86_32 && HIGHMEM64G && (X86_NUMAQ || (X86_SUMMIT || X86_GENERICARCH) && ACPI) && EXPERIMENTAL)
+	depends on X86_64 || (X86_32 && (X86_NUMAQ || (X86_SUMMIT || X86_GENERICARCH) && ACPI) && EXPERIMENTAL)
 	default n if X86_PC
 	default y if (X86_NUMAQ || X86_SUMMIT)
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
