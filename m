Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 741E26B0161
	for <linux-mm@kvack.org>; Wed, 13 May 2009 22:15:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E2FpgF025918
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 11:15:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 722B245DD7B
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:15:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 424E845DD7D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:15:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E00F51DB8038
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:15:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33D78E08003
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:15:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/2] remove CONFIG_UNEVICTABLE_LRU definition from defconfig
In-Reply-To: <20090514110357.9B54.A69D9226@jp.fujitsu.com>
References: <20090514110357.9B54.A69D9226@jp.fujitsu.com>
Message-Id: <20090514111519.9B5D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 11:15:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] remove CONFIG_UNEVICTABLE_LRU definition from defconfig

Now, There isn't CONFIG_UNEVICTABLE_LRU. these line are unnecessary.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>
---
 arch/arm/configs/cm_x2xx_defconfig                |    1 -
 arch/arm/configs/colibri_pxa270_defconfig         |    1 -
 arch/arm/configs/colibri_pxa300_defconfig         |    1 -
 arch/arm/configs/davinci_all_defconfig            |    1 -
 arch/arm/configs/em_x270_defconfig                |    1 -
 arch/arm/configs/eseries_pxa_defconfig            |    1 -
 arch/arm/configs/kirkwood_defconfig               |    1 -
 arch/arm/configs/magician_defconfig               |    1 -
 arch/arm/configs/mv78xx0_defconfig                |    1 -
 arch/arm/configs/mx1_defconfig                    |    1 -
 arch/arm/configs/mx27_defconfig                   |    1 -
 arch/arm/configs/mx31pdk_defconfig                |    1 -
 arch/arm/configs/mx3_defconfig                    |    1 -
 arch/arm/configs/omap3_pandora_defconfig          |    1 -
 arch/arm/configs/omap_3430sdp_defconfig           |    1 -
 arch/arm/configs/orion5x_defconfig                |    1 -
 arch/arm/configs/pxa168_defconfig                 |    1 -
 arch/arm/configs/pxa910_defconfig                 |    1 -
 arch/arm/configs/realview-smp_defconfig           |    1 -
 arch/arm/configs/realview_defconfig               |    1 -
 arch/arm/configs/rx51_defconfig                   |    1 -
 arch/arm/configs/s3c2410_defconfig                |    1 -
 arch/arm/configs/s3c6400_defconfig                |    1 -
 arch/arm/configs/shark_defconfig                  |    1 -
 arch/arm/configs/stmp378x_defconfig               |    1 -
 arch/arm/configs/stmp37xx_defconfig               |    1 -
 arch/avr32/configs/atstk1006_defconfig            |    1 -
 arch/avr32/configs/hammerhead_defconfig           |    1 -
 arch/avr32/configs/merisc_defconfig               |    1 -
 arch/ia64/configs/generic_defconfig               |    1 -
 arch/ia64/configs/xen_domu_defconfig              |    1 -
 arch/m68k/configs/amiga_defconfig                 |    1 -
 arch/m68k/configs/apollo_defconfig                |    1 -
 arch/m68k/configs/atari_defconfig                 |    1 -
 arch/m68k/configs/bvme6000_defconfig              |    1 -
 arch/m68k/configs/hp300_defconfig                 |    1 -
 arch/m68k/configs/mac_defconfig                   |    1 -
 arch/m68k/configs/multi_defconfig                 |    1 -
 arch/m68k/configs/mvme147_defconfig               |    1 -
 arch/m68k/configs/mvme16x_defconfig               |    1 -
 arch/m68k/configs/q40_defconfig                   |    1 -
 arch/m68k/configs/sun3_defconfig                  |    1 -
 arch/m68k/configs/sun3x_defconfig                 |    1 -
 arch/m68knommu/configs/m5208evb_defconfig         |    1 -
 arch/m68knommu/configs/m5249evb_defconfig         |    1 -
 arch/m68knommu/configs/m5272c3_defconfig          |    1 -
 arch/m68knommu/configs/m5275evb_defconfig         |    1 -
 arch/m68knommu/configs/m5307c3_defconfig          |    1 -
 arch/m68knommu/configs/m5407c3_defconfig          |    1 -
 arch/mips/configs/cavium-octeon_defconfig         |    1 -
 arch/mips/configs/fulong_defconfig                |    1 -
 arch/mips/configs/ip22_defconfig                  |    1 -
 arch/mips/configs/ip32_defconfig                  |    1 -
 arch/mips/configs/jmr3927_defconfig               |    1 -
 arch/mips/configs/malta_defconfig                 |    1 -
 arch/mips/configs/rbtx49xx_defconfig              |    1 -
 arch/mn10300/configs/asb2303_defconfig            |    1 -
 arch/parisc/configs/712_defconfig                 |    1 -
 arch/parisc/configs/a500_defconfig                |    1 -
 arch/parisc/configs/b180_defconfig                |    1 -
 arch/parisc/configs/c3000_defconfig               |    1 -
 arch/parisc/configs/default_defconfig             |    1 -
 arch/powerpc/configs/40x/acadia_defconfig         |    1 -
 arch/powerpc/configs/40x/ep405_defconfig          |    1 -
 arch/powerpc/configs/40x/hcu4_defconfig           |    1 -
 arch/powerpc/configs/40x/kilauea_defconfig        |    1 -
 arch/powerpc/configs/40x/makalu_defconfig         |    1 -
 arch/powerpc/configs/40x/virtex_defconfig         |    1 -
 arch/powerpc/configs/40x/walnut_defconfig         |    1 -
 arch/powerpc/configs/44x/arches_defconfig         |    1 -
 arch/powerpc/configs/44x/bamboo_defconfig         |    1 -
 arch/powerpc/configs/44x/canyonlands_defconfig    |    1 -
 arch/powerpc/configs/44x/ebony_defconfig          |    1 -
 arch/powerpc/configs/44x/katmai_defconfig         |    1 -
 arch/powerpc/configs/44x/rainier_defconfig        |    1 -
 arch/powerpc/configs/44x/redwood_defconfig        |    1 -
 arch/powerpc/configs/44x/sam440ep_defconfig       |    1 -
 arch/powerpc/configs/44x/sequoia_defconfig        |    1 -
 arch/powerpc/configs/44x/taishan_defconfig        |    1 -
 arch/powerpc/configs/44x/virtex5_defconfig        |    1 -
 arch/powerpc/configs/44x/warp_defconfig           |    1 -
 arch/powerpc/configs/52xx/cm5200_defconfig        |    1 -
 arch/powerpc/configs/52xx/lite5200b_defconfig     |    1 -
 arch/powerpc/configs/52xx/motionpro_defconfig     |    1 -
 arch/powerpc/configs/52xx/pcm030_defconfig        |    1 -
 arch/powerpc/configs/52xx/tqm5200_defconfig       |    1 -
 arch/powerpc/configs/83xx/asp8347_defconfig       |    1 -
 arch/powerpc/configs/83xx/mpc8313_rdb_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc8315_rdb_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc832x_mds_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc832x_rdb_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc834x_itx_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig |    1 -
 arch/powerpc/configs/83xx/mpc834x_mds_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc836x_mds_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc836x_rdk_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc837x_mds_defconfig   |    1 -
 arch/powerpc/configs/83xx/mpc837x_rdb_defconfig   |    1 -
 arch/powerpc/configs/83xx/sbc834x_defconfig       |    1 -
 arch/powerpc/configs/85xx/ksi8560_defconfig       |    1 -
 arch/powerpc/configs/85xx/mpc8540_ads_defconfig   |    1 -
 arch/powerpc/configs/85xx/mpc8560_ads_defconfig   |    1 -
 arch/powerpc/configs/85xx/mpc85xx_cds_defconfig   |    1 -
 arch/powerpc/configs/85xx/sbc8548_defconfig       |    1 -
 arch/powerpc/configs/85xx/sbc8560_defconfig       |    1 -
 arch/powerpc/configs/85xx/stx_gp3_defconfig       |    1 -
 arch/powerpc/configs/85xx/tqm8540_defconfig       |    1 -
 arch/powerpc/configs/85xx/tqm8541_defconfig       |    1 -
 arch/powerpc/configs/85xx/tqm8548_defconfig       |    1 -
 arch/powerpc/configs/85xx/tqm8555_defconfig       |    1 -
 arch/powerpc/configs/85xx/tqm8560_defconfig       |    1 -
 arch/powerpc/configs/86xx/gef_ppc9a_defconfig     |    1 -
 arch/powerpc/configs/86xx/gef_sbc310_defconfig    |    1 -
 arch/powerpc/configs/86xx/gef_sbc610_defconfig    |    1 -
 arch/powerpc/configs/86xx/mpc8610_hpcd_defconfig  |    1 -
 arch/powerpc/configs/86xx/mpc8641_hpcn_defconfig  |    1 -
 arch/powerpc/configs/86xx/sbc8641d_defconfig      |    1 -
 arch/powerpc/configs/adder875_defconfig           |    1 -
 arch/powerpc/configs/amigaone_defconfig           |    1 -
 arch/powerpc/configs/c2k_defconfig                |    1 -
 arch/powerpc/configs/chrp32_defconfig             |    1 -
 arch/powerpc/configs/ep8248e_defconfig            |    1 -
 arch/powerpc/configs/ep88xc_defconfig             |    1 -
 arch/powerpc/configs/g5_defconfig                 |    1 -
 arch/powerpc/configs/iseries_defconfig            |    1 -
 arch/powerpc/configs/linkstation_defconfig        |    1 -
 arch/powerpc/configs/maple_defconfig              |    1 -
 arch/powerpc/configs/mgcoge_defconfig             |    1 -
 arch/powerpc/configs/mgsuvd_defconfig             |    1 -
 arch/powerpc/configs/mpc5200_defconfig            |    1 -
 arch/powerpc/configs/mpc7448_hpc2_defconfig       |    1 -
 arch/powerpc/configs/mpc8272_ads_defconfig        |    1 -
 arch/powerpc/configs/mpc83xx_defconfig            |    1 -
 arch/powerpc/configs/mpc85xx_defconfig            |    1 -
 arch/powerpc/configs/mpc85xx_smp_defconfig        |    1 -
 arch/powerpc/configs/mpc866_ads_defconfig         |    1 -
 arch/powerpc/configs/mpc86xx_defconfig            |    1 -
 arch/powerpc/configs/mpc885_ads_defconfig         |    1 -
 arch/powerpc/configs/pmac32_defconfig             |    1 -
 arch/powerpc/configs/ppc40x_defconfig             |    1 -
 arch/powerpc/configs/ppc44x_defconfig             |    1 -
 arch/powerpc/configs/ppc64_defconfig              |    1 -
 arch/powerpc/configs/ppc6xx_defconfig             |    1 -
 arch/powerpc/configs/pq2fads_defconfig            |    1 -
 arch/powerpc/configs/prpmc2800_defconfig          |    1 -
 arch/powerpc/configs/ps3_defconfig                |    1 -
 arch/powerpc/configs/pseries_defconfig            |    1 -
 arch/powerpc/configs/storcenter_defconfig         |    1 -
 arch/s390/defconfig                               |    1 -
 arch/sh/configs/ap325rxa_defconfig                |    1 -
 arch/sh/configs/cayman_defconfig                  |    1 -
 arch/sh/configs/dreamcast_defconfig               |    1 -
 arch/sh/configs/edosk7705_defconfig               |    1 -
 arch/sh/configs/edosk7760_defconfig               |    1 -
 arch/sh/configs/espt_defconfig                    |    1 -
 arch/sh/configs/hp6xx_defconfig                   |    1 -
 arch/sh/configs/landisk_defconfig                 |    1 -
 arch/sh/configs/lboxre2_defconfig                 |    1 -
 arch/sh/configs/magicpanelr2_defconfig            |    1 -
 arch/sh/configs/microdev_defconfig                |    1 -
 arch/sh/configs/migor_defconfig                   |    1 -
 arch/sh/configs/polaris_defconfig                 |    1 -
 arch/sh/configs/r7780mp_defconfig                 |    1 -
 arch/sh/configs/r7785rp_defconfig                 |    1 -
 arch/sh/configs/rsk7201_defconfig                 |    1 -
 arch/sh/configs/rsk7203_defconfig                 |    1 -
 arch/sh/configs/rts7751r2d1_defconfig             |    1 -
 arch/sh/configs/rts7751r2dplus_defconfig          |    1 -
 arch/sh/configs/sdk7780_defconfig                 |    1 -
 arch/sh/configs/se7206_defconfig                  |    1 -
 arch/sh/configs/se7343_defconfig                  |    1 -
 arch/sh/configs/se7619_defconfig                  |    1 -
 arch/sh/configs/se7705_defconfig                  |    1 -
 arch/sh/configs/se7712_defconfig                  |    1 -
 arch/sh/configs/se7721_defconfig                  |    1 -
 arch/sh/configs/se7722_defconfig                  |    1 -
 arch/sh/configs/se7750_defconfig                  |    1 -
 arch/sh/configs/se7751_defconfig                  |    1 -
 arch/sh/configs/se7780_defconfig                  |    1 -
 arch/sh/configs/sh03_defconfig                    |    1 -
 arch/sh/configs/sh7710voipgw_defconfig            |    1 -
 arch/sh/configs/sh7724_generic_defconfig          |    1 -
 arch/sh/configs/sh7763rdp_defconfig               |    1 -
 arch/sh/configs/sh7785lcr_32bit_defconfig         |    1 -
 arch/sh/configs/sh7785lcr_defconfig               |    1 -
 arch/sh/configs/shmin_defconfig                   |    1 -
 arch/sh/configs/shx3_defconfig                    |    1 -
 arch/sh/configs/snapgear_defconfig                |    1 -
 arch/sh/configs/systemh_defconfig                 |    1 -
 arch/sh/configs/titan_defconfig                   |    1 -
 arch/sh/configs/ul2_defconfig                     |    1 -
 arch/sh/configs/urquell_defconfig                 |    1 -
 arch/sparc/configs/sparc32_defconfig              |    1 -
 arch/sparc/configs/sparc64_defconfig              |    1 -
 arch/x86/configs/i386_defconfig                   |    1 -
 arch/x86/configs/x86_64_defconfig                 |    1 -
 196 files changed, 196 deletions(-)

Index: b/arch/arm/configs/cm_x2xx_defconfig
===================================================================
--- a/arch/arm/configs/cm_x2xx_defconfig
+++ b/arch/arm/configs/cm_x2xx_defconfig
@@ -287,7 +287,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/colibri_pxa270_defconfig
===================================================================
--- a/arch/arm/configs/colibri_pxa270_defconfig
+++ b/arch/arm/configs/colibri_pxa270_defconfig
@@ -260,7 +260,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/colibri_pxa300_defconfig
===================================================================
--- a/arch/arm/configs/colibri_pxa300_defconfig
+++ b/arch/arm/configs/colibri_pxa300_defconfig
@@ -270,7 +270,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/davinci_all_defconfig
===================================================================
--- a/arch/arm/configs/davinci_all_defconfig
+++ b/arch/arm/configs/davinci_all_defconfig
@@ -261,7 +261,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_LEDS=y
Index: b/arch/arm/configs/em_x270_defconfig
===================================================================
--- a/arch/arm/configs/em_x270_defconfig
+++ b/arch/arm/configs/em_x270_defconfig
@@ -258,7 +258,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/eseries_pxa_defconfig
===================================================================
--- a/arch/arm/configs/eseries_pxa_defconfig
+++ b/arch/arm/configs/eseries_pxa_defconfig
@@ -269,7 +269,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/kirkwood_defconfig
===================================================================
--- a/arch/arm/configs/kirkwood_defconfig
+++ b/arch/arm/configs/kirkwood_defconfig
@@ -253,7 +253,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_ALIGNMENT_TRAP=y
Index: b/arch/arm/configs/magician_defconfig
===================================================================
--- a/arch/arm/configs/magician_defconfig
+++ b/arch/arm/configs/magician_defconfig
@@ -259,7 +259,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/mv78xx0_defconfig
===================================================================
--- a/arch/arm/configs/mv78xx0_defconfig
+++ b/arch/arm/configs/mv78xx0_defconfig
@@ -246,7 +246,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_ALIGNMENT_TRAP=y
Index: b/arch/arm/configs/mx1_defconfig
===================================================================
--- a/arch/arm/configs/mx1_defconfig
+++ b/arch/arm/configs/mx1_defconfig
@@ -248,7 +248,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_ALIGNMENT_TRAP=y
Index: b/arch/arm/configs/mx27_defconfig
===================================================================
--- a/arch/arm/configs/mx27_defconfig
+++ b/arch/arm/configs/mx27_defconfig
@@ -253,7 +253,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_ALIGNMENT_TRAP=y
Index: b/arch/arm/configs/mx31pdk_defconfig
===================================================================
--- a/arch/arm/configs/mx31pdk_defconfig
+++ b/arch/arm/configs/mx31pdk_defconfig
@@ -226,7 +226,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_UNEVICTABLE_LRU is not set
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/mx3_defconfig
===================================================================
--- a/arch/arm/configs/mx3_defconfig
+++ b/arch/arm/configs/mx3_defconfig
@@ -257,7 +257,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_ALIGNMENT_TRAP=y
Index: b/arch/arm/configs/omap3_pandora_defconfig
===================================================================
--- a/arch/arm/configs/omap3_pandora_defconfig
+++ b/arch/arm/configs/omap3_pandora_defconfig
@@ -272,7 +272,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_LEDS is not set
 CONFIG_ALIGNMENT_TRAP=y
 
Index: b/arch/arm/configs/omap_3430sdp_defconfig
===================================================================
--- a/arch/arm/configs/omap_3430sdp_defconfig
+++ b/arch/arm/configs/omap_3430sdp_defconfig
@@ -277,7 +277,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_LEDS=y
 CONFIG_ALIGNMENT_TRAP=y
 
Index: b/arch/arm/configs/orion5x_defconfig
===================================================================
--- a/arch/arm/configs/orion5x_defconfig
+++ b/arch/arm/configs/orion5x_defconfig
@@ -259,7 +259,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_LEDS=y
Index: b/arch/arm/configs/pxa168_defconfig
===================================================================
--- a/arch/arm/configs/pxa168_defconfig
+++ b/arch/arm/configs/pxa168_defconfig
@@ -242,7 +242,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/pxa910_defconfig
===================================================================
--- a/arch/arm/configs/pxa910_defconfig
+++ b/arch/arm/configs/pxa910_defconfig
@@ -242,7 +242,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/realview-smp_defconfig
===================================================================
--- a/arch/arm/configs/realview-smp_defconfig
+++ b/arch/arm/configs/realview-smp_defconfig
@@ -256,7 +256,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/realview_defconfig
===================================================================
--- a/arch/arm/configs/realview_defconfig
+++ b/arch/arm/configs/realview_defconfig
@@ -250,7 +250,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/rx51_defconfig
===================================================================
--- a/arch/arm/configs/rx51_defconfig
+++ b/arch/arm/configs/rx51_defconfig
@@ -273,7 +273,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_LEDS is not set
 CONFIG_ALIGNMENT_TRAP=y
 
Index: b/arch/arm/configs/s3c2410_defconfig
===================================================================
--- a/arch/arm/configs/s3c2410_defconfig
+++ b/arch/arm/configs/s3c2410_defconfig
@@ -334,7 +334,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_ALIGNMENT_TRAP=y
Index: b/arch/arm/configs/s3c6400_defconfig
===================================================================
--- a/arch/arm/configs/s3c6400_defconfig
+++ b/arch/arm/configs/s3c6400_defconfig
@@ -249,7 +249,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/arm/configs/shark_defconfig
===================================================================
--- a/arch/arm/configs/shark_defconfig
+++ b/arch/arm/configs/shark_defconfig
@@ -232,7 +232,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_LEDS=y
 CONFIG_LEDS_TIMER=y
 # CONFIG_LEDS_CPU is not set
Index: b/arch/arm/configs/stmp378x_defconfig
===================================================================
--- a/arch/arm/configs/stmp378x_defconfig
+++ b/arch/arm/configs/stmp378x_defconfig
@@ -253,7 +253,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_ALIGNMENT_TRAP=y
Index: b/arch/arm/configs/stmp37xx_defconfig
===================================================================
--- a/arch/arm/configs/stmp37xx_defconfig
+++ b/arch/arm/configs/stmp37xx_defconfig
@@ -240,7 +240,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ALIGNMENT_TRAP=y
 
 #
Index: b/arch/avr32/configs/atstk1006_defconfig
===================================================================
--- a/arch/avr32/configs/atstk1006_defconfig
+++ b/arch/avr32/configs/atstk1006_defconfig
@@ -175,7 +175,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_OWNERSHIP_TRACE is not set
 CONFIG_NMI_DEBUGGING=y
 # CONFIG_HZ_100 is not set
Index: b/arch/avr32/configs/hammerhead_defconfig
===================================================================
--- a/arch/avr32/configs/hammerhead_defconfig
+++ b/arch/avr32/configs/hammerhead_defconfig
@@ -172,7 +172,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_OWNERSHIP_TRACE is not set
 # CONFIG_NMI_DEBUGGING is not set
 # CONFIG_HZ_100 is not set
Index: b/arch/avr32/configs/merisc_defconfig
===================================================================
--- a/arch/avr32/configs/merisc_defconfig
+++ b/arch/avr32/configs/merisc_defconfig
@@ -169,7 +169,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_OWNERSHIP_TRACE is not set
 # CONFIG_NMI_DEBUGGING is not set
 # CONFIG_HZ_100 is not set
Index: b/arch/ia64/configs/generic_defconfig
===================================================================
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -192,7 +192,6 @@ CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_NR_QUICK=1
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ARCH_SELECT_MEMORY_MODEL=y
 CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_ARCH_FLATMEM_ENABLE=y
Index: b/arch/ia64/configs/xen_domu_defconfig
===================================================================
--- a/arch/ia64/configs/xen_domu_defconfig
+++ b/arch/ia64/configs/xen_domu_defconfig
@@ -192,7 +192,6 @@ CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_NR_QUICK=1
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ARCH_SELECT_MEMORY_MODEL=y
 CONFIG_ARCH_DISCONTIGMEM_ENABLE=y
 CONFIG_ARCH_FLATMEM_ENABLE=y
Index: b/arch/m68k/configs/amiga_defconfig
===================================================================
--- a/arch/m68k/configs/amiga_defconfig
+++ b/arch/m68k/configs/amiga_defconfig
@@ -155,7 +155,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/apollo_defconfig
===================================================================
--- a/arch/m68k/configs/apollo_defconfig
+++ b/arch/m68k/configs/apollo_defconfig
@@ -155,7 +155,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/atari_defconfig
===================================================================
--- a/arch/m68k/configs/atari_defconfig
+++ b/arch/m68k/configs/atari_defconfig
@@ -155,7 +155,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/bvme6000_defconfig
===================================================================
--- a/arch/m68k/configs/bvme6000_defconfig
+++ b/arch/m68k/configs/bvme6000_defconfig
@@ -158,7 +158,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/hp300_defconfig
===================================================================
--- a/arch/m68k/configs/hp300_defconfig
+++ b/arch/m68k/configs/hp300_defconfig
@@ -156,7 +156,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/mac_defconfig
===================================================================
--- a/arch/m68k/configs/mac_defconfig
+++ b/arch/m68k/configs/mac_defconfig
@@ -157,7 +157,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/multi_defconfig
===================================================================
--- a/arch/m68k/configs/multi_defconfig
+++ b/arch/m68k/configs/multi_defconfig
@@ -161,7 +161,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/mvme147_defconfig
===================================================================
--- a/arch/m68k/configs/mvme147_defconfig
+++ b/arch/m68k/configs/mvme147_defconfig
@@ -158,7 +158,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/mvme16x_defconfig
===================================================================
--- a/arch/m68k/configs/mvme16x_defconfig
+++ b/arch/m68k/configs/mvme16x_defconfig
@@ -158,7 +158,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/q40_defconfig
===================================================================
--- a/arch/m68k/configs/q40_defconfig
+++ b/arch/m68k/configs/q40_defconfig
@@ -155,7 +155,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/sun3_defconfig
===================================================================
--- a/arch/m68k/configs/sun3_defconfig
+++ b/arch/m68k/configs/sun3_defconfig
@@ -153,7 +153,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68k/configs/sun3x_defconfig
===================================================================
--- a/arch/m68k/configs/sun3x_defconfig
+++ b/arch/m68k/configs/sun3x_defconfig
@@ -155,7 +155,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/m68knommu/configs/m5208evb_defconfig
===================================================================
--- a/arch/m68knommu/configs/m5208evb_defconfig
+++ b/arch/m68knommu/configs/m5208evb_defconfig
@@ -165,7 +165,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_UNEVICTABLE_LRU is not set
 CONFIG_ISA_DMA_API=y
 
 #
Index: b/arch/m68knommu/configs/m5249evb_defconfig
===================================================================
--- a/arch/m68knommu/configs/m5249evb_defconfig
+++ b/arch/m68knommu/configs/m5249evb_defconfig
@@ -165,7 +165,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_UNEVICTABLE_LRU is not set
 CONFIG_ISA_DMA_API=y
 
 #
Index: b/arch/m68knommu/configs/m5272c3_defconfig
===================================================================
--- a/arch/m68knommu/configs/m5272c3_defconfig
+++ b/arch/m68knommu/configs/m5272c3_defconfig
@@ -172,7 +172,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_UNEVICTABLE_LRU is not set
 
 #
 # Executable file formats
Index: b/arch/m68knommu/configs/m5275evb_defconfig
===================================================================
--- a/arch/m68knommu/configs/m5275evb_defconfig
+++ b/arch/m68knommu/configs/m5275evb_defconfig
@@ -169,7 +169,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_UNEVICTABLE_LRU is not set
 CONFIG_ISA_DMA_API=y
 
 #
Index: b/arch/m68knommu/configs/m5307c3_defconfig
===================================================================
--- a/arch/m68knommu/configs/m5307c3_defconfig
+++ b/arch/m68knommu/configs/m5307c3_defconfig
@@ -171,7 +171,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_UNEVICTABLE_LRU is not set
 CONFIG_ISA_DMA_API=y
 
 #
Index: b/arch/m68knommu/configs/m5407c3_defconfig
===================================================================
--- a/arch/m68knommu/configs/m5407c3_defconfig
+++ b/arch/m68knommu/configs/m5407c3_defconfig
@@ -172,7 +172,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_VIRT_TO_BUS=y
-# CONFIG_UNEVICTABLE_LRU is not set
 CONFIG_ISA_DMA_API=y
 
 #
Index: b/arch/mips/configs/cavium-octeon_defconfig
===================================================================
--- a/arch/mips/configs/cavium-octeon_defconfig
+++ b/arch/mips/configs/cavium-octeon_defconfig
@@ -149,7 +149,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_SMP=y
 CONFIG_SYS_SUPPORTS_SMP=y
 CONFIG_NR_CPUS_DEFAULT_16=y
Index: b/arch/mips/configs/fulong_defconfig
===================================================================
--- a/arch/mips/configs/fulong_defconfig
+++ b/arch/mips/configs/fulong_defconfig
@@ -139,7 +139,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_TICK_ONESHOT=y
 CONFIG_NO_HZ=y
 CONFIG_HIGH_RES_TIMERS=y
Index: b/arch/mips/configs/ip22_defconfig
===================================================================
--- a/arch/mips/configs/ip22_defconfig
+++ b/arch/mips/configs/ip22_defconfig
@@ -148,7 +148,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_TICK_ONESHOT=y
 CONFIG_NO_HZ=y
 CONFIG_HIGH_RES_TIMERS=y
Index: b/arch/mips/configs/ip32_defconfig
===================================================================
--- a/arch/mips/configs/ip32_defconfig
+++ b/arch/mips/configs/ip32_defconfig
@@ -136,7 +136,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_NO_HZ is not set
 # CONFIG_HIGH_RES_TIMERS is not set
 CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
Index: b/arch/mips/configs/jmr3927_defconfig
===================================================================
--- a/arch/mips/configs/jmr3927_defconfig
+++ b/arch/mips/configs/jmr3927_defconfig
@@ -132,7 +132,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_NO_HZ is not set
 # CONFIG_HIGH_RES_TIMERS is not set
 CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
Index: b/arch/mips/configs/malta_defconfig
===================================================================
--- a/arch/mips/configs/malta_defconfig
+++ b/arch/mips/configs/malta_defconfig
@@ -164,7 +164,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_SMP=y
 CONFIG_SMP_UP=y
 CONFIG_SYS_SUPPORTS_SMP=y
Index: b/arch/mips/configs/rbtx49xx_defconfig
===================================================================
--- a/arch/mips/configs/rbtx49xx_defconfig
+++ b/arch/mips/configs/rbtx49xx_defconfig
@@ -155,7 +155,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_TICK_ONESHOT=y
 CONFIG_NO_HZ=y
 CONFIG_HIGH_RES_TIMERS=y
Index: b/arch/mn10300/configs/asb2303_defconfig
===================================================================
--- a/arch/mn10300/configs/asb2303_defconfig
+++ b/arch/mn10300/configs/asb2303_defconfig
@@ -145,7 +145,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=1
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/parisc/configs/712_defconfig
===================================================================
--- a/arch/parisc/configs/712_defconfig
+++ b/arch/parisc/configs/712_defconfig
@@ -154,7 +154,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_HPUX is not set
 
 #
Index: b/arch/parisc/configs/a500_defconfig
===================================================================
--- a/arch/parisc/configs/a500_defconfig
+++ b/arch/parisc/configs/a500_defconfig
@@ -161,7 +161,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_COMPAT=y
 CONFIG_NR_CPUS=8
 
Index: b/arch/parisc/configs/b180_defconfig
===================================================================
--- a/arch/parisc/configs/b180_defconfig
+++ b/arch/parisc/configs/b180_defconfig
@@ -140,7 +140,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_HPUX is not set
 
 #
Index: b/arch/parisc/configs/c3000_defconfig
===================================================================
--- a/arch/parisc/configs/c3000_defconfig
+++ b/arch/parisc/configs/c3000_defconfig
@@ -151,7 +151,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_HPUX is not set
 
 #
Index: b/arch/parisc/configs/default_defconfig
===================================================================
--- a/arch/parisc/configs/default_defconfig
+++ b/arch/parisc/configs/default_defconfig
@@ -155,7 +155,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4096
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_HPUX is not set
 
 #
Index: b/arch/powerpc/configs/40x/acadia_defconfig
===================================================================
--- a/arch/powerpc/configs/40x/acadia_defconfig
+++ b/arch/powerpc/configs/40x/acadia_defconfig
@@ -227,7 +227,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/40x/ep405_defconfig
===================================================================
--- a/arch/powerpc/configs/40x/ep405_defconfig
+++ b/arch/powerpc/configs/40x/ep405_defconfig
@@ -229,7 +229,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/40x/hcu4_defconfig
===================================================================
--- a/arch/powerpc/configs/40x/hcu4_defconfig
+++ b/arch/powerpc/configs/40x/hcu4_defconfig
@@ -227,7 +227,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/40x/kilauea_defconfig
===================================================================
--- a/arch/powerpc/configs/40x/kilauea_defconfig
+++ b/arch/powerpc/configs/40x/kilauea_defconfig
@@ -227,7 +227,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/40x/makalu_defconfig
===================================================================
--- a/arch/powerpc/configs/40x/makalu_defconfig
+++ b/arch/powerpc/configs/40x/makalu_defconfig
@@ -227,7 +227,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/40x/virtex_defconfig
===================================================================
--- a/arch/powerpc/configs/40x/virtex_defconfig
+++ b/arch/powerpc/configs/40x/virtex_defconfig
@@ -232,7 +232,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/40x/walnut_defconfig
===================================================================
--- a/arch/powerpc/configs/40x/walnut_defconfig
+++ b/arch/powerpc/configs/40x/walnut_defconfig
@@ -230,7 +230,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/arches_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/arches_defconfig
+++ b/arch/powerpc/configs/44x/arches_defconfig
@@ -233,7 +233,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/bamboo_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/bamboo_defconfig
+++ b/arch/powerpc/configs/44x/bamboo_defconfig
@@ -237,7 +237,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/canyonlands_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/canyonlands_defconfig
+++ b/arch/powerpc/configs/44x/canyonlands_defconfig
@@ -237,7 +237,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/ebony_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/ebony_defconfig
+++ b/arch/powerpc/configs/44x/ebony_defconfig
@@ -237,7 +237,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/katmai_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/katmai_defconfig
+++ b/arch/powerpc/configs/44x/katmai_defconfig
@@ -231,7 +231,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/rainier_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/rainier_defconfig
+++ b/arch/powerpc/configs/44x/rainier_defconfig
@@ -235,7 +235,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/redwood_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/redwood_defconfig
+++ b/arch/powerpc/configs/44x/redwood_defconfig
@@ -238,7 +238,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/sam440ep_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/sam440ep_defconfig
+++ b/arch/powerpc/configs/44x/sam440ep_defconfig
@@ -237,7 +237,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/sequoia_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/sequoia_defconfig
+++ b/arch/powerpc/configs/44x/sequoia_defconfig
@@ -237,7 +237,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/taishan_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/taishan_defconfig
+++ b/arch/powerpc/configs/44x/taishan_defconfig
@@ -235,7 +235,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/virtex5_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/virtex5_defconfig
+++ b/arch/powerpc/configs/44x/virtex5_defconfig
@@ -238,7 +238,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/44x/warp_defconfig
===================================================================
--- a/arch/powerpc/configs/44x/warp_defconfig
+++ b/arch/powerpc/configs/44x/warp_defconfig
@@ -234,7 +234,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/52xx/cm5200_defconfig
===================================================================
--- a/arch/powerpc/configs/52xx/cm5200_defconfig
+++ b/arch/powerpc/configs/52xx/cm5200_defconfig
@@ -239,7 +239,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/52xx/lite5200b_defconfig
===================================================================
--- a/arch/powerpc/configs/52xx/lite5200b_defconfig
+++ b/arch/powerpc/configs/52xx/lite5200b_defconfig
@@ -248,7 +248,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/52xx/motionpro_defconfig
===================================================================
--- a/arch/powerpc/configs/52xx/motionpro_defconfig
+++ b/arch/powerpc/configs/52xx/motionpro_defconfig
@@ -240,7 +240,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/52xx/pcm030_defconfig
===================================================================
--- a/arch/powerpc/configs/52xx/pcm030_defconfig
+++ b/arch/powerpc/configs/52xx/pcm030_defconfig
@@ -247,7 +247,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/52xx/tqm5200_defconfig
===================================================================
--- a/arch/powerpc/configs/52xx/tqm5200_defconfig
+++ b/arch/powerpc/configs/52xx/tqm5200_defconfig
@@ -245,7 +245,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/83xx/asp8347_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/asp8347_defconfig
+++ b/arch/powerpc/configs/83xx/asp8347_defconfig
@@ -244,7 +244,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc832x_mds_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc832x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc832x_mds_defconfig
@@ -244,7 +244,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
@@ -244,7 +244,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
+++ b/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig
+++ b/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc834x_mds_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc834x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc834x_mds_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc836x_mds_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc836x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc836x_mds_defconfig
@@ -242,7 +242,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc836x_rdk_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc836x_rdk_defconfig
+++ b/arch/powerpc/configs/83xx/mpc836x_rdk_defconfig
@@ -242,7 +242,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc837x_mds_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc837x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc837x_mds_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/83xx/sbc834x_defconfig
===================================================================
--- a/arch/powerpc/configs/83xx/sbc834x_defconfig
+++ b/arch/powerpc/configs/83xx/sbc834x_defconfig
@@ -241,7 +241,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/ksi8560_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/ksi8560_defconfig
+++ b/arch/powerpc/configs/85xx/ksi8560_defconfig
@@ -230,7 +230,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/mpc8540_ads_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/mpc8540_ads_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8540_ads_defconfig
@@ -232,7 +232,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
@@ -235,7 +235,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
+++ b/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
@@ -233,7 +233,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/sbc8548_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/sbc8548_defconfig
+++ b/arch/powerpc/configs/85xx/sbc8548_defconfig
@@ -230,7 +230,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/sbc8560_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/sbc8560_defconfig
+++ b/arch/powerpc/configs/85xx/sbc8560_defconfig
@@ -230,7 +230,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/stx_gp3_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/stx_gp3_defconfig
+++ b/arch/powerpc/configs/85xx/stx_gp3_defconfig
@@ -240,7 +240,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/tqm8540_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/tqm8540_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8540_defconfig
@@ -231,7 +231,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/tqm8541_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/tqm8541_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8541_defconfig
@@ -234,7 +234,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/tqm8548_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/tqm8548_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8548_defconfig
@@ -245,7 +245,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/tqm8555_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/tqm8555_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8555_defconfig
@@ -234,7 +234,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/85xx/tqm8560_defconfig
===================================================================
--- a/arch/powerpc/configs/85xx/tqm8560_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8560_defconfig
@@ -234,7 +234,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/86xx/gef_ppc9a_defconfig
===================================================================
--- a/arch/powerpc/configs/86xx/gef_ppc9a_defconfig
+++ b/arch/powerpc/configs/86xx/gef_ppc9a_defconfig
@@ -249,7 +249,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/86xx/gef_sbc310_defconfig
===================================================================
--- a/arch/powerpc/configs/86xx/gef_sbc310_defconfig
+++ b/arch/powerpc/configs/86xx/gef_sbc310_defconfig
@@ -244,7 +244,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/86xx/gef_sbc610_defconfig
===================================================================
--- a/arch/powerpc/configs/86xx/gef_sbc610_defconfig
+++ b/arch/powerpc/configs/86xx/gef_sbc610_defconfig
@@ -243,7 +243,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/86xx/mpc8610_hpcd_defconfig
===================================================================
--- a/arch/powerpc/configs/86xx/mpc8610_hpcd_defconfig
+++ b/arch/powerpc/configs/86xx/mpc8610_hpcd_defconfig
@@ -237,7 +237,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/86xx/mpc8641_hpcn_defconfig
===================================================================
--- a/arch/powerpc/configs/86xx/mpc8641_hpcn_defconfig
+++ b/arch/powerpc/configs/86xx/mpc8641_hpcn_defconfig
@@ -244,7 +244,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/86xx/sbc8641d_defconfig
===================================================================
--- a/arch/powerpc/configs/86xx/sbc8641d_defconfig
+++ b/arch/powerpc/configs/86xx/sbc8641d_defconfig
@@ -242,7 +242,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/adder875_defconfig
===================================================================
--- a/arch/powerpc/configs/adder875_defconfig
+++ b/arch/powerpc/configs/adder875_defconfig
@@ -232,7 +232,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/amigaone_defconfig
===================================================================
--- a/arch/powerpc/configs/amigaone_defconfig
+++ b/arch/powerpc/configs/amigaone_defconfig
@@ -240,7 +240,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/c2k_defconfig
===================================================================
--- a/arch/powerpc/configs/c2k_defconfig
+++ b/arch/powerpc/configs/c2k_defconfig
@@ -267,7 +267,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/chrp32_defconfig
===================================================================
--- a/arch/powerpc/configs/chrp32_defconfig
+++ b/arch/powerpc/configs/chrp32_defconfig
@@ -237,7 +237,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_FORCE_MAX_ZONEORDER=11
 CONFIG_PROC_DEVICETREE=y
 # CONFIG_CMDLINE_BOOL is not set
Index: b/arch/powerpc/configs/ep8248e_defconfig
===================================================================
--- a/arch/powerpc/configs/ep8248e_defconfig
+++ b/arch/powerpc/configs/ep8248e_defconfig
@@ -221,7 +221,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/ep88xc_defconfig
===================================================================
--- a/arch/powerpc/configs/ep88xc_defconfig
+++ b/arch/powerpc/configs/ep88xc_defconfig
@@ -232,7 +232,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/g5_defconfig
===================================================================
--- a/arch/powerpc/configs/g5_defconfig
+++ b/arch/powerpc/configs/g5_defconfig
@@ -266,7 +266,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_PPC_HAS_HASH_64K is not set
 # CONFIG_PPC_64K_PAGES is not set
 CONFIG_FORCE_MAX_ZONEORDER=13
Index: b/arch/powerpc/configs/iseries_defconfig
===================================================================
--- a/arch/powerpc/configs/iseries_defconfig
+++ b/arch/powerpc/configs/iseries_defconfig
@@ -249,7 +249,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_PPC_HAS_HASH_64K is not set
 # CONFIG_PPC_64K_PAGES is not set
 CONFIG_FORCE_MAX_ZONEORDER=13
Index: b/arch/powerpc/configs/linkstation_defconfig
===================================================================
--- a/arch/powerpc/configs/linkstation_defconfig
+++ b/arch/powerpc/configs/linkstation_defconfig
@@ -249,7 +249,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/maple_defconfig
===================================================================
--- a/arch/powerpc/configs/maple_defconfig
+++ b/arch/powerpc/configs/maple_defconfig
@@ -245,7 +245,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
-CONFIG_UNEVICTABLE_LRU=y
 # CONFIG_PPC_HAS_HASH_64K is not set
 # CONFIG_PPC_64K_PAGES is not set
 CONFIG_FORCE_MAX_ZONEORDER=13
Index: b/arch/powerpc/configs/mgcoge_defconfig
===================================================================
--- a/arch/powerpc/configs/mgcoge_defconfig
+++ b/arch/powerpc/configs/mgcoge_defconfig
@@ -230,7 +230,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/mgsuvd_defconfig
===================================================================
--- a/arch/powerpc/configs/mgsuvd_defconfig
+++ b/arch/powerpc/configs/mgsuvd_defconfig
@@ -231,7 +231,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/mpc5200_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc5200_defconfig
+++ b/arch/powerpc/configs/mpc5200_defconfig
@@ -249,7 +249,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/mpc7448_hpc2_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc7448_hpc2_defconfig
+++ b/arch/powerpc/configs/mpc7448_hpc2_defconfig
@@ -229,7 +229,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/mpc8272_ads_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc8272_ads_defconfig
+++ b/arch/powerpc/configs/mpc8272_ads_defconfig
@@ -224,7 +224,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/mpc83xx_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc83xx_defconfig
+++ b/arch/powerpc/configs/mpc83xx_defconfig
@@ -250,7 +250,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/mpc85xx_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc85xx_defconfig
+++ b/arch/powerpc/configs/mpc85xx_defconfig
@@ -260,7 +260,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/mpc85xx_smp_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc85xx_smp_defconfig
+++ b/arch/powerpc/configs/mpc85xx_smp_defconfig
@@ -264,7 +264,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/mpc866_ads_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc866_ads_defconfig
+++ b/arch/powerpc/configs/mpc866_ads_defconfig
@@ -231,7 +231,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/mpc86xx_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc86xx_defconfig
+++ b/arch/powerpc/configs/mpc86xx_defconfig
@@ -246,7 +246,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/mpc885_ads_defconfig
===================================================================
--- a/arch/powerpc/configs/mpc885_ads_defconfig
+++ b/arch/powerpc/configs/mpc885_ads_defconfig
@@ -239,7 +239,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/pmac32_defconfig
===================================================================
--- a/arch/powerpc/configs/pmac32_defconfig
+++ b/arch/powerpc/configs/pmac32_defconfig
@@ -255,7 +255,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_FORCE_MAX_ZONEORDER=11
 CONFIG_PROC_DEVICETREE=y
 # CONFIG_CMDLINE_BOOL is not set
Index: b/arch/powerpc/configs/ppc40x_defconfig
===================================================================
--- a/arch/powerpc/configs/ppc40x_defconfig
+++ b/arch/powerpc/configs/ppc40x_defconfig
@@ -237,7 +237,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/ppc44x_defconfig
===================================================================
--- a/arch/powerpc/configs/ppc44x_defconfig
+++ b/arch/powerpc/configs/ppc44x_defconfig
@@ -249,7 +249,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/ppc64_defconfig
===================================================================
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -353,7 +353,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ARCH_MEMORY_PROBE=y
 CONFIG_PPC_HAS_HASH_64K=y
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/ppc6xx_defconfig
===================================================================
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -326,7 +326,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_FORCE_MAX_ZONEORDER=11
 CONFIG_PROC_DEVICETREE=y
 # CONFIG_CMDLINE_BOOL is not set
Index: b/arch/powerpc/configs/pq2fads_defconfig
===================================================================
--- a/arch/powerpc/configs/pq2fads_defconfig
+++ b/arch/powerpc/configs/pq2fads_defconfig
@@ -224,7 +224,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/prpmc2800_defconfig
===================================================================
--- a/arch/powerpc/configs/prpmc2800_defconfig
+++ b/arch/powerpc/configs/prpmc2800_defconfig
@@ -236,7 +236,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/ps3_defconfig
===================================================================
--- a/arch/powerpc/configs/ps3_defconfig
+++ b/arch/powerpc/configs/ps3_defconfig
@@ -278,7 +278,6 @@ CONFIG_MIGRATION=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_ARCH_MEMORY_PROBE=y
 CONFIG_PPC_HAS_HASH_64K=y
 CONFIG_PPC_4K_PAGES=y
Index: b/arch/powerpc/configs/pseries_defconfig
===================================================================
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -278,7 +278,6 @@ CONFIG_RESOURCES_64BIT=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_NODES_SPAN_OTHER_NODES=y
 # CONFIG_PPC_HAS_HASH_64K is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/powerpc/configs/storcenter_defconfig
===================================================================
--- a/arch/powerpc/configs/storcenter_defconfig
+++ b/arch/powerpc/configs/storcenter_defconfig
@@ -238,7 +238,6 @@ CONFIG_MIGRATION=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_PPC_4K_PAGES=y
 # CONFIG_PPC_16K_PAGES is not set
 # CONFIG_PPC_64K_PAGES is not set
Index: b/arch/s390/defconfig
===================================================================
--- a/arch/s390/defconfig
+++ b/arch/s390/defconfig
@@ -218,7 +218,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/ap325rxa_defconfig
===================================================================
--- a/arch/sh/configs/ap325rxa_defconfig
+++ b/arch/sh/configs/ap325rxa_defconfig
@@ -208,7 +208,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/cayman_defconfig
===================================================================
--- a/arch/sh/configs/cayman_defconfig
+++ b/arch/sh/configs/cayman_defconfig
@@ -172,7 +172,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/dreamcast_defconfig
===================================================================
--- a/arch/sh/configs/dreamcast_defconfig
+++ b/arch/sh/configs/dreamcast_defconfig
@@ -210,7 +210,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/edosk7705_defconfig
===================================================================
--- a/arch/sh/configs/edosk7705_defconfig
+++ b/arch/sh/configs/edosk7705_defconfig
@@ -166,7 +166,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/edosk7760_defconfig
===================================================================
--- a/arch/sh/configs/edosk7760_defconfig
+++ b/arch/sh/configs/edosk7760_defconfig
@@ -209,7 +209,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/espt_defconfig
===================================================================
--- a/arch/sh/configs/espt_defconfig
+++ b/arch/sh/configs/espt_defconfig
@@ -215,7 +215,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/hp6xx_defconfig
===================================================================
--- a/arch/sh/configs/hp6xx_defconfig
+++ b/arch/sh/configs/hp6xx_defconfig
@@ -192,7 +192,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/landisk_defconfig
===================================================================
--- a/arch/sh/configs/landisk_defconfig
+++ b/arch/sh/configs/landisk_defconfig
@@ -201,7 +201,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/lboxre2_defconfig
===================================================================
--- a/arch/sh/configs/lboxre2_defconfig
+++ b/arch/sh/configs/lboxre2_defconfig
@@ -201,7 +201,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/magicpanelr2_defconfig
===================================================================
--- a/arch/sh/configs/magicpanelr2_defconfig
+++ b/arch/sh/configs/magicpanelr2_defconfig
@@ -207,7 +207,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/microdev_defconfig
===================================================================
--- a/arch/sh/configs/microdev_defconfig
+++ b/arch/sh/configs/microdev_defconfig
@@ -204,7 +204,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/migor_defconfig
===================================================================
--- a/arch/sh/configs/migor_defconfig
+++ b/arch/sh/configs/migor_defconfig
@@ -217,7 +217,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/polaris_defconfig
===================================================================
--- a/arch/sh/configs/polaris_defconfig
+++ b/arch/sh/configs/polaris_defconfig
@@ -208,7 +208,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/r7780mp_defconfig
===================================================================
--- a/arch/sh/configs/r7780mp_defconfig
+++ b/arch/sh/configs/r7780mp_defconfig
@@ -222,7 +222,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/r7785rp_defconfig
===================================================================
--- a/arch/sh/configs/r7785rp_defconfig
+++ b/arch/sh/configs/r7785rp_defconfig
@@ -232,7 +232,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/rsk7201_defconfig
===================================================================
--- a/arch/sh/configs/rsk7201_defconfig
+++ b/arch/sh/configs/rsk7201_defconfig
@@ -201,7 +201,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 
 #
 # Cache configuration
Index: b/arch/sh/configs/rsk7203_defconfig
===================================================================
--- a/arch/sh/configs/rsk7203_defconfig
+++ b/arch/sh/configs/rsk7203_defconfig
@@ -208,7 +208,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 
 #
 # Cache configuration
Index: b/arch/sh/configs/rts7751r2d1_defconfig
===================================================================
--- a/arch/sh/configs/rts7751r2d1_defconfig
+++ b/arch/sh/configs/rts7751r2d1_defconfig
@@ -203,7 +203,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/rts7751r2dplus_defconfig
===================================================================
--- a/arch/sh/configs/rts7751r2dplus_defconfig
+++ b/arch/sh/configs/rts7751r2dplus_defconfig
@@ -203,7 +203,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/sdk7780_defconfig
===================================================================
--- a/arch/sh/configs/sdk7780_defconfig
+++ b/arch/sh/configs/sdk7780_defconfig
@@ -218,7 +218,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7206_defconfig
===================================================================
--- a/arch/sh/configs/se7206_defconfig
+++ b/arch/sh/configs/se7206_defconfig
@@ -220,7 +220,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 
 #
 # Cache configuration
Index: b/arch/sh/configs/se7343_defconfig
===================================================================
--- a/arch/sh/configs/se7343_defconfig
+++ b/arch/sh/configs/se7343_defconfig
@@ -207,7 +207,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7619_defconfig
===================================================================
--- a/arch/sh/configs/se7619_defconfig
+++ b/arch/sh/configs/se7619_defconfig
@@ -181,7 +181,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 
 #
 # Cache configuration
Index: b/arch/sh/configs/se7705_defconfig
===================================================================
--- a/arch/sh/configs/se7705_defconfig
+++ b/arch/sh/configs/se7705_defconfig
@@ -198,7 +198,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7712_defconfig
===================================================================
--- a/arch/sh/configs/se7712_defconfig
+++ b/arch/sh/configs/se7712_defconfig
@@ -200,7 +200,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7721_defconfig
===================================================================
--- a/arch/sh/configs/se7721_defconfig
+++ b/arch/sh/configs/se7721_defconfig
@@ -204,7 +204,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7722_defconfig
===================================================================
--- a/arch/sh/configs/se7722_defconfig
+++ b/arch/sh/configs/se7722_defconfig
@@ -226,7 +226,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7750_defconfig
===================================================================
--- a/arch/sh/configs/se7750_defconfig
+++ b/arch/sh/configs/se7750_defconfig
@@ -200,7 +200,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7751_defconfig
===================================================================
--- a/arch/sh/configs/se7751_defconfig
+++ b/arch/sh/configs/se7751_defconfig
@@ -203,7 +203,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/se7780_defconfig
===================================================================
--- a/arch/sh/configs/se7780_defconfig
+++ b/arch/sh/configs/se7780_defconfig
@@ -200,7 +200,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/sh03_defconfig
===================================================================
--- a/arch/sh/configs/sh03_defconfig
+++ b/arch/sh/configs/sh03_defconfig
@@ -210,7 +210,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/sh7710voipgw_defconfig
===================================================================
--- a/arch/sh/configs/sh7710voipgw_defconfig
+++ b/arch/sh/configs/sh7710voipgw_defconfig
@@ -203,7 +203,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/sh7724_generic_defconfig
===================================================================
--- a/arch/sh/configs/sh7724_generic_defconfig
+++ b/arch/sh/configs/sh7724_generic_defconfig
@@ -215,7 +215,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/sh7763rdp_defconfig
===================================================================
--- a/arch/sh/configs/sh7763rdp_defconfig
+++ b/arch/sh/configs/sh7763rdp_defconfig
@@ -215,7 +215,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/sh7785lcr_32bit_defconfig
===================================================================
--- a/arch/sh/configs/sh7785lcr_32bit_defconfig
+++ b/arch/sh/configs/sh7785lcr_32bit_defconfig
@@ -224,7 +224,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/sh7785lcr_defconfig
===================================================================
--- a/arch/sh/configs/sh7785lcr_defconfig
+++ b/arch/sh/configs/sh7785lcr_defconfig
@@ -217,7 +217,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/shmin_defconfig
===================================================================
--- a/arch/sh/configs/shmin_defconfig
+++ b/arch/sh/configs/shmin_defconfig
@@ -186,7 +186,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/shx3_defconfig
===================================================================
--- a/arch/sh/configs/shx3_defconfig
+++ b/arch/sh/configs/shx3_defconfig
@@ -249,7 +249,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/snapgear_defconfig
===================================================================
--- a/arch/sh/configs/snapgear_defconfig
+++ b/arch/sh/configs/snapgear_defconfig
@@ -198,7 +198,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/systemh_defconfig
===================================================================
--- a/arch/sh/configs/systemh_defconfig
+++ b/arch/sh/configs/systemh_defconfig
@@ -200,7 +200,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/titan_defconfig
===================================================================
--- a/arch/sh/configs/titan_defconfig
+++ b/arch/sh/configs/titan_defconfig
@@ -208,7 +208,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/ul2_defconfig
===================================================================
--- a/arch/sh/configs/ul2_defconfig
+++ b/arch/sh/configs/ul2_defconfig
@@ -226,7 +226,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sh/configs/urquell_defconfig
===================================================================
--- a/arch/sh/configs/urquell_defconfig
+++ b/arch/sh/configs/urquell_defconfig
@@ -216,7 +216,6 @@ CONFIG_MIGRATION=y
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=2
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 
Index: b/arch/sparc/configs/sparc32_defconfig
===================================================================
--- a/arch/sparc/configs/sparc32_defconfig
+++ b/arch/sparc/configs/sparc32_defconfig
@@ -154,7 +154,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 # CONFIG_PHYS_ADDR_T_64BIT is not set
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_SUN_PM=y
Index: b/arch/sparc/configs/sparc64_defconfig
===================================================================
--- a/arch/sparc/configs/sparc64_defconfig
+++ b/arch/sparc/configs/sparc64_defconfig
@@ -199,7 +199,6 @@ CONFIG_MIGRATION=y
 CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=0
 CONFIG_NR_QUICK=1
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HAVE_MLOCK=y
 CONFIG_HAVE_MLOCKED_PAGE_BIT=y
 CONFIG_SCHED_SMT=y
Index: b/arch/x86/configs/i386_defconfig
===================================================================
--- a/arch/x86/configs/i386_defconfig
+++ b/arch/x86/configs/i386_defconfig
@@ -301,7 +301,6 @@ CONFIG_SPLIT_PTLOCK_CPUS=4
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_HIGHPTE=y
 CONFIG_X86_CHECK_BIOS_CORRUPTION=y
 CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
Index: b/arch/x86/configs/x86_64_defconfig
===================================================================
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -307,7 +307,6 @@ CONFIG_PHYS_ADDR_T_64BIT=y
 CONFIG_ZONE_DMA_FLAG=1
 CONFIG_BOUNCE=y
 CONFIG_VIRT_TO_BUS=y
-CONFIG_UNEVICTABLE_LRU=y
 CONFIG_X86_CHECK_BIOS_CORRUPTION=y
 CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
 CONFIG_X86_RESERVE_LOW_64K=y


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
