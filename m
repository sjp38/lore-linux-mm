Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2PLsqua456782
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 16:54:52 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2PLsqMu178342
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 14:54:52 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2PLspwE026331
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 14:54:51 -0700
Subject: [RFC][PATCH 3/4] update all defconfigs for ARCH_DISCONTIGMEM_ENABLE
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 25 Mar 2005 13:54:50 -0800
Message-Id: <E1DEwlW-0006Nz-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

This will at least suppress one prompt that users would have
received the first time they compile with the new DISCONTIG
arch option.  They'll still get the "Memory Model" prompt,
but 99% of them will have the default work there.
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 arch/x86_64/defconfig                                |    0 
 memhotplug-dave/arch/alpha/defconfig                 |    2 +-
 memhotplug-dave/arch/ia64/configs/sn2_defconfig      |    2 +-
 memhotplug-dave/arch/ia64/defconfig                  |    2 +-
 memhotplug-dave/arch/mips/configs/ip27_defconfig     |    2 +-
 memhotplug-dave/arch/ppc64/configs/pSeries_defconfig |    2 +-
 memhotplug-dave/arch/ppc64/defconfig                 |    2 +-
 7 files changed, 6 insertions(+), 6 deletions(-)

diff -puN arch/alpha/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/alpha/defconfig
--- memhotplug/arch/alpha/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG	2005-03-25 08:08:24.000000000 -0800
+++ memhotplug-dave/arch/alpha/defconfig	2005-03-25 08:08:24.000000000 -0800
@@ -96,7 +96,7 @@ CONFIG_ALPHA_CORE_AGP=y
 CONFIG_ALPHA_BROKEN_IRQ_MASK=y
 CONFIG_EISA=y
 # CONFIG_SMP is not set
-# CONFIG_DISCONTIGMEM is not set
+# CONFIG_ARCH_DISCONTIGMEM_ENABLE is not set
 CONFIG_VERBOSE_MCHECK=y
 CONFIG_VERBOSE_MCHECK_ON=1
 CONFIG_PCI_LEGACY_PROC=y
diff -puN arch/arm/configs/a5k_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/a5k_defconfig
diff -puN arch/arm/configs/assabet_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/assabet_defconfig
diff -puN arch/arm/configs/badge4_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/badge4_defconfig
diff -puN arch/arm/configs/cerfcube_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/cerfcube_defconfig
diff -puN arch/arm/configs/clps7500_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/clps7500_defconfig
diff -puN arch/arm/configs/edb7211_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/edb7211_defconfig
diff -puN arch/arm/configs/footbridge_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/footbridge_defconfig
diff -puN arch/arm/configs/fortunet_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/fortunet_defconfig
diff -puN arch/arm/configs/h3600_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/h3600_defconfig
diff -puN arch/arm/configs/hackkit_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/hackkit_defconfig
diff -puN arch/arm/configs/jornada720_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/jornada720_defconfig
diff -puN arch/arm/configs/lart_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/lart_defconfig
diff -puN arch/arm/configs/lpd7a400_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/lpd7a400_defconfig
diff -puN arch/arm/configs/lpd7a404_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/lpd7a404_defconfig
diff -puN arch/arm/configs/lusl7200_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/lusl7200_defconfig
diff -puN arch/arm/configs/neponset_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/neponset_defconfig
diff -puN arch/arm/configs/omnimeter_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/omnimeter_defconfig
diff -puN arch/arm/configs/pleb_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/pleb_defconfig
diff -puN arch/arm/configs/shannon_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/shannon_defconfig
diff -puN arch/arm/configs/simpad_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/arm/configs/simpad_defconfig
diff -puN arch/ia64/configs/sn2_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/ia64/configs/sn2_defconfig
--- memhotplug/arch/ia64/configs/sn2_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG	2005-03-25 08:08:24.000000000 -0800
+++ memhotplug-dave/arch/ia64/configs/sn2_defconfig	2005-03-25 08:08:24.000000000 -0800
@@ -78,7 +78,7 @@ CONFIG_IA64_L1_CACHE_SHIFT=7
 CONFIG_NUMA=y
 CONFIG_VIRTUAL_MEM_MAP=y
 CONFIG_HOLES_IN_ZONE=y
-CONFIG_DISCONTIGMEM=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 # CONFIG_IA64_CYCLONE is not set
 CONFIG_IOSAPIC=y
 CONFIG_IA64_SGI_SN_SIM=y
diff -puN arch/ia64/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/ia64/defconfig
--- memhotplug/arch/ia64/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG	2005-03-25 08:08:24.000000000 -0800
+++ memhotplug-dave/arch/ia64/defconfig	2005-03-25 08:08:24.000000000 -0800
@@ -77,7 +77,7 @@ CONFIG_IA64_PAGE_SIZE_16KB=y
 CONFIG_IA64_L1_CACHE_SHIFT=7
 CONFIG_NUMA=y
 CONFIG_VIRTUAL_MEM_MAP=y
-CONFIG_DISCONTIGMEM=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_IA64_CYCLONE=y
 CONFIG_IOSAPIC=y
 CONFIG_FORCE_MAX_ZONEORDER=18
diff -puN arch/m32r/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/defconfig
diff -puN arch/m32r/m32700ut/defconfig.m32700ut.smp~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/m32700ut/defconfig.m32700ut.smp
diff -puN arch/m32r/m32700ut/defconfig.m32700ut.up~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/m32700ut/defconfig.m32700ut.up
diff -puN arch/m32r/mappi/defconfig.nommu~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/mappi/defconfig.nommu
diff -puN arch/m32r/mappi/defconfig.smp~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/mappi/defconfig.smp
diff -puN arch/m32r/mappi/defconfig.up~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/mappi/defconfig.up
diff -puN arch/m32r/mappi2/defconfig.vdec2~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/mappi2/defconfig.vdec2
diff -puN arch/m32r/oaks32r/defconfig.nommu~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/oaks32r/defconfig.nommu
diff -puN arch/m32r/opsput/defconfig.opsput~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/m32r/opsput/defconfig.opsput
diff -puN arch/mips/configs/ip27_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/mips/configs/ip27_defconfig
--- memhotplug/arch/mips/configs/ip27_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG	2005-03-25 08:08:24.000000000 -0800
+++ memhotplug-dave/arch/mips/configs/ip27_defconfig	2005-03-25 08:08:24.000000000 -0800
@@ -82,7 +82,7 @@ CONFIG_STOP_MACHINE=y
 # CONFIG_SGI_IP22 is not set
 CONFIG_SGI_IP27=y
 # CONFIG_SGI_SN0_N_MODE is not set
-CONFIG_DISCONTIGMEM=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_NUMA=y
 # CONFIG_MAPPED_KERNEL is not set
 # CONFIG_REPLICATE_KTEXT is not set
diff -puN arch/parisc/configs/712_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/parisc/configs/712_defconfig
diff -puN arch/parisc/configs/a500_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/parisc/configs/a500_defconfig
diff -puN arch/parisc/configs/c3000_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/parisc/configs/c3000_defconfig
diff -puN arch/ppc64/configs/pSeries_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/ppc64/configs/pSeries_defconfig
--- memhotplug/arch/ppc64/configs/pSeries_defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG	2005-03-25 08:08:24.000000000 -0800
+++ memhotplug-dave/arch/ppc64/configs/pSeries_defconfig	2005-03-25 08:08:24.000000000 -0800
@@ -82,7 +82,7 @@ CONFIG_IBMVIO=y
 CONFIG_IOMMU_VMERGE=y
 CONFIG_SMP=y
 CONFIG_NR_CPUS=128
-CONFIG_DISCONTIGMEM=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_NUMA=y
 CONFIG_SCHED_SMT=y
 # CONFIG_PREEMPT is not set
diff -puN arch/ppc64/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/ppc64/defconfig
--- memhotplug/arch/ppc64/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG	2005-03-25 08:08:24.000000000 -0800
+++ memhotplug-dave/arch/ppc64/defconfig	2005-03-25 08:08:24.000000000 -0800
@@ -84,7 +84,7 @@ CONFIG_BOOTX_TEXT=y
 CONFIG_IOMMU_VMERGE=y
 CONFIG_SMP=y
 CONFIG_NR_CPUS=32
-CONFIG_DISCONTIGMEM=y
+CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 # CONFIG_NUMA is not set
 # CONFIG_SCHED_SMT is not set
 # CONFIG_PREEMPT is not set
diff -puN arch/x86_64/defconfig~A8-update-all-defconfigs-for-ARCH...DISCONTIG arch/x86_64/defconfig
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
