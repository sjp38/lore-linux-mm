Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5CIu5tb005531
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 14:56:05 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5CIu2Nk165236
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 12:56:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5CIu0Jd024177
	for <linux-mm@kvack.org>; Thu, 12 Jun 2008 12:56:01 -0600
Subject: [RFC PATCH 2/2] Update defconfigs for CONFIG_HUGETLB
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1213296540.17108.8.camel@localhost.localdomain>
References: <1213296540.17108.8.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 12 Jun 2008 14:55:45 -0400
Message-Id: <1213296945.17108.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: agl@us.ibm.com, npiggin@suse.de, nacc@us.ibm.com, mel@csn.ul.ie, Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linux-mips@linux-mips.org
List-ID: <linux-mm.kvack.org>

Update all defconfigs that specify a default configuration for hugetlbfs.
There is now only one option: CONFIG_HUGETLB.  Replace the old
CONFIG_HUGETLB_PAGE and CONFIG_HUGETLBFS options with the new one.  I found no
cases where CONFIG_HUGETLBFS and CONFIG_HUGETLB_PAGE had different values so
this patch is large but completely mechanical:

Signed-off-by: Adam Litke <agl@us.ibm.com>

--

 alpha/defconfig                              |    2 +-
 arm/configs/am200epdkit_defconfig            |    2 +-
 arm/configs/assabet_defconfig                |    2 +-
 arm/configs/at91cap9adk_defconfig            |    2 +-
 arm/configs/at91rm9200dk_defconfig           |    2 +-
 arm/configs/at91rm9200ek_defconfig           |    2 +-
 arm/configs/at91sam9260ek_defconfig          |    2 +-
 arm/configs/at91sam9261ek_defconfig          |    2 +-
 arm/configs/at91sam9263ek_defconfig          |    2 +-
 arm/configs/at91sam9rlek_defconfig           |    2 +-
 arm/configs/ateb9200_defconfig               |    2 +-
 arm/configs/badge4_defconfig                 |    2 +-
 arm/configs/cam60_defconfig                  |    2 +-
 arm/configs/carmeva_defconfig                |    2 +-
 arm/configs/cerfcube_defconfig               |    2 +-
 arm/configs/clps7500_defconfig               |    2 +-
 arm/configs/cm_x270_defconfig                |    2 +-
 arm/configs/colibri_defconfig                |    2 +-
 arm/configs/collie_defconfig                 |    2 +-
 arm/configs/corgi_defconfig                  |    2 +-
 arm/configs/csb337_defconfig                 |    2 +-
 arm/configs/csb637_defconfig                 |    2 +-
 arm/configs/ebsa110_defconfig                |    2 +-
 arm/configs/ecbat91_defconfig                |    2 +-
 arm/configs/edb7211_defconfig                |    2 +-
 arm/configs/em_x270_defconfig                |    2 +-
 arm/configs/ep93xx_defconfig                 |    2 +-
 arm/configs/eseries_pxa_defconfig            |    2 +-
 arm/configs/footbridge_defconfig             |    2 +-
 arm/configs/fortunet_defconfig               |    2 +-
 arm/configs/h3600_defconfig                  |    2 +-
 arm/configs/h7201_defconfig                  |    2 +-
 arm/configs/h7202_defconfig                  |    2 +-
 arm/configs/hackkit_defconfig                |    2 +-
 arm/configs/integrator_defconfig             |    2 +-
 arm/configs/iop13xx_defconfig                |    2 +-
 arm/configs/iop32x_defconfig                 |    2 +-
 arm/configs/iop33x_defconfig                 |    2 +-
 arm/configs/ixp2000_defconfig                |    2 +-
 arm/configs/ixp23xx_defconfig                |    2 +-
 arm/configs/ixp4xx_defconfig                 |    2 +-
 arm/configs/jornada720_defconfig             |    2 +-
 arm/configs/kafa_defconfig                   |    2 +-
 arm/configs/kb9202_defconfig                 |    2 +-
 arm/configs/ks8695_defconfig                 |    2 +-
 arm/configs/lart_defconfig                   |    2 +-
 arm/configs/littleton_defconfig              |    2 +-
 arm/configs/lpd270_defconfig                 |    2 +-
 arm/configs/lpd7a400_defconfig               |    2 +-
 arm/configs/lpd7a404_defconfig               |    2 +-
 arm/configs/lubbock_defconfig                |    2 +-
 arm/configs/lusl7200_defconfig               |    2 +-
 arm/configs/magician_defconfig               |    2 +-
 arm/configs/mainstone_defconfig              |    2 +-
 arm/configs/msm_defconfig                    |    2 +-
 arm/configs/mx1ads_defconfig                 |    2 +-
 arm/configs/neponset_defconfig               |    2 +-
 arm/configs/netwinder_defconfig              |    2 +-
 arm/configs/netx_defconfig                   |    2 +-
 arm/configs/omap_h2_1610_defconfig           |    2 +-
 arm/configs/omap_osk_5912_defconfig          |    2 +-
 arm/configs/onearm_defconfig                 |    2 +-
 arm/configs/orion5x_defconfig                |    2 +-
 arm/configs/pcm027_defconfig                 |    2 +-
 arm/configs/picotux200_defconfig             |    2 +-
 arm/configs/pleb_defconfig                   |    2 +-
 arm/configs/pnx4008_defconfig                |    2 +-
 arm/configs/pxa255-idp_defconfig             |    2 +-
 arm/configs/realview-smp_defconfig           |    2 +-
 arm/configs/realview_defconfig               |    2 +-
 arm/configs/rpc_defconfig                    |    2 +-
 arm/configs/s3c2410_defconfig                |    2 +-
 arm/configs/sam9_l9260_defconfig             |    2 +-
 arm/configs/shannon_defconfig                |    2 +-
 arm/configs/shark_defconfig                  |    2 +-
 arm/configs/simpad_defconfig                 |    2 +-
 arm/configs/spitz_defconfig                  |    2 +-
 arm/configs/tct_hammer_defconfig             |    2 +-
 arm/configs/trizeps4_defconfig               |    2 +-
 arm/configs/versatile_defconfig              |    2 +-
 arm/configs/yl9200_defconfig                 |    2 +-
 arm/configs/zylonite_defconfig               |    2 +-
 avr32/configs/atngw100_defconfig             |    2 +-
 avr32/configs/atstk1002_defconfig            |    2 +-
 avr32/configs/atstk1003_defconfig            |    2 +-
 avr32/configs/atstk1004_defconfig            |    2 +-
 blackfin/configs/BF527-EZKIT_defconfig       |    2 +-
 blackfin/configs/BF533-EZKIT_defconfig       |    2 +-
 blackfin/configs/BF533-STAMP_defconfig       |    2 +-
 blackfin/configs/BF537-STAMP_defconfig       |    2 +-
 blackfin/configs/BF548-EZKIT_defconfig       |    2 +-
 blackfin/configs/BF561-EZKIT_defconfig       |    2 +-
 blackfin/configs/CM-BF533_defconfig          |    2 +-
 blackfin/configs/CM-BF537E_defconfig         |    2 +-
 blackfin/configs/CM-BF537U_defconfig         |    2 +-
 blackfin/configs/CM-BF548_defconfig          |    2 +-
 blackfin/configs/CM-BF561_defconfig          |    2 +-
 blackfin/configs/H8606_defconfig             |    2 +-
 blackfin/configs/IP0X_defconfig              |    2 +-
 blackfin/configs/PNAV-10_defconfig           |    2 +-
 blackfin/configs/SRV1_defconfig              |    2 +-
 cris/artpec_3_defconfig                      |    2 +-
 cris/defconfig                               |    2 +-
 cris/etraxfs_defconfig                       |    2 +-
 frv/defconfig                                |    2 +-
 h8300/defconfig                              |    2 +-
 ia64/configs/bigsur_defconfig                |    3 +--
 ia64/configs/generic_defconfig               |    3 +--
 ia64/configs/gensparse_defconfig             |    3 +--
 ia64/configs/sim_defconfig                   |    3 +--
 ia64/configs/sn2_defconfig                   |    3 +--
 ia64/configs/tiger_defconfig                 |    3 +--
 ia64/configs/zx1_defconfig                   |    3 +--
 m32r/configs/m32104ut_defconfig              |    2 +-
 m32r/configs/m32700ut.smp_defconfig          |    2 +-
 m32r/configs/m32700ut.up_defconfig           |    2 +-
 m32r/configs/mappi.nommu_defconfig           |    2 +-
 m32r/configs/mappi.smp_defconfig             |    2 +-
 m32r/configs/mappi.up_defconfig              |    2 +-
 m32r/configs/mappi2.opsp_defconfig           |    2 +-
 m32r/configs/mappi2.vdec2_defconfig          |    2 +-
 m32r/configs/mappi3.smp_defconfig            |    2 +-
 m32r/configs/oaks32r_defconfig               |    2 +-
 m32r/configs/opsput_defconfig                |    2 +-
 m32r/configs/usrv_defconfig                  |    2 +-
 m68k/configs/amiga_defconfig                 |    2 +-
 m68k/configs/apollo_defconfig                |    2 +-
 m68k/configs/atari_defconfig                 |    2 +-
 m68k/configs/bvme6000_defconfig              |    2 +-
 m68k/configs/hp300_defconfig                 |    2 +-
 m68k/configs/mac_defconfig                   |    2 +-
 m68k/configs/multi_defconfig                 |    2 +-
 m68k/configs/mvme147_defconfig               |    2 +-
 m68k/configs/mvme16x_defconfig               |    2 +-
 m68k/configs/q40_defconfig                   |    2 +-
 m68k/configs/sun3_defconfig                  |    2 +-
 m68k/configs/sun3x_defconfig                 |    2 +-
 m68knommu/defconfig                          |    2 +-
 mips/configs/atlas_defconfig                 |    2 +-
 mips/configs/bcm47xx_defconfig               |    2 +-
 mips/configs/bigsur_defconfig                |    2 +-
 mips/configs/capcella_defconfig              |    2 +-
 mips/configs/cobalt_defconfig                |    2 +-
 mips/configs/db1000_defconfig                |    2 +-
 mips/configs/db1100_defconfig                |    2 +-
 mips/configs/db1200_defconfig                |    2 +-
 mips/configs/db1500_defconfig                |    2 +-
 mips/configs/db1550_defconfig                |    2 +-
 mips/configs/decstation_defconfig            |    2 +-
 mips/configs/e55_defconfig                   |    2 +-
 mips/configs/emma2rh_defconfig               |    2 +-
 mips/configs/excite_defconfig                |    2 +-
 mips/configs/fulong_defconfig                |    2 +-
 mips/configs/ip22_defconfig                  |    2 +-
 mips/configs/ip27_defconfig                  |    2 +-
 mips/configs/ip28_defconfig                  |    2 +-
 mips/configs/ip32_defconfig                  |    2 +-
 mips/configs/jazz_defconfig                  |    2 +-
 mips/configs/jmr3927_defconfig               |    2 +-
 mips/configs/lasat_defconfig                 |    2 +-
 mips/configs/malta_defconfig                 |    2 +-
 mips/configs/mipssim_defconfig               |    2 +-
 mips/configs/mpc30x_defconfig                |    2 +-
 mips/configs/msp71xx_defconfig               |    2 +-
 mips/configs/mtx1_defconfig                  |    2 +-
 mips/configs/pb1100_defconfig                |    2 +-
 mips/configs/pb1500_defconfig                |    2 +-
 mips/configs/pb1550_defconfig                |    2 +-
 mips/configs/pnx8550-jbs_defconfig           |    2 +-
 mips/configs/pnx8550-stb810_defconfig        |    2 +-
 mips/configs/rbhma4200_defconfig             |    2 +-
 mips/configs/rbhma4500_defconfig             |    2 +-
 mips/configs/rm200_defconfig                 |    2 +-
 mips/configs/sb1250-swarm_defconfig          |    2 +-
 mips/configs/sead_defconfig                  |    2 +-
 mips/configs/tb0219_defconfig                |    2 +-
 mips/configs/tb0226_defconfig                |    2 +-
 mips/configs/tb0287_defconfig                |    2 +-
 mips/configs/workpad_defconfig               |    2 +-
 mips/configs/wrppmc_defconfig                |    2 +-
 mips/configs/yosemite_defconfig              |    2 +-
 mn10300/configs/asb2303_defconfig            |    2 +-
 parisc/configs/712_defconfig                 |    2 +-
 parisc/configs/a500_defconfig                |    2 +-
 parisc/configs/b180_defconfig                |    2 +-
 parisc/configs/c3000_defconfig               |    2 +-
 parisc/configs/default_defconfig             |    2 +-
 powerpc/configs/40x/ep405_defconfig          |    2 +-
 powerpc/configs/40x/kilauea_defconfig        |    2 +-
 powerpc/configs/40x/makalu_defconfig         |    2 +-
 powerpc/configs/40x/walnut_defconfig         |    2 +-
 powerpc/configs/44x/bamboo_defconfig         |    2 +-
 powerpc/configs/44x/canyonlands_defconfig    |    2 +-
 powerpc/configs/44x/ebony_defconfig          |    2 +-
 powerpc/configs/44x/katmai_defconfig         |    2 +-
 powerpc/configs/44x/rainier_defconfig        |    2 +-
 powerpc/configs/44x/sequoia_defconfig        |    2 +-
 powerpc/configs/44x/taishan_defconfig        |    2 +-
 powerpc/configs/44x/warp_defconfig           |    2 +-
 powerpc/configs/52xx/cm5200_defconfig        |    2 +-
 powerpc/configs/52xx/lite5200b_defconfig     |    2 +-
 powerpc/configs/52xx/motionpro_defconfig     |    2 +-
 powerpc/configs/52xx/pcm030_defconfig        |    2 +-
 powerpc/configs/52xx/tqm5200_defconfig       |    2 +-
 powerpc/configs/83xx/mpc8313_rdb_defconfig   |    2 +-
 powerpc/configs/83xx/mpc8315_rdb_defconfig   |    2 +-
 powerpc/configs/83xx/mpc832x_mds_defconfig   |    2 +-
 powerpc/configs/83xx/mpc832x_rdb_defconfig   |    2 +-
 powerpc/configs/83xx/mpc834x_itx_defconfig   |    2 +-
 powerpc/configs/83xx/mpc834x_itxgp_defconfig |    2 +-
 powerpc/configs/83xx/mpc834x_mds_defconfig   |    2 +-
 powerpc/configs/83xx/mpc836x_mds_defconfig   |    2 +-
 powerpc/configs/83xx/mpc837x_mds_defconfig   |    2 +-
 powerpc/configs/83xx/mpc837x_rdb_defconfig   |    2 +-
 powerpc/configs/83xx/sbc834x_defconfig       |    2 +-
 powerpc/configs/85xx/ksi8560_defconfig       |    2 +-
 powerpc/configs/85xx/mpc8540_ads_defconfig   |    2 +-
 powerpc/configs/85xx/mpc8544_ds_defconfig    |    2 +-
 powerpc/configs/85xx/mpc8560_ads_defconfig   |    2 +-
 powerpc/configs/85xx/mpc8568mds_defconfig    |    2 +-
 powerpc/configs/85xx/mpc8572_ds_defconfig    |    2 +-
 powerpc/configs/85xx/mpc85xx_cds_defconfig   |    2 +-
 powerpc/configs/85xx/sbc8548_defconfig       |    2 +-
 powerpc/configs/85xx/sbc8560_defconfig       |    2 +-
 powerpc/configs/85xx/stx_gp3_defconfig       |    2 +-
 powerpc/configs/85xx/tqm8540_defconfig       |    2 +-
 powerpc/configs/85xx/tqm8541_defconfig       |    2 +-
 powerpc/configs/85xx/tqm8555_defconfig       |    2 +-
 powerpc/configs/85xx/tqm8560_defconfig       |    2 +-
 powerpc/configs/adder875_defconfig           |    2 +-
 powerpc/configs/cell_defconfig               |    3 +--
 powerpc/configs/celleb_defconfig             |    3 +--
 powerpc/configs/chrp32_defconfig             |    2 +-
 powerpc/configs/ep8248e_defconfig            |    2 +-
 powerpc/configs/ep88xc_defconfig             |    2 +-
 powerpc/configs/g5_defconfig                 |    3 +--
 powerpc/configs/holly_defconfig              |    2 +-
 powerpc/configs/iseries_defconfig            |    3 +--
 powerpc/configs/linkstation_defconfig        |    2 +-
 powerpc/configs/maple_defconfig              |    3 +--
 powerpc/configs/mpc5200_defconfig            |    2 +-
 powerpc/configs/mpc7448_hpc2_defconfig       |    2 +-
 powerpc/configs/mpc8272_ads_defconfig        |    2 +-
 powerpc/configs/mpc83xx_defconfig            |    2 +-
 powerpc/configs/mpc85xx_defconfig            |    2 +-
 powerpc/configs/mpc8610_hpcd_defconfig       |    2 +-
 powerpc/configs/mpc8641_hpcn_defconfig       |    2 +-
 powerpc/configs/mpc866_ads_defconfig         |    2 +-
 powerpc/configs/mpc885_ads_defconfig         |    2 +-
 powerpc/configs/pasemi_defconfig             |    3 +--
 powerpc/configs/pmac32_defconfig             |    2 +-
 powerpc/configs/ppc40x_defconfig             |    2 +-
 powerpc/configs/ppc44x_defconfig             |    2 +-
 powerpc/configs/ppc64_defconfig              |    3 +--
 powerpc/configs/pq2fads_defconfig            |    2 +-
 powerpc/configs/prpmc2800_defconfig          |    2 +-
 powerpc/configs/ps3_defconfig                |    3 +--
 powerpc/configs/pseries_defconfig            |    3 +--
 powerpc/configs/sbc8641d_defconfig           |    2 +-
 powerpc/configs/storcenter_defconfig         |    2 +-
 ppc/configs/bamboo_defconfig                 |    2 +-
 ppc/configs/bubinga_defconfig                |    2 +-
 ppc/configs/chestnut_defconfig               |    2 +-
 ppc/configs/cpci405_defconfig                |    2 +-
 ppc/configs/cpci690_defconfig                |    2 +-
 ppc/configs/ebony_defconfig                  |    2 +-
 ppc/configs/ep405_defconfig                  |    2 +-
 ppc/configs/ev64260_defconfig                |    2 +-
 ppc/configs/ev64360_defconfig                |    2 +-
 ppc/configs/hdpu_defconfig                   |    2 +-
 ppc/configs/katana_defconfig                 |    2 +-
 ppc/configs/lite5200_defconfig               |    2 +-
 ppc/configs/lopec_defconfig                  |    2 +-
 ppc/configs/luan_defconfig                   |    2 +-
 ppc/configs/ml300_defconfig                  |    2 +-
 ppc/configs/ml403_defconfig                  |    2 +-
 ppc/configs/mvme5100_defconfig               |    2 +-
 ppc/configs/ocotea_defconfig                 |    2 +-
 ppc/configs/pplus_defconfig                  |    2 +-
 ppc/configs/prep_defconfig                   |    2 +-
 ppc/configs/prpmc750_defconfig               |    2 +-
 ppc/configs/prpmc800_defconfig               |    2 +-
 ppc/configs/radstone_ppc7d_defconfig         |    2 +-
 ppc/configs/redwood5_defconfig               |    2 +-
 ppc/configs/redwood6_defconfig               |    2 +-
 ppc/configs/rpx8260_defconfig                |    2 +-
 ppc/configs/rpxcllf_defconfig                |    3 +--
 ppc/configs/rpxlite_defconfig                |    3 +--
 ppc/configs/sandpoint_defconfig              |    2 +-
 ppc/configs/spruce_defconfig                 |    2 +-
 ppc/configs/sycamore_defconfig               |    2 +-
 ppc/configs/taishan_defconfig                |    2 +-
 ppc/configs/walnut_defconfig                 |    2 +-
 s390/defconfig                               |    3 +--
 sh/configs/cayman_defconfig                  |    3 +--
 sh/configs/dreamcast_defconfig               |    3 +--
 sh/configs/hp6xx_defconfig                   |    3 +--
 sh/configs/landisk_defconfig                 |    3 +--
 sh/configs/lboxre2_defconfig                 |    3 +--
 sh/configs/magicpanelr2_defconfig            |    3 +--
 sh/configs/microdev_defconfig                |    3 +--
 sh/configs/migor_defconfig                   |    3 +--
 sh/configs/r7780mp_defconfig                 |    3 +--
 sh/configs/r7785rp_defconfig                 |    3 +--
 sh/configs/rsk7203_defconfig                 |    2 +-
 sh/configs/rts7751r2d1_defconfig             |    3 +--
 sh/configs/rts7751r2dplus_defconfig          |    3 +--
 sh/configs/sdk7780_defconfig                 |    3 +--
 sh/configs/se7206_defconfig                  |    2 +-
 sh/configs/se7343_defconfig                  |    3 +--
 sh/configs/se7619_defconfig                  |    2 +-
 sh/configs/se7705_defconfig                  |    3 +--
 sh/configs/se7712_defconfig                  |    3 +--
 sh/configs/se7721_defconfig                  |    3 +--
 sh/configs/se7722_defconfig                  |    3 +--
 sh/configs/se7750_defconfig                  |    3 +--
 sh/configs/se7751_defconfig                  |    3 +--
 sh/configs/se7780_defconfig                  |    3 +--
 sh/configs/sh03_defconfig                    |    3 +--
 sh/configs/sh7710voipgw_defconfig            |    3 +--
 sh/configs/shmin_defconfig                   |    3 +--
 sh/configs/shx3_defconfig                    |    3 +--
 sh/configs/snapgear_defconfig                |    3 +--
 sh/configs/systemh_defconfig                 |    3 +--
 sh/configs/titan_defconfig                   |    3 +--
 sparc/defconfig                              |    2 +-
 sparc64/defconfig                            |    3 +--
 um/defconfig                                 |    2 +-
 v850/configs/rte-ma1-cb_defconfig            |    2 +-
 v850/configs/rte-me2-cb_defconfig            |    2 +-
 v850/configs/sim_defconfig                   |    2 +-
 x86/configs/i386_defconfig                   |    3 +--
 x86/configs/x86_64_defconfig                 |    3 +--
 xtensa/configs/common_defconfig              |    2 +-
 xtensa/configs/iss_defconfig                 |    2 +-
 335 files changed, 335 insertions(+), 385 deletions(-)

--

commit 68157153175744f02f1b0c4d3b0f3d019dfc897a
Author: Adam Litke <agl@us.ibm.com>
Date:   Thu Jun 12 07:34:53 2008 -0700

    Modify defconfig files

diff --git a/arch/alpha/defconfig b/arch/alpha/defconfig
index e43f68f..6ec1caf 100644
--- a/arch/alpha/defconfig
+++ b/arch/alpha/defconfig
@@ -774,7 +774,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/am200epdkit_defconfig b/arch/arm/configs/am200epdkit_defconfig
index 5e68420..f9ba6a2 100644
--- a/arch/arm/configs/am200epdkit_defconfig
+++ b/arch/arm/configs/am200epdkit_defconfig
@@ -925,7 +925,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/assabet_defconfig b/arch/arm/configs/assabet_defconfig
index b1cd331..6a8e449 100644
--- a/arch/arm/configs/assabet_defconfig
+++ b/arch/arm/configs/assabet_defconfig
@@ -755,7 +755,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/at91cap9adk_defconfig b/arch/arm/configs/at91cap9adk_defconfig
index e32e736..85a9be9 100644
--- a/arch/arm/configs/at91cap9adk_defconfig
+++ b/arch/arm/configs/at91cap9adk_defconfig
@@ -976,7 +976,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/at91rm9200dk_defconfig b/arch/arm/configs/at91rm9200dk_defconfig
index 2dbbbc3..2a9ea5a 100644
--- a/arch/arm/configs/at91rm9200dk_defconfig
+++ b/arch/arm/configs/at91rm9200dk_defconfig
@@ -910,7 +910,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 
diff --git a/arch/arm/configs/at91rm9200ek_defconfig b/arch/arm/configs/at91rm9200ek_defconfig
index 6e994f7..acaf410 100644
--- a/arch/arm/configs/at91rm9200ek_defconfig
+++ b/arch/arm/configs/at91rm9200ek_defconfig
@@ -899,7 +899,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 
diff --git a/arch/arm/configs/at91sam9260ek_defconfig b/arch/arm/configs/at91sam9260ek_defconfig
index f659c93..d1156f0 100644
--- a/arch/arm/configs/at91sam9260ek_defconfig
+++ b/arch/arm/configs/at91sam9260ek_defconfig
@@ -895,7 +895,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/at91sam9261ek_defconfig b/arch/arm/configs/at91sam9261ek_defconfig
index 3802e85..38a81c4 100644
--- a/arch/arm/configs/at91sam9261ek_defconfig
+++ b/arch/arm/configs/at91sam9261ek_defconfig
@@ -1033,7 +1033,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/at91sam9263ek_defconfig b/arch/arm/configs/at91sam9263ek_defconfig
index 32a0d74..297648c 100644
--- a/arch/arm/configs/at91sam9263ek_defconfig
+++ b/arch/arm/configs/at91sam9263ek_defconfig
@@ -1041,7 +1041,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/at91sam9rlek_defconfig b/arch/arm/configs/at91sam9rlek_defconfig
index 98e6746..98f7877 100644
--- a/arch/arm/configs/at91sam9rlek_defconfig
+++ b/arch/arm/configs/at91sam9rlek_defconfig
@@ -808,7 +808,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/ateb9200_defconfig b/arch/arm/configs/ateb9200_defconfig
index d846a49..b241907 100644
--- a/arch/arm/configs/ateb9200_defconfig
+++ b/arch/arm/configs/ateb9200_defconfig
@@ -1127,7 +1127,7 @@ CONFIG_NTFS_RW=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/badge4_defconfig b/arch/arm/configs/badge4_defconfig
index b2bbf21..88c9091 100644
--- a/arch/arm/configs/badge4_defconfig
+++ b/arch/arm/configs/badge4_defconfig
@@ -1080,7 +1080,7 @@ CONFIG_DEVFS_MOUNT=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/cam60_defconfig b/arch/arm/configs/cam60_defconfig
index f3cd4a9..51ef2a2 100644
--- a/arch/arm/configs/cam60_defconfig
+++ b/arch/arm/configs/cam60_defconfig
@@ -1016,7 +1016,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=y
 
 #
diff --git a/arch/arm/configs/carmeva_defconfig b/arch/arm/configs/carmeva_defconfig
index d392833..0194819 100644
--- a/arch/arm/configs/carmeva_defconfig
+++ b/arch/arm/configs/carmeva_defconfig
@@ -591,7 +591,7 @@ CONFIG_SYSFS=y
 CONFIG_DEVPTS_FS_XATTR=y
 CONFIG_DEVPTS_FS_SECURITY=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/cerfcube_defconfig b/arch/arm/configs/cerfcube_defconfig
index ee130b5..2b9e55a 100644
--- a/arch/arm/configs/cerfcube_defconfig
+++ b/arch/arm/configs/cerfcube_defconfig
@@ -711,7 +711,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/clps7500_defconfig b/arch/arm/configs/clps7500_defconfig
index 49e9f9d..e5cf94c 100644
--- a/arch/arm/configs/clps7500_defconfig
+++ b/arch/arm/configs/clps7500_defconfig
@@ -701,7 +701,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/cm_x270_defconfig b/arch/arm/configs/cm_x270_defconfig
index 5cab083..92a53f8 100644
--- a/arch/arm/configs/cm_x270_defconfig
+++ b/arch/arm/configs/cm_x270_defconfig
@@ -1206,7 +1206,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/colibri_defconfig b/arch/arm/configs/colibri_defconfig
index c3e3418..5e0c8fa 100644
--- a/arch/arm/configs/colibri_defconfig
+++ b/arch/arm/configs/colibri_defconfig
@@ -1257,7 +1257,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=y
 
 #
diff --git a/arch/arm/configs/collie_defconfig b/arch/arm/configs/collie_defconfig
index 4264e27..954f3c1 100644
--- a/arch/arm/configs/collie_defconfig
+++ b/arch/arm/configs/collie_defconfig
@@ -814,7 +814,7 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/corgi_defconfig b/arch/arm/configs/corgi_defconfig
index e8980a9..883a82d 100644
--- a/arch/arm/configs/corgi_defconfig
+++ b/arch/arm/configs/corgi_defconfig
@@ -1364,7 +1364,7 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 
diff --git a/arch/arm/configs/csb337_defconfig b/arch/arm/configs/csb337_defconfig
index 67e65e4..e8d9ff5 100644
--- a/arch/arm/configs/csb337_defconfig
+++ b/arch/arm/configs/csb337_defconfig
@@ -1055,7 +1055,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/csb637_defconfig b/arch/arm/configs/csb637_defconfig
index 9970214..affad51 100644
--- a/arch/arm/configs/csb637_defconfig
+++ b/arch/arm/configs/csb637_defconfig
@@ -1053,7 +1053,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/ebsa110_defconfig b/arch/arm/configs/ebsa110_defconfig
index afcfff6..75a568a 100644
--- a/arch/arm/configs/ebsa110_defconfig
+++ b/arch/arm/configs/ebsa110_defconfig
@@ -647,7 +647,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/ecbat91_defconfig b/arch/arm/configs/ecbat91_defconfig
index 90ed214..d441f92 100644
--- a/arch/arm/configs/ecbat91_defconfig
+++ b/arch/arm/configs/ecbat91_defconfig
@@ -1110,7 +1110,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=y
 
diff --git a/arch/arm/configs/edb7211_defconfig b/arch/arm/configs/edb7211_defconfig
index 6ba7355..a98a00d 100644
--- a/arch/arm/configs/edb7211_defconfig
+++ b/arch/arm/configs/edb7211_defconfig
@@ -484,7 +484,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/em_x270_defconfig b/arch/arm/configs/em_x270_defconfig
index 6bea090..0247484 100644
--- a/arch/arm/configs/em_x270_defconfig
+++ b/arch/arm/configs/em_x270_defconfig
@@ -1045,7 +1045,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/ep93xx_defconfig b/arch/arm/configs/ep93xx_defconfig
index 24a701a..6f937a3 100644
--- a/arch/arm/configs/ep93xx_defconfig
+++ b/arch/arm/configs/ep93xx_defconfig
@@ -1036,7 +1036,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/eseries_pxa_defconfig b/arch/arm/configs/eseries_pxa_defconfig
index ed487b9..6589e48 100644
--- a/arch/arm/configs/eseries_pxa_defconfig
+++ b/arch/arm/configs/eseries_pxa_defconfig
@@ -1292,7 +1292,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/footbridge_defconfig b/arch/arm/configs/footbridge_defconfig
index 299dc22..b4c6006 100644
--- a/arch/arm/configs/footbridge_defconfig
+++ b/arch/arm/configs/footbridge_defconfig
@@ -1102,7 +1102,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/fortunet_defconfig b/arch/arm/configs/fortunet_defconfig
index 65dc73a..352dd64 100644
--- a/arch/arm/configs/fortunet_defconfig
+++ b/arch/arm/configs/fortunet_defconfig
@@ -480,7 +480,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/h3600_defconfig b/arch/arm/configs/h3600_defconfig
index 8f986e9..d9101e6 100644
--- a/arch/arm/configs/h3600_defconfig
+++ b/arch/arm/configs/h3600_defconfig
@@ -778,7 +778,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/h7201_defconfig b/arch/arm/configs/h7201_defconfig
index 116920a..962c226 100644
--- a/arch/arm/configs/h7201_defconfig
+++ b/arch/arm/configs/h7201_defconfig
@@ -486,7 +486,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/h7202_defconfig b/arch/arm/configs/h7202_defconfig
index 0e739af..a1374b7 100644
--- a/arch/arm/configs/h7202_defconfig
+++ b/arch/arm/configs/h7202_defconfig
@@ -620,7 +620,7 @@ CONFIG_DEVFS_MOUNT=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/hackkit_defconfig b/arch/arm/configs/hackkit_defconfig
index 1c8fb89..222682b 100644
--- a/arch/arm/configs/hackkit_defconfig
+++ b/arch/arm/configs/hackkit_defconfig
@@ -635,7 +635,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/integrator_defconfig b/arch/arm/configs/integrator_defconfig
index 3ce96e6..2a180dc 100644
--- a/arch/arm/configs/integrator_defconfig
+++ b/arch/arm/configs/integrator_defconfig
@@ -735,7 +735,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/iop13xx_defconfig b/arch/arm/configs/iop13xx_defconfig
index 988b4d1..5a62119 100644
--- a/arch/arm/configs/iop13xx_defconfig
+++ b/arch/arm/configs/iop13xx_defconfig
@@ -943,7 +943,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/iop32x_defconfig b/arch/arm/configs/iop32x_defconfig
index 83f40d4..60212db 100644
--- a/arch/arm/configs/iop32x_defconfig
+++ b/arch/arm/configs/iop32x_defconfig
@@ -1191,7 +1191,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/iop33x_defconfig b/arch/arm/configs/iop33x_defconfig
index 917afb5..fd9393d 100644
--- a/arch/arm/configs/iop33x_defconfig
+++ b/arch/arm/configs/iop33x_defconfig
@@ -945,7 +945,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/ixp2000_defconfig b/arch/arm/configs/ixp2000_defconfig
index f8f9793..b9554a6 100644
--- a/arch/arm/configs/ixp2000_defconfig
+++ b/arch/arm/configs/ixp2000_defconfig
@@ -966,7 +966,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/ixp23xx_defconfig b/arch/arm/configs/ixp23xx_defconfig
index 27cf022..2fdf7d2 100644
--- a/arch/arm/configs/ixp23xx_defconfig
+++ b/arch/arm/configs/ixp23xx_defconfig
@@ -1222,7 +1222,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/ixp4xx_defconfig b/arch/arm/configs/ixp4xx_defconfig
index efa0485..ae636b5 100644
--- a/arch/arm/configs/ixp4xx_defconfig
+++ b/arch/arm/configs/ixp4xx_defconfig
@@ -1444,7 +1444,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/jornada720_defconfig b/arch/arm/configs/jornada720_defconfig
index 0c55628..3044d2d 100644
--- a/arch/arm/configs/jornada720_defconfig
+++ b/arch/arm/configs/jornada720_defconfig
@@ -808,7 +808,7 @@ CONFIG_DEVFS_MOUNT=y
 CONFIG_DEVFS_DEBUG=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/kafa_defconfig b/arch/arm/configs/kafa_defconfig
index ae51a40..96bb7b5 100644
--- a/arch/arm/configs/kafa_defconfig
+++ b/arch/arm/configs/kafa_defconfig
@@ -762,7 +762,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/kb9202_defconfig b/arch/arm/configs/kb9202_defconfig
index c16537d..7634792 100644
--- a/arch/arm/configs/kb9202_defconfig
+++ b/arch/arm/configs/kb9202_defconfig
@@ -655,7 +655,7 @@ CONFIG_DEVPTS_FS_XATTR=y
 # CONFIG_DEVPTS_FS_SECURITY is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/ks8695_defconfig b/arch/arm/configs/ks8695_defconfig
index 8ab21a0..857601b 100644
--- a/arch/arm/configs/ks8695_defconfig
+++ b/arch/arm/configs/ks8695_defconfig
@@ -777,7 +777,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/lart_defconfig b/arch/arm/configs/lart_defconfig
index a1cc34f..3386977 100644
--- a/arch/arm/configs/lart_defconfig
+++ b/arch/arm/configs/lart_defconfig
@@ -735,7 +735,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/littleton_defconfig b/arch/arm/configs/littleton_defconfig
index 1db4969..c4d58d6 100644
--- a/arch/arm/configs/littleton_defconfig
+++ b/arch/arm/configs/littleton_defconfig
@@ -624,7 +624,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/lpd270_defconfig b/arch/arm/configs/lpd270_defconfig
index a3bf583..643e2ac 100644
--- a/arch/arm/configs/lpd270_defconfig
+++ b/arch/arm/configs/lpd270_defconfig
@@ -862,7 +862,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/lpd7a400_defconfig b/arch/arm/configs/lpd7a400_defconfig
index f8ac29d..99ffcad 100644
--- a/arch/arm/configs/lpd7a400_defconfig
+++ b/arch/arm/configs/lpd7a400_defconfig
@@ -714,7 +714,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/lpd7a404_defconfig b/arch/arm/configs/lpd7a404_defconfig
index 46a0f7f..de428ca 100644
--- a/arch/arm/configs/lpd7a404_defconfig
+++ b/arch/arm/configs/lpd7a404_defconfig
@@ -953,7 +953,7 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 # CONFIG_CONFIGFS_FS is not set
diff --git a/arch/arm/configs/lubbock_defconfig b/arch/arm/configs/lubbock_defconfig
index e544bfb..b7fb2c7 100644
--- a/arch/arm/configs/lubbock_defconfig
+++ b/arch/arm/configs/lubbock_defconfig
@@ -652,7 +652,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/lusl7200_defconfig b/arch/arm/configs/lusl7200_defconfig
index 42f6a77..59f562f 100644
--- a/arch/arm/configs/lusl7200_defconfig
+++ b/arch/arm/configs/lusl7200_defconfig
@@ -385,7 +385,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/magician_defconfig b/arch/arm/configs/magician_defconfig
index 4d11678..8ffe125 100644
--- a/arch/arm/configs/magician_defconfig
+++ b/arch/arm/configs/magician_defconfig
@@ -968,7 +968,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/mainstone_defconfig b/arch/arm/configs/mainstone_defconfig
index cc8c95b..4e9e8dc 100644
--- a/arch/arm/configs/mainstone_defconfig
+++ b/arch/arm/configs/mainstone_defconfig
@@ -646,7 +646,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/msm_defconfig b/arch/arm/configs/msm_defconfig
index ae4c5e6..a9e926d 100644
--- a/arch/arm/configs/msm_defconfig
+++ b/arch/arm/configs/msm_defconfig
@@ -766,7 +766,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/mx1ads_defconfig b/arch/arm/configs/mx1ads_defconfig
index 577d7e1..bc1811c 100644
--- a/arch/arm/configs/mx1ads_defconfig
+++ b/arch/arm/configs/mx1ads_defconfig
@@ -569,7 +569,7 @@ CONFIG_DEVFS_MOUNT=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/neponset_defconfig b/arch/arm/configs/neponset_defconfig
index 92ccdc6..abfaf00 100644
--- a/arch/arm/configs/neponset_defconfig
+++ b/arch/arm/configs/neponset_defconfig
@@ -987,7 +987,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/netwinder_defconfig b/arch/arm/configs/netwinder_defconfig
index c1a63a3..7d52a56 100644
--- a/arch/arm/configs/netwinder_defconfig
+++ b/arch/arm/configs/netwinder_defconfig
@@ -862,7 +862,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/netx_defconfig b/arch/arm/configs/netx_defconfig
index 57f32f3..9360a91 100644
--- a/arch/arm/configs/netx_defconfig
+++ b/arch/arm/configs/netx_defconfig
@@ -778,7 +778,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/omap_h2_1610_defconfig b/arch/arm/configs/omap_h2_1610_defconfig
index 323c1de..61275fa 100644
--- a/arch/arm/configs/omap_h2_1610_defconfig
+++ b/arch/arm/configs/omap_h2_1610_defconfig
@@ -881,7 +881,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/omap_osk_5912_defconfig b/arch/arm/configs/omap_osk_5912_defconfig
index d4ca5e6..a69d132 100644
--- a/arch/arm/configs/omap_osk_5912_defconfig
+++ b/arch/arm/configs/omap_osk_5912_defconfig
@@ -944,7 +944,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/onearm_defconfig b/arch/arm/configs/onearm_defconfig
index 650a248..555894b 100644
--- a/arch/arm/configs/onearm_defconfig
+++ b/arch/arm/configs/onearm_defconfig
@@ -1009,7 +1009,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/orion5x_defconfig b/arch/arm/configs/orion5x_defconfig
index 52cd99b..94c76c4 100644
--- a/arch/arm/configs/orion5x_defconfig
+++ b/arch/arm/configs/orion5x_defconfig
@@ -1179,7 +1179,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/pcm027_defconfig b/arch/arm/configs/pcm027_defconfig
index 17b9b24..365b759 100644
--- a/arch/arm/configs/pcm027_defconfig
+++ b/arch/arm/configs/pcm027_defconfig
@@ -939,7 +939,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/picotux200_defconfig b/arch/arm/configs/picotux200_defconfig
index 95a22f5..e3f4563 100644
--- a/arch/arm/configs/picotux200_defconfig
+++ b/arch/arm/configs/picotux200_defconfig
@@ -1148,7 +1148,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/pleb_defconfig b/arch/arm/configs/pleb_defconfig
index a6b47ea..bc1b507 100644
--- a/arch/arm/configs/pleb_defconfig
+++ b/arch/arm/configs/pleb_defconfig
@@ -608,7 +608,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/pnx4008_defconfig b/arch/arm/configs/pnx4008_defconfig
index b5e11aa..6b54c2d 100644
--- a/arch/arm/configs/pnx4008_defconfig
+++ b/arch/arm/configs/pnx4008_defconfig
@@ -1417,7 +1417,7 @@ CONFIG_NTFS_FS=m
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/pxa255-idp_defconfig b/arch/arm/configs/pxa255-idp_defconfig
index 46e5089..bfa6215 100644
--- a/arch/arm/configs/pxa255-idp_defconfig
+++ b/arch/arm/configs/pxa255-idp_defconfig
@@ -648,7 +648,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/realview-smp_defconfig b/arch/arm/configs/realview-smp_defconfig
index fc39ba1..46a47ae 100644
--- a/arch/arm/configs/realview-smp_defconfig
+++ b/arch/arm/configs/realview-smp_defconfig
@@ -835,7 +835,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/realview_defconfig b/arch/arm/configs/realview_defconfig
index accbf52..9ebfa20 100644
--- a/arch/arm/configs/realview_defconfig
+++ b/arch/arm/configs/realview_defconfig
@@ -657,7 +657,7 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 
diff --git a/arch/arm/configs/rpc_defconfig b/arch/arm/configs/rpc_defconfig
index 5ddecb9..bdb7102 100644
--- a/arch/arm/configs/rpc_defconfig
+++ b/arch/arm/configs/rpc_defconfig
@@ -832,7 +832,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/s3c2410_defconfig b/arch/arm/configs/s3c2410_defconfig
index f8a1645..3d863e9 100644
--- a/arch/arm/configs/s3c2410_defconfig
+++ b/arch/arm/configs/s3c2410_defconfig
@@ -1231,7 +1231,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/sam9_l9260_defconfig b/arch/arm/configs/sam9_l9260_defconfig
index 484dc97..ab3ac0b 100644
--- a/arch/arm/configs/sam9_l9260_defconfig
+++ b/arch/arm/configs/sam9_l9260_defconfig
@@ -921,7 +921,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/shannon_defconfig b/arch/arm/configs/shannon_defconfig
index d052c8f..3becc93 100644
--- a/arch/arm/configs/shannon_defconfig
+++ b/arch/arm/configs/shannon_defconfig
@@ -720,7 +720,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/shark_defconfig b/arch/arm/configs/shark_defconfig
index 9b6561d..5adfc82 100644
--- a/arch/arm/configs/shark_defconfig
+++ b/arch/arm/configs/shark_defconfig
@@ -840,7 +840,7 @@ CONFIG_DEVFS_MOUNT=y
 # CONFIG_DEVFS_DEBUG is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/simpad_defconfig b/arch/arm/configs/simpad_defconfig
index 03f783e..b523fe1 100644
--- a/arch/arm/configs/simpad_defconfig
+++ b/arch/arm/configs/simpad_defconfig
@@ -809,7 +809,7 @@ CONFIG_DEVFS_MOUNT=y
 # CONFIG_DEVFS_DEBUG is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/arm/configs/spitz_defconfig b/arch/arm/configs/spitz_defconfig
index aa7a011..29951da 100644
--- a/arch/arm/configs/spitz_defconfig
+++ b/arch/arm/configs/spitz_defconfig
@@ -1257,7 +1257,7 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 
diff --git a/arch/arm/configs/tct_hammer_defconfig b/arch/arm/configs/tct_hammer_defconfig
index 576b833..247f57b 100644
--- a/arch/arm/configs/tct_hammer_defconfig
+++ b/arch/arm/configs/tct_hammer_defconfig
@@ -737,7 +737,7 @@ CONFIG_PROC_FS=y
 # CONFIG_PROC_SYSCTL is not set
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/arm/configs/trizeps4_defconfig b/arch/arm/configs/trizeps4_defconfig
index 6db6392..4c633f7 100644
--- a/arch/arm/configs/trizeps4_defconfig
+++ b/arch/arm/configs/trizeps4_defconfig
@@ -1474,7 +1474,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/versatile_defconfig b/arch/arm/configs/versatile_defconfig
index 48dca69..672346e 100644
--- a/arch/arm/configs/versatile_defconfig
+++ b/arch/arm/configs/versatile_defconfig
@@ -821,7 +821,7 @@ CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/arm/configs/yl9200_defconfig b/arch/arm/configs/yl9200_defconfig
index 26de37f..e6db85c 100644
--- a/arch/arm/configs/yl9200_defconfig
+++ b/arch/arm/configs/yl9200_defconfig
@@ -1050,7 +1050,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 
 #
 # Miscellaneous filesystems
diff --git a/arch/arm/configs/zylonite_defconfig b/arch/arm/configs/zylonite_defconfig
index 7949d04..ef8b0f0 100644
--- a/arch/arm/configs/zylonite_defconfig
+++ b/arch/arm/configs/zylonite_defconfig
@@ -605,7 +605,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/avr32/configs/atngw100_defconfig b/arch/avr32/configs/atngw100_defconfig
index 119edb8..da4fac8 100644
--- a/arch/avr32/configs/atngw100_defconfig
+++ b/arch/avr32/configs/atngw100_defconfig
@@ -894,7 +894,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/avr32/configs/atstk1002_defconfig b/arch/avr32/configs/atstk1002_defconfig
index c6d02ea..a9f3df9 100644
--- a/arch/avr32/configs/atstk1002_defconfig
+++ b/arch/avr32/configs/atstk1002_defconfig
@@ -992,7 +992,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/avr32/configs/atstk1003_defconfig b/arch/avr32/configs/atstk1003_defconfig
index 5a4ae6b..7066927 100644
--- a/arch/avr32/configs/atstk1003_defconfig
+++ b/arch/avr32/configs/atstk1003_defconfig
@@ -916,7 +916,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/avr32/configs/atstk1004_defconfig b/arch/avr32/configs/atstk1004_defconfig
index a0912fb..59b63f6 100644
--- a/arch/avr32/configs/atstk1004_defconfig
+++ b/arch/avr32/configs/atstk1004_defconfig
@@ -587,7 +587,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/blackfin/configs/BF527-EZKIT_defconfig b/arch/blackfin/configs/BF527-EZKIT_defconfig
index 5e6fb9d..26d1eb3 100644
--- a/arch/blackfin/configs/BF527-EZKIT_defconfig
+++ b/arch/blackfin/configs/BF527-EZKIT_defconfig
@@ -1094,7 +1094,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/blackfin/configs/BF533-EZKIT_defconfig b/arch/blackfin/configs/BF533-EZKIT_defconfig
index 8d817ba..14f1366 100644
--- a/arch/blackfin/configs/BF533-EZKIT_defconfig
+++ b/arch/blackfin/configs/BF533-EZKIT_defconfig
@@ -944,7 +944,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/BF533-STAMP_defconfig b/arch/blackfin/configs/BF533-STAMP_defconfig
index 20d598d..64d4bd5 100644
--- a/arch/blackfin/configs/BF533-STAMP_defconfig
+++ b/arch/blackfin/configs/BF533-STAMP_defconfig
@@ -1122,7 +1122,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/BF537-STAMP_defconfig b/arch/blackfin/configs/BF537-STAMP_defconfig
index b5189c8..1f38032 100644
--- a/arch/blackfin/configs/BF537-STAMP_defconfig
+++ b/arch/blackfin/configs/BF537-STAMP_defconfig
@@ -1185,7 +1185,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/BF548-EZKIT_defconfig b/arch/blackfin/configs/BF548-EZKIT_defconfig
index 1ff2ff4..77195d4 100644
--- a/arch/blackfin/configs/BF548-EZKIT_defconfig
+++ b/arch/blackfin/configs/BF548-EZKIT_defconfig
@@ -1344,7 +1344,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/blackfin/configs/BF561-EZKIT_defconfig b/arch/blackfin/configs/BF561-EZKIT_defconfig
index b4a20c8..4b87450 100644
--- a/arch/blackfin/configs/BF561-EZKIT_defconfig
+++ b/arch/blackfin/configs/BF561-EZKIT_defconfig
@@ -949,7 +949,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/CM-BF533_defconfig b/arch/blackfin/configs/CM-BF533_defconfig
index 560890f..5c2269e 100644
--- a/arch/blackfin/configs/CM-BF533_defconfig
+++ b/arch/blackfin/configs/CM-BF533_defconfig
@@ -803,7 +803,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/CM-BF537E_defconfig b/arch/blackfin/configs/CM-BF537E_defconfig
index 9f66d2d..a42b598 100644
--- a/arch/blackfin/configs/CM-BF537E_defconfig
+++ b/arch/blackfin/configs/CM-BF537E_defconfig
@@ -831,7 +831,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/CM-BF537U_defconfig b/arch/blackfin/configs/CM-BF537U_defconfig
index 2694d06..a642db7 100644
--- a/arch/blackfin/configs/CM-BF537U_defconfig
+++ b/arch/blackfin/configs/CM-BF537U_defconfig
@@ -831,7 +831,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/CM-BF548_defconfig b/arch/blackfin/configs/CM-BF548_defconfig
index 9020725..210ba2c 100644
--- a/arch/blackfin/configs/CM-BF548_defconfig
+++ b/arch/blackfin/configs/CM-BF548_defconfig
@@ -1181,7 +1181,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/blackfin/configs/CM-BF561_defconfig b/arch/blackfin/configs/CM-BF561_defconfig
index daf0090..189a4f6 100644
--- a/arch/blackfin/configs/CM-BF561_defconfig
+++ b/arch/blackfin/configs/CM-BF561_defconfig
@@ -781,7 +781,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/blackfin/configs/H8606_defconfig b/arch/blackfin/configs/H8606_defconfig
index 679c748..6b6414e 100644
--- a/arch/blackfin/configs/H8606_defconfig
+++ b/arch/blackfin/configs/H8606_defconfig
@@ -992,7 +992,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/IP0X_defconfig b/arch/blackfin/configs/IP0X_defconfig
index 4384a67..f885a3d 100644
--- a/arch/blackfin/configs/IP0X_defconfig
+++ b/arch/blackfin/configs/IP0X_defconfig
@@ -1094,7 +1094,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/PNAV-10_defconfig b/arch/blackfin/configs/PNAV-10_defconfig
index 87622ad..bef89b2 100644
--- a/arch/blackfin/configs/PNAV-10_defconfig
+++ b/arch/blackfin/configs/PNAV-10_defconfig
@@ -1105,7 +1105,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/blackfin/configs/SRV1_defconfig b/arch/blackfin/configs/SRV1_defconfig
index 951ea04..a2f8435 100644
--- a/arch/blackfin/configs/SRV1_defconfig
+++ b/arch/blackfin/configs/SRV1_defconfig
@@ -1092,7 +1092,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/cris/artpec_3_defconfig b/arch/cris/artpec_3_defconfig
index 41fe674..24fcf81 100644
--- a/arch/cris/artpec_3_defconfig
+++ b/arch/cris/artpec_3_defconfig
@@ -484,7 +484,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/cris/defconfig b/arch/cris/defconfig
index 59f36a5..4d0684d 100644
--- a/arch/cris/defconfig
+++ b/arch/cris/defconfig
@@ -482,7 +482,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/cris/etraxfs_defconfig b/arch/cris/etraxfs_defconfig
index 73c646a..e75bf83 100644
--- a/arch/cris/etraxfs_defconfig
+++ b/arch/cris/etraxfs_defconfig
@@ -487,7 +487,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/frv/defconfig b/arch/frv/defconfig
index b6e4ca5..686fec1 100644
--- a/arch/frv/defconfig
+++ b/arch/frv/defconfig
@@ -529,7 +529,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 
diff --git a/arch/h8300/defconfig b/arch/h8300/defconfig
index 8901cdb..4837532 100644
--- a/arch/h8300/defconfig
+++ b/arch/h8300/defconfig
@@ -301,7 +301,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index 6dd8655..3df05de 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -1153,8 +1153,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 # CONFIG_CONFIGFS_FS is not set
diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 0210545..49acb81 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -1203,8 +1203,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index e86fbd3..f4cad4a 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -1182,8 +1182,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 # CONFIG_CONFIGFS_FS is not set
diff --git a/arch/ia64/configs/sim_defconfig b/arch/ia64/configs/sim_defconfig
index 546a772..ddbdb88 100644
--- a/arch/ia64/configs/sim_defconfig
+++ b/arch/ia64/configs/sim_defconfig
@@ -581,8 +581,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 # CONFIG_CONFIGFS_FS is not set
diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index 7f6b237..8b35d0f 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -1049,8 +1049,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index 797acf9..85630ab 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -1044,8 +1044,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index 0a06b13..e1a8967 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -1381,8 +1381,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/m32104ut_defconfig b/arch/m32r/configs/m32104ut_defconfig
index 9b5af6c..d0c755a 100644
--- a/arch/m32r/configs/m32104ut_defconfig
+++ b/arch/m32r/configs/m32104ut_defconfig
@@ -841,7 +841,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/m32r/configs/m32700ut.smp_defconfig b/arch/m32r/configs/m32700ut.smp_defconfig
index af3b981..8ab11cb 100644
--- a/arch/m32r/configs/m32700ut.smp_defconfig
+++ b/arch/m32r/configs/m32700ut.smp_defconfig
@@ -724,7 +724,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/m32700ut.up_defconfig b/arch/m32r/configs/m32700ut.up_defconfig
index a31823f..b33b5aa 100644
--- a/arch/m32r/configs/m32700ut.up_defconfig
+++ b/arch/m32r/configs/m32700ut.up_defconfig
@@ -721,7 +721,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/mappi.nommu_defconfig b/arch/m32r/configs/mappi.nommu_defconfig
index e3379de..fcd8d0f 100644
--- a/arch/m32r/configs/mappi.nommu_defconfig
+++ b/arch/m32r/configs/mappi.nommu_defconfig
@@ -520,7 +520,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/mappi.smp_defconfig b/arch/m32r/configs/mappi.smp_defconfig
index b86fb37..5af651f 100644
--- a/arch/m32r/configs/mappi.smp_defconfig
+++ b/arch/m32r/configs/mappi.smp_defconfig
@@ -626,7 +626,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/mappi.up_defconfig b/arch/m32r/configs/mappi.up_defconfig
index 114a6c9..0cc56f4 100644
--- a/arch/m32r/configs/mappi.up_defconfig
+++ b/arch/m32r/configs/mappi.up_defconfig
@@ -623,7 +623,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/mappi2.opsp_defconfig b/arch/m32r/configs/mappi2.opsp_defconfig
index 54bb6e2..bb8fd1b 100644
--- a/arch/m32r/configs/mappi2.opsp_defconfig
+++ b/arch/m32r/configs/mappi2.opsp_defconfig
@@ -611,7 +611,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/mappi2.vdec2_defconfig b/arch/m32r/configs/mappi2.vdec2_defconfig
index 42247ae..85ea6e1 100644
--- a/arch/m32r/configs/mappi2.vdec2_defconfig
+++ b/arch/m32r/configs/mappi2.vdec2_defconfig
@@ -609,7 +609,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/mappi3.smp_defconfig b/arch/m32r/configs/mappi3.smp_defconfig
index 18c564f..0bbd448 100644
--- a/arch/m32r/configs/mappi3.smp_defconfig
+++ b/arch/m32r/configs/mappi3.smp_defconfig
@@ -630,7 +630,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/oaks32r_defconfig b/arch/m32r/configs/oaks32r_defconfig
index cc0f99a..160ecb8 100644
--- a/arch/m32r/configs/oaks32r_defconfig
+++ b/arch/m32r/configs/oaks32r_defconfig
@@ -491,7 +491,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/opsput_defconfig b/arch/m32r/configs/opsput_defconfig
index 39f5c1a..dfd2bbc 100644
--- a/arch/m32r/configs/opsput_defconfig
+++ b/arch/m32r/configs/opsput_defconfig
@@ -573,7 +573,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m32r/configs/usrv_defconfig b/arch/m32r/configs/usrv_defconfig
index 62e813e..b8ec01c 100644
--- a/arch/m32r/configs/usrv_defconfig
+++ b/arch/m32r/configs/usrv_defconfig
@@ -605,7 +605,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/m68k/configs/amiga_defconfig b/arch/m68k/configs/amiga_defconfig
index dca50da..e33d2a2 100644
--- a/arch/m68k/configs/amiga_defconfig
+++ b/arch/m68k/configs/amiga_defconfig
@@ -942,7 +942,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/apollo_defconfig b/arch/m68k/configs/apollo_defconfig
index c3cd5b7..1b92775 100644
--- a/arch/m68k/configs/apollo_defconfig
+++ b/arch/m68k/configs/apollo_defconfig
@@ -832,7 +832,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/atari_defconfig b/arch/m68k/configs/atari_defconfig
index 073ae4b..47f7bb7 100644
--- a/arch/m68k/configs/atari_defconfig
+++ b/arch/m68k/configs/atari_defconfig
@@ -883,7 +883,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/bvme6000_defconfig b/arch/m68k/configs/bvme6000_defconfig
index 0789ede..24800fa 100644
--- a/arch/m68k/configs/bvme6000_defconfig
+++ b/arch/m68k/configs/bvme6000_defconfig
@@ -802,7 +802,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/hp300_defconfig b/arch/m68k/configs/hp300_defconfig
index 3e140bf..b02a4d2 100644
--- a/arch/m68k/configs/hp300_defconfig
+++ b/arch/m68k/configs/hp300_defconfig
@@ -839,7 +839,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/mac_defconfig b/arch/m68k/configs/mac_defconfig
index ba3a917..449b4dc 100644
--- a/arch/m68k/configs/mac_defconfig
+++ b/arch/m68k/configs/mac_defconfig
@@ -879,7 +879,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/multi_defconfig b/arch/m68k/configs/multi_defconfig
index 4d23f99..ec02c32 100644
--- a/arch/m68k/configs/multi_defconfig
+++ b/arch/m68k/configs/multi_defconfig
@@ -1035,7 +1035,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/mvme147_defconfig b/arch/m68k/configs/mvme147_defconfig
index 188847f..aeb195c 100644
--- a/arch/m68k/configs/mvme147_defconfig
+++ b/arch/m68k/configs/mvme147_defconfig
@@ -801,7 +801,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/mvme16x_defconfig b/arch/m68k/configs/mvme16x_defconfig
index 983e53d..958e69a 100644
--- a/arch/m68k/configs/mvme16x_defconfig
+++ b/arch/m68k/configs/mvme16x_defconfig
@@ -803,7 +803,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/q40_defconfig b/arch/m68k/configs/q40_defconfig
index 7707f3f..f66f568 100644
--- a/arch/m68k/configs/q40_defconfig
+++ b/arch/m68k/configs/q40_defconfig
@@ -886,7 +886,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/sun3_defconfig b/arch/m68k/configs/sun3_defconfig
index a765f6f..cb7562d 100644
--- a/arch/m68k/configs/sun3_defconfig
+++ b/arch/m68k/configs/sun3_defconfig
@@ -819,7 +819,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68k/configs/sun3x_defconfig b/arch/m68k/configs/sun3x_defconfig
index 4315139..53daa25 100644
--- a/arch/m68k/configs/sun3x_defconfig
+++ b/arch/m68k/configs/sun3x_defconfig
@@ -829,7 +829,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/m68knommu/defconfig b/arch/m68knommu/defconfig
index 670b0a9..0bb6fef 100644
--- a/arch/m68knommu/defconfig
+++ b/arch/m68knommu/defconfig
@@ -548,7 +548,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/mips/configs/atlas_defconfig b/arch/mips/configs/atlas_defconfig
index 3443f6c..e4e8750 100644
--- a/arch/mips/configs/atlas_defconfig
+++ b/arch/mips/configs/atlas_defconfig
@@ -1271,7 +1271,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/bcm47xx_defconfig b/arch/mips/configs/bcm47xx_defconfig
index c0e42e7..0a72af0 100644
--- a/arch/mips/configs/bcm47xx_defconfig
+++ b/arch/mips/configs/bcm47xx_defconfig
@@ -1697,7 +1697,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/mips/configs/bigsur_defconfig b/arch/mips/configs/bigsur_defconfig
index 3b42cea..bc478eb 100644
--- a/arch/mips/configs/bigsur_defconfig
+++ b/arch/mips/configs/bigsur_defconfig
@@ -1096,7 +1096,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/mips/configs/capcella_defconfig b/arch/mips/configs/capcella_defconfig
index a94f14b..50d0dbc 100644
--- a/arch/mips/configs/capcella_defconfig
+++ b/arch/mips/configs/capcella_defconfig
@@ -710,7 +710,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/cobalt_defconfig b/arch/mips/configs/cobalt_defconfig
index b7295e9..c36c119 100644
--- a/arch/mips/configs/cobalt_defconfig
+++ b/arch/mips/configs/cobalt_defconfig
@@ -968,7 +968,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=y
 
diff --git a/arch/mips/configs/db1000_defconfig b/arch/mips/configs/db1000_defconfig
index 3657896..62cfae1 100644
--- a/arch/mips/configs/db1000_defconfig
+++ b/arch/mips/configs/db1000_defconfig
@@ -969,7 +969,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/db1100_defconfig b/arch/mips/configs/db1100_defconfig
index 5a90740..04b2aa7 100644
--- a/arch/mips/configs/db1100_defconfig
+++ b/arch/mips/configs/db1100_defconfig
@@ -969,7 +969,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/db1200_defconfig b/arch/mips/configs/db1200_defconfig
index 76f37a1..7f13197 100644
--- a/arch/mips/configs/db1200_defconfig
+++ b/arch/mips/configs/db1200_defconfig
@@ -1045,7 +1045,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/db1500_defconfig b/arch/mips/configs/db1500_defconfig
index 508c919..e7a21f1 100644
--- a/arch/mips/configs/db1500_defconfig
+++ b/arch/mips/configs/db1500_defconfig
@@ -1269,7 +1269,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/db1550_defconfig b/arch/mips/configs/db1550_defconfig
index 0c2c70d..1a94129 100644
--- a/arch/mips/configs/db1550_defconfig
+++ b/arch/mips/configs/db1550_defconfig
@@ -1086,7 +1086,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/decstation_defconfig b/arch/mips/configs/decstation_defconfig
index 58c2cd6..06446e6 100644
--- a/arch/mips/configs/decstation_defconfig
+++ b/arch/mips/configs/decstation_defconfig
@@ -785,7 +785,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=y
 
diff --git a/arch/mips/configs/e55_defconfig b/arch/mips/configs/e55_defconfig
index 90d81f5..ed6f9a0 100644
--- a/arch/mips/configs/e55_defconfig
+++ b/arch/mips/configs/e55_defconfig
@@ -514,7 +514,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/emma2rh_defconfig b/arch/mips/configs/emma2rh_defconfig
index f9a003c..668187e 100644
--- a/arch/mips/configs/emma2rh_defconfig
+++ b/arch/mips/configs/emma2rh_defconfig
@@ -1230,7 +1230,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/excite_defconfig b/arch/mips/configs/excite_defconfig
index 15efacc..bdd346c 100644
--- a/arch/mips/configs/excite_defconfig
+++ b/arch/mips/configs/excite_defconfig
@@ -1126,7 +1126,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/fulong_defconfig b/arch/mips/configs/fulong_defconfig
index 5887a17..da16d32 100644
--- a/arch/mips/configs/fulong_defconfig
+++ b/arch/mips/configs/fulong_defconfig
@@ -1535,7 +1535,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/ip22_defconfig b/arch/mips/configs/ip22_defconfig
index 4f5e56c..21072db 100644
--- a/arch/mips/configs/ip22_defconfig
+++ b/arch/mips/configs/ip22_defconfig
@@ -935,7 +935,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/ip27_defconfig b/arch/mips/configs/ip27_defconfig
index f40e437..66b74d3 100644
--- a/arch/mips/configs/ip27_defconfig
+++ b/arch/mips/configs/ip27_defconfig
@@ -848,7 +848,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/ip28_defconfig b/arch/mips/configs/ip28_defconfig
index ec188be..4413f79 100644
--- a/arch/mips/configs/ip28_defconfig
+++ b/arch/mips/configs/ip28_defconfig
@@ -741,7 +741,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/mips/configs/ip32_defconfig b/arch/mips/configs/ip32_defconfig
index 2c5c624..8f2a203 100644
--- a/arch/mips/configs/ip32_defconfig
+++ b/arch/mips/configs/ip32_defconfig
@@ -901,7 +901,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=y
 
diff --git a/arch/mips/configs/jazz_defconfig b/arch/mips/configs/jazz_defconfig
index 5614874..7d802ba 100644
--- a/arch/mips/configs/jazz_defconfig
+++ b/arch/mips/configs/jazz_defconfig
@@ -1216,7 +1216,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/jmr3927_defconfig b/arch/mips/configs/jmr3927_defconfig
index a7cd677..db913f9 100644
--- a/arch/mips/configs/jmr3927_defconfig
+++ b/arch/mips/configs/jmr3927_defconfig
@@ -621,7 +621,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/mips/configs/lasat_defconfig b/arch/mips/configs/lasat_defconfig
index e6aef99..f7ba3dd 100644
--- a/arch/mips/configs/lasat_defconfig
+++ b/arch/mips/configs/lasat_defconfig
@@ -735,7 +735,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=y
 
diff --git a/arch/mips/configs/malta_defconfig b/arch/mips/configs/malta_defconfig
index 3d0da95..fc75b68 100644
--- a/arch/mips/configs/malta_defconfig
+++ b/arch/mips/configs/malta_defconfig
@@ -1297,7 +1297,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/mipssim_defconfig b/arch/mips/configs/mipssim_defconfig
index 4f6bce9..e284593 100644
--- a/arch/mips/configs/mipssim_defconfig
+++ b/arch/mips/configs/mipssim_defconfig
@@ -550,7 +550,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/mips/configs/mpc30x_defconfig b/arch/mips/configs/mpc30x_defconfig
index 27e23fc..c8bb388 100644
--- a/arch/mips/configs/mpc30x_defconfig
+++ b/arch/mips/configs/mpc30x_defconfig
@@ -745,7 +745,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/msp71xx_defconfig b/arch/mips/configs/msp71xx_defconfig
index b12b73f..fe2e592 100644
--- a/arch/mips/configs/msp71xx_defconfig
+++ b/arch/mips/configs/msp71xx_defconfig
@@ -1275,7 +1275,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index fa3aa39..31f3db9 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -2845,7 +2845,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/pb1100_defconfig b/arch/mips/configs/pb1100_defconfig
index 1d0157d..cee3808 100644
--- a/arch/mips/configs/pb1100_defconfig
+++ b/arch/mips/configs/pb1100_defconfig
@@ -962,7 +962,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/pb1500_defconfig b/arch/mips/configs/pb1500_defconfig
index d0491a0..c26c746 100644
--- a/arch/mips/configs/pb1500_defconfig
+++ b/arch/mips/configs/pb1500_defconfig
@@ -1079,7 +1079,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/pb1550_defconfig b/arch/mips/configs/pb1550_defconfig
index 16d78d3..b52c0bb 100644
--- a/arch/mips/configs/pb1550_defconfig
+++ b/arch/mips/configs/pb1550_defconfig
@@ -1072,7 +1072,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/pnx8550-jbs_defconfig b/arch/mips/configs/pnx8550-jbs_defconfig
index 780c7fc..79295e7 100644
--- a/arch/mips/configs/pnx8550-jbs_defconfig
+++ b/arch/mips/configs/pnx8550-jbs_defconfig
@@ -1075,7 +1075,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/pnx8550-stb810_defconfig b/arch/mips/configs/pnx8550-stb810_defconfig
index 267f21e..eee4ebd 100644
--- a/arch/mips/configs/pnx8550-stb810_defconfig
+++ b/arch/mips/configs/pnx8550-stb810_defconfig
@@ -1065,7 +1065,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/rbhma4200_defconfig b/arch/mips/configs/rbhma4200_defconfig
index 470f6f4..22c1f33 100644
--- a/arch/mips/configs/rbhma4200_defconfig
+++ b/arch/mips/configs/rbhma4200_defconfig
@@ -589,7 +589,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/mips/configs/rbhma4500_defconfig b/arch/mips/configs/rbhma4500_defconfig
index 5a39f56..7caf966 100644
--- a/arch/mips/configs/rbhma4500_defconfig
+++ b/arch/mips/configs/rbhma4500_defconfig
@@ -621,7 +621,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/mips/configs/rm200_defconfig b/arch/mips/configs/rm200_defconfig
index 56371b8..f8383db 100644
--- a/arch/mips/configs/rm200_defconfig
+++ b/arch/mips/configs/rm200_defconfig
@@ -1536,7 +1536,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/sb1250-swarm_defconfig b/arch/mips/configs/sb1250-swarm_defconfig
index 117470b..0df1d50 100644
--- a/arch/mips/configs/sb1250-swarm_defconfig
+++ b/arch/mips/configs/sb1250-swarm_defconfig
@@ -854,7 +854,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/sead_defconfig b/arch/mips/configs/sead_defconfig
index 3ee75b1..bed2ca3 100644
--- a/arch/mips/configs/sead_defconfig
+++ b/arch/mips/configs/sead_defconfig
@@ -556,7 +556,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/tb0219_defconfig b/arch/mips/configs/tb0219_defconfig
index af82e1a..7e051e7 100644
--- a/arch/mips/configs/tb0219_defconfig
+++ b/arch/mips/configs/tb0219_defconfig
@@ -812,7 +812,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/tb0226_defconfig b/arch/mips/configs/tb0226_defconfig
index a95385b..46a9a8e 100644
--- a/arch/mips/configs/tb0226_defconfig
+++ b/arch/mips/configs/tb0226_defconfig
@@ -817,7 +817,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/tb0287_defconfig b/arch/mips/configs/tb0287_defconfig
index 40d4a40..aa3d5b5 100644
--- a/arch/mips/configs/tb0287_defconfig
+++ b/arch/mips/configs/tb0287_defconfig
@@ -986,7 +986,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/workpad_defconfig b/arch/mips/configs/workpad_defconfig
index edf90b3..9e496c3 100644
--- a/arch/mips/configs/workpad_defconfig
+++ b/arch/mips/configs/workpad_defconfig
@@ -676,7 +676,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/mips/configs/wrppmc_defconfig b/arch/mips/configs/wrppmc_defconfig
index 2e3c683..1a5aeba 100644
--- a/arch/mips/configs/wrppmc_defconfig
+++ b/arch/mips/configs/wrppmc_defconfig
@@ -809,7 +809,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/mips/configs/yosemite_defconfig b/arch/mips/configs/yosemite_defconfig
index b6178ff..f983731 100644
--- a/arch/mips/configs/yosemite_defconfig
+++ b/arch/mips/configs/yosemite_defconfig
@@ -753,7 +753,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/mn10300/configs/asb2303_defconfig b/arch/mn10300/configs/asb2303_defconfig
index 3aa8906..ca5388c 100644
--- a/arch/mn10300/configs/asb2303_defconfig
+++ b/arch/mn10300/configs/asb2303_defconfig
@@ -489,7 +489,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/parisc/configs/712_defconfig b/arch/parisc/configs/712_defconfig
index 9fc96e7..27367df 100644
--- a/arch/parisc/configs/712_defconfig
+++ b/arch/parisc/configs/712_defconfig
@@ -762,7 +762,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/parisc/configs/a500_defconfig b/arch/parisc/configs/a500_defconfig
index ddacc72..48d1ca9 100644
--- a/arch/parisc/configs/a500_defconfig
+++ b/arch/parisc/configs/a500_defconfig
@@ -900,7 +900,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/parisc/configs/b180_defconfig b/arch/parisc/configs/b180_defconfig
index 1bf22c9..8991255 100644
--- a/arch/parisc/configs/b180_defconfig
+++ b/arch/parisc/configs/b180_defconfig
@@ -920,7 +920,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/parisc/configs/c3000_defconfig b/arch/parisc/configs/c3000_defconfig
index c6def3c..ad04e1f 100644
--- a/arch/parisc/configs/c3000_defconfig
+++ b/arch/parisc/configs/c3000_defconfig
@@ -1127,7 +1127,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/parisc/configs/default_defconfig b/arch/parisc/configs/default_defconfig
index 448a757..7d06e95 100644
--- a/arch/parisc/configs/default_defconfig
+++ b/arch/parisc/configs/default_defconfig
@@ -1205,7 +1205,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/powerpc/configs/40x/ep405_defconfig b/arch/powerpc/configs/40x/ep405_defconfig
index e24240a..c55313b 100644
--- a/arch/powerpc/configs/40x/ep405_defconfig
+++ b/arch/powerpc/configs/40x/ep405_defconfig
@@ -801,7 +801,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/40x/kilauea_defconfig b/arch/powerpc/configs/40x/kilauea_defconfig
index 2f47539..1fecfc5 100644
--- a/arch/powerpc/configs/40x/kilauea_defconfig
+++ b/arch/powerpc/configs/40x/kilauea_defconfig
@@ -672,7 +672,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/40x/makalu_defconfig b/arch/powerpc/configs/40x/makalu_defconfig
index 9ef4d8a..865ee63 100644
--- a/arch/powerpc/configs/40x/makalu_defconfig
+++ b/arch/powerpc/configs/40x/makalu_defconfig
@@ -672,7 +672,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/40x/walnut_defconfig b/arch/powerpc/configs/40x/walnut_defconfig
index 3b2689e..a77b15f 100644
--- a/arch/powerpc/configs/40x/walnut_defconfig
+++ b/arch/powerpc/configs/40x/walnut_defconfig
@@ -720,7 +720,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/bamboo_defconfig b/arch/powerpc/configs/44x/bamboo_defconfig
index c44db55..5ec97eb 100644
--- a/arch/powerpc/configs/44x/bamboo_defconfig
+++ b/arch/powerpc/configs/44x/bamboo_defconfig
@@ -647,7 +647,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/canyonlands_defconfig b/arch/powerpc/configs/44x/canyonlands_defconfig
index a3b763c..afab470 100644
--- a/arch/powerpc/configs/44x/canyonlands_defconfig
+++ b/arch/powerpc/configs/44x/canyonlands_defconfig
@@ -600,7 +600,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/ebony_defconfig b/arch/powerpc/configs/44x/ebony_defconfig
index 07c8d4c..5c99f44 100644
--- a/arch/powerpc/configs/44x/ebony_defconfig
+++ b/arch/powerpc/configs/44x/ebony_defconfig
@@ -721,7 +721,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/katmai_defconfig b/arch/powerpc/configs/44x/katmai_defconfig
index c8804ec..1e4967e 100644
--- a/arch/powerpc/configs/44x/katmai_defconfig
+++ b/arch/powerpc/configs/44x/katmai_defconfig
@@ -628,7 +628,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/rainier_defconfig b/arch/powerpc/configs/44x/rainier_defconfig
index dec18ca..3705fb2 100644
--- a/arch/powerpc/configs/44x/rainier_defconfig
+++ b/arch/powerpc/configs/44x/rainier_defconfig
@@ -706,7 +706,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/sequoia_defconfig b/arch/powerpc/configs/44x/sequoia_defconfig
index dd5d630..7831d8e 100644
--- a/arch/powerpc/configs/44x/sequoia_defconfig
+++ b/arch/powerpc/configs/44x/sequoia_defconfig
@@ -723,7 +723,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/taishan_defconfig b/arch/powerpc/configs/44x/taishan_defconfig
index 087aedc..19b4d43 100644
--- a/arch/powerpc/configs/44x/taishan_defconfig
+++ b/arch/powerpc/configs/44x/taishan_defconfig
@@ -647,7 +647,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/44x/warp_defconfig b/arch/powerpc/configs/44x/warp_defconfig
index 2313c3e..d6e4054 100644
--- a/arch/powerpc/configs/44x/warp_defconfig
+++ b/arch/powerpc/configs/44x/warp_defconfig
@@ -897,7 +897,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/52xx/cm5200_defconfig b/arch/powerpc/configs/52xx/cm5200_defconfig
index c10f739..e8b87a7 100644
--- a/arch/powerpc/configs/52xx/cm5200_defconfig
+++ b/arch/powerpc/configs/52xx/cm5200_defconfig
@@ -833,7 +833,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/52xx/lite5200b_defconfig b/arch/powerpc/configs/52xx/lite5200b_defconfig
index 1a8a250..330b587 100644
--- a/arch/powerpc/configs/52xx/lite5200b_defconfig
+++ b/arch/powerpc/configs/52xx/lite5200b_defconfig
@@ -848,7 +848,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/52xx/motionpro_defconfig b/arch/powerpc/configs/52xx/motionpro_defconfig
index 8c7ba7c..ea5606d 100644
--- a/arch/powerpc/configs/52xx/motionpro_defconfig
+++ b/arch/powerpc/configs/52xx/motionpro_defconfig
@@ -841,7 +841,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/52xx/pcm030_defconfig b/arch/powerpc/configs/52xx/pcm030_defconfig
index 9c0caa4..8221aa4 100644
--- a/arch/powerpc/configs/52xx/pcm030_defconfig
+++ b/arch/powerpc/configs/52xx/pcm030_defconfig
@@ -967,7 +967,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/52xx/tqm5200_defconfig b/arch/powerpc/configs/52xx/tqm5200_defconfig
index 7672bfb..db74be5 100644
--- a/arch/powerpc/configs/52xx/tqm5200_defconfig
+++ b/arch/powerpc/configs/52xx/tqm5200_defconfig
@@ -946,7 +946,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig b/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig
index 7d18440..00ce61a 100644
--- a/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc8313_rdb_defconfig
@@ -1200,7 +1200,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig b/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig
index 1f57456..8f81d2b 100644
--- a/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc8315_rdb_defconfig
@@ -1257,7 +1257,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc832x_mds_defconfig b/arch/powerpc/configs/83xx/mpc832x_mds_defconfig
index 50cceda..92eb8d6 100644
--- a/arch/powerpc/configs/83xx/mpc832x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc832x_mds_defconfig
@@ -926,7 +926,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
index ac91302..8b06cbf 100644
--- a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
@@ -1034,7 +1034,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc834x_itx_defconfig b/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
index e1de399..59d8e50 100644
--- a/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
+++ b/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
@@ -1099,7 +1099,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig b/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig
index b4e39cf..fe222e3 100644
--- a/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig
+++ b/arch/powerpc/configs/83xx/mpc834x_itxgp_defconfig
@@ -1026,7 +1026,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc834x_mds_defconfig b/arch/powerpc/configs/83xx/mpc834x_mds_defconfig
index b4e82c0..b914667 100644
--- a/arch/powerpc/configs/83xx/mpc834x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc834x_mds_defconfig
@@ -869,7 +869,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc836x_mds_defconfig b/arch/powerpc/configs/83xx/mpc836x_mds_defconfig
index d50a96e..3014531 100644
--- a/arch/powerpc/configs/83xx/mpc836x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc836x_mds_defconfig
@@ -924,7 +924,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc837x_mds_defconfig b/arch/powerpc/configs/83xx/mpc837x_mds_defconfig
index f377cde..c39842f 100644
--- a/arch/powerpc/configs/83xx/mpc837x_mds_defconfig
+++ b/arch/powerpc/configs/83xx/mpc837x_mds_defconfig
@@ -746,7 +746,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig b/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig
index a633176..a68c0a5 100644
--- a/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc837x_rdb_defconfig
@@ -773,7 +773,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/83xx/sbc834x_defconfig b/arch/powerpc/configs/83xx/sbc834x_defconfig
index 1f15182..94724a5 100644
--- a/arch/powerpc/configs/83xx/sbc834x_defconfig
+++ b/arch/powerpc/configs/83xx/sbc834x_defconfig
@@ -691,7 +691,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/ksi8560_defconfig b/arch/powerpc/configs/85xx/ksi8560_defconfig
index 2d0debc..556eb5e 100644
--- a/arch/powerpc/configs/85xx/ksi8560_defconfig
+++ b/arch/powerpc/configs/85xx/ksi8560_defconfig
@@ -727,7 +727,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/mpc8540_ads_defconfig b/arch/powerpc/configs/85xx/mpc8540_ads_defconfig
index b998539..2b25df7 100644
--- a/arch/powerpc/configs/85xx/mpc8540_ads_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8540_ads_defconfig
@@ -627,7 +627,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/mpc8544_ds_defconfig b/arch/powerpc/configs/85xx/mpc8544_ds_defconfig
index a9f113b..97b2748 100644
--- a/arch/powerpc/configs/85xx/mpc8544_ds_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8544_ds_defconfig
@@ -1333,7 +1333,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/mpc8560_ads_defconfig b/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
index 851ac91..6df40c4 100644
--- a/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
@@ -713,7 +713,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/mpc8568mds_defconfig b/arch/powerpc/configs/85xx/mpc8568mds_defconfig
index 2b866b3..93cf58f 100644
--- a/arch/powerpc/configs/85xx/mpc8568mds_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8568mds_defconfig
@@ -927,7 +927,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/mpc8572_ds_defconfig b/arch/powerpc/configs/85xx/mpc8572_ds_defconfig
index 53aa6f3..9f8b793 100644
--- a/arch/powerpc/configs/85xx/mpc8572_ds_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8572_ds_defconfig
@@ -1319,7 +1319,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig b/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
index a469fe9..eaf9824 100644
--- a/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
+++ b/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
@@ -765,7 +765,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/sbc8548_defconfig b/arch/powerpc/configs/85xx/sbc8548_defconfig
index 67f6797..a513c09 100644
--- a/arch/powerpc/configs/85xx/sbc8548_defconfig
+++ b/arch/powerpc/configs/85xx/sbc8548_defconfig
@@ -680,7 +680,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/sbc8560_defconfig b/arch/powerpc/configs/85xx/sbc8560_defconfig
index fef6055..e8baf84 100644
--- a/arch/powerpc/configs/85xx/sbc8560_defconfig
+++ b/arch/powerpc/configs/85xx/sbc8560_defconfig
@@ -651,7 +651,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/stx_gp3_defconfig b/arch/powerpc/configs/85xx/stx_gp3_defconfig
index 1d303c4..de777d7 100644
--- a/arch/powerpc/configs/85xx/stx_gp3_defconfig
+++ b/arch/powerpc/configs/85xx/stx_gp3_defconfig
@@ -1047,7 +1047,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/tqm8540_defconfig b/arch/powerpc/configs/85xx/tqm8540_defconfig
index d39ee3b..ef35f84 100644
--- a/arch/powerpc/configs/85xx/tqm8540_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8540_defconfig
@@ -938,7 +938,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/tqm8541_defconfig b/arch/powerpc/configs/85xx/tqm8541_defconfig
index cbf6ad2..c9ea801 100644
--- a/arch/powerpc/configs/85xx/tqm8541_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8541_defconfig
@@ -948,7 +948,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/tqm8555_defconfig b/arch/powerpc/configs/85xx/tqm8555_defconfig
index bbff962..a19582a 100644
--- a/arch/powerpc/configs/85xx/tqm8555_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8555_defconfig
@@ -948,7 +948,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/85xx/tqm8560_defconfig b/arch/powerpc/configs/85xx/tqm8560_defconfig
index 63c5ec8..162538e 100644
--- a/arch/powerpc/configs/85xx/tqm8560_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8560_defconfig
@@ -948,7 +948,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/adder875_defconfig b/arch/powerpc/configs/adder875_defconfig
index a3cc94a..5bca27b 100644
--- a/arch/powerpc/configs/adder875_defconfig
+++ b/arch/powerpc/configs/adder875_defconfig
@@ -681,7 +681,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/cell_defconfig b/arch/powerpc/configs/cell_defconfig
index c420e47..5ceb42b 100644
--- a/arch/powerpc/configs/cell_defconfig
+++ b/arch/powerpc/configs/cell_defconfig
@@ -1303,8 +1303,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/celleb_defconfig b/arch/powerpc/configs/celleb_defconfig
index 9ba3c6f..061189b 100644
--- a/arch/powerpc/configs/celleb_defconfig
+++ b/arch/powerpc/configs/celleb_defconfig
@@ -1099,8 +1099,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/chrp32_defconfig b/arch/powerpc/configs/chrp32_defconfig
index 05360d4..bd8580b 100644
--- a/arch/powerpc/configs/chrp32_defconfig
+++ b/arch/powerpc/configs/chrp32_defconfig
@@ -1210,7 +1210,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/ep8248e_defconfig b/arch/powerpc/configs/ep8248e_defconfig
index 2b1504e..825164e 100644
--- a/arch/powerpc/configs/ep8248e_defconfig
+++ b/arch/powerpc/configs/ep8248e_defconfig
@@ -655,7 +655,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/ep88xc_defconfig b/arch/powerpc/configs/ep88xc_defconfig
index 125b476..61fafff 100644
--- a/arch/powerpc/configs/ep88xc_defconfig
+++ b/arch/powerpc/configs/ep88xc_defconfig
@@ -638,7 +638,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/g5_defconfig b/arch/powerpc/configs/g5_defconfig
index db34909..e250010 100644
--- a/arch/powerpc/configs/g5_defconfig
+++ b/arch/powerpc/configs/g5_defconfig
@@ -1424,8 +1424,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/holly_defconfig b/arch/powerpc/configs/holly_defconfig
index a211a79..554376a 100644
--- a/arch/powerpc/configs/holly_defconfig
+++ b/arch/powerpc/configs/holly_defconfig
@@ -817,7 +817,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/iseries_defconfig b/arch/powerpc/configs/iseries_defconfig
index 63f0bdb..75b5012 100644
--- a/arch/powerpc/configs/iseries_defconfig
+++ b/arch/powerpc/configs/iseries_defconfig
@@ -950,8 +950,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/powerpc/configs/linkstation_defconfig b/arch/powerpc/configs/linkstation_defconfig
index 22a943a..95a8a92 100644
--- a/arch/powerpc/configs/linkstation_defconfig
+++ b/arch/powerpc/configs/linkstation_defconfig
@@ -1361,7 +1361,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/maple_defconfig b/arch/powerpc/configs/maple_defconfig
index 7a166a3..f3b87f6 100644
--- a/arch/powerpc/configs/maple_defconfig
+++ b/arch/powerpc/configs/maple_defconfig
@@ -1072,8 +1072,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc5200_defconfig b/arch/powerpc/configs/mpc5200_defconfig
index 740c9f2..710c084 100644
--- a/arch/powerpc/configs/mpc5200_defconfig
+++ b/arch/powerpc/configs/mpc5200_defconfig
@@ -1075,7 +1075,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc7448_hpc2_defconfig b/arch/powerpc/configs/mpc7448_hpc2_defconfig
index a3d52e3..be2091d 100644
--- a/arch/powerpc/configs/mpc7448_hpc2_defconfig
+++ b/arch/powerpc/configs/mpc7448_hpc2_defconfig
@@ -846,7 +846,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc8272_ads_defconfig b/arch/powerpc/configs/mpc8272_ads_defconfig
index 0264c57..b6f3e08 100644
--- a/arch/powerpc/configs/mpc8272_ads_defconfig
+++ b/arch/powerpc/configs/mpc8272_ads_defconfig
@@ -778,7 +778,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc83xx_defconfig b/arch/powerpc/configs/mpc83xx_defconfig
index 9e0dd82..f2de6da 100644
--- a/arch/powerpc/configs/mpc83xx_defconfig
+++ b/arch/powerpc/configs/mpc83xx_defconfig
@@ -935,7 +935,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc85xx_defconfig b/arch/powerpc/configs/mpc85xx_defconfig
index 2075722..0c6ce34 100644
--- a/arch/powerpc/configs/mpc85xx_defconfig
+++ b/arch/powerpc/configs/mpc85xx_defconfig
@@ -1327,7 +1327,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc8610_hpcd_defconfig b/arch/powerpc/configs/mpc8610_hpcd_defconfig
index 7e5b9ce..0dd3ed1 100644
--- a/arch/powerpc/configs/mpc8610_hpcd_defconfig
+++ b/arch/powerpc/configs/mpc8610_hpcd_defconfig
@@ -1121,7 +1121,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc8641_hpcn_defconfig b/arch/powerpc/configs/mpc8641_hpcn_defconfig
index d01dcdb..0721ee5 100644
--- a/arch/powerpc/configs/mpc8641_hpcn_defconfig
+++ b/arch/powerpc/configs/mpc8641_hpcn_defconfig
@@ -1313,7 +1313,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc866_ads_defconfig b/arch/powerpc/configs/mpc866_ads_defconfig
index 2d831db..d60d91c 100644
--- a/arch/powerpc/configs/mpc866_ads_defconfig
+++ b/arch/powerpc/configs/mpc866_ads_defconfig
@@ -652,7 +652,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/mpc885_ads_defconfig b/arch/powerpc/configs/mpc885_ads_defconfig
index 82151b9..4b5524f 100644
--- a/arch/powerpc/configs/mpc885_ads_defconfig
+++ b/arch/powerpc/configs/mpc885_ads_defconfig
@@ -649,7 +649,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/pasemi_defconfig b/arch/powerpc/configs/pasemi_defconfig
index 199e5f5..7a1d417 100644
--- a/arch/powerpc/configs/pasemi_defconfig
+++ b/arch/powerpc/configs/pasemi_defconfig
@@ -1552,8 +1552,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_CONFIGFS_FS=y
 
 #
diff --git a/arch/powerpc/configs/pmac32_defconfig b/arch/powerpc/configs/pmac32_defconfig
index 3688e4b..277ee60 100644
--- a/arch/powerpc/configs/pmac32_defconfig
+++ b/arch/powerpc/configs/pmac32_defconfig
@@ -1773,7 +1773,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/ppc40x_defconfig b/arch/powerpc/configs/ppc40x_defconfig
index 9d0140e..dfea710 100644
--- a/arch/powerpc/configs/ppc40x_defconfig
+++ b/arch/powerpc/configs/ppc40x_defconfig
@@ -728,7 +728,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/ppc44x_defconfig b/arch/powerpc/configs/ppc44x_defconfig
index 12f9b5a..470416f 100644
--- a/arch/powerpc/configs/ppc44x_defconfig
+++ b/arch/powerpc/configs/ppc44x_defconfig
@@ -733,7 +733,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index 40f84fa..461be0b 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -1692,8 +1692,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/pq2fads_defconfig b/arch/powerpc/configs/pq2fads_defconfig
index 1383eb6..edc655b 100644
--- a/arch/powerpc/configs/pq2fads_defconfig
+++ b/arch/powerpc/configs/pq2fads_defconfig
@@ -868,7 +868,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/prpmc2800_defconfig b/arch/powerpc/configs/prpmc2800_defconfig
index f912168..d54f2f0 100644
--- a/arch/powerpc/configs/prpmc2800_defconfig
+++ b/arch/powerpc/configs/prpmc2800_defconfig
@@ -1231,7 +1231,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/ps3_defconfig b/arch/powerpc/configs/ps3_defconfig
index 71d79e4..89d2f7b 100644
--- a/arch/powerpc/configs/ps3_defconfig
+++ b/arch/powerpc/configs/ps3_defconfig
@@ -959,8 +959,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index adaa05f..65df8c0 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -1353,8 +1353,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/powerpc/configs/sbc8641d_defconfig b/arch/powerpc/configs/sbc8641d_defconfig
index 3180125..fc7638a 100644
--- a/arch/powerpc/configs/sbc8641d_defconfig
+++ b/arch/powerpc/configs/sbc8641d_defconfig
@@ -1118,7 +1118,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/powerpc/configs/storcenter_defconfig b/arch/powerpc/configs/storcenter_defconfig
index fdbfd39..1b80ce8 100644
--- a/arch/powerpc/configs/storcenter_defconfig
+++ b/arch/powerpc/configs/storcenter_defconfig
@@ -1037,7 +1037,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/ppc/configs/bamboo_defconfig b/arch/ppc/configs/bamboo_defconfig
index 41fd393..5e44373 100644
--- a/arch/ppc/configs/bamboo_defconfig
+++ b/arch/ppc/configs/bamboo_defconfig
@@ -845,7 +845,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/bubinga_defconfig b/arch/ppc/configs/bubinga_defconfig
index ebec801..d2417c8 100644
--- a/arch/ppc/configs/bubinga_defconfig
+++ b/arch/ppc/configs/bubinga_defconfig
@@ -503,7 +503,7 @@ CONFIG_PROC_KCORE=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/chestnut_defconfig b/arch/ppc/configs/chestnut_defconfig
index e219aad..0d85c91 100644
--- a/arch/ppc/configs/chestnut_defconfig
+++ b/arch/ppc/configs/chestnut_defconfig
@@ -697,7 +697,7 @@ CONFIG_DEVFS_MOUNT=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/cpci405_defconfig b/arch/ppc/configs/cpci405_defconfig
index a336ffa..0c6a7b7 100644
--- a/arch/ppc/configs/cpci405_defconfig
+++ b/arch/ppc/configs/cpci405_defconfig
@@ -514,7 +514,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 # CONFIG_DEVFS_FS is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/cpci690_defconfig b/arch/ppc/configs/cpci690_defconfig
index ff3f7e0..fe9ae56 100644
--- a/arch/ppc/configs/cpci690_defconfig
+++ b/arch/ppc/configs/cpci690_defconfig
@@ -679,7 +679,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 # CONFIG_RELAYFS_FS is not set
diff --git a/arch/ppc/configs/ebony_defconfig b/arch/ppc/configs/ebony_defconfig
index c8deca3..23cba62 100644
--- a/arch/ppc/configs/ebony_defconfig
+++ b/arch/ppc/configs/ebony_defconfig
@@ -498,7 +498,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/ep405_defconfig b/arch/ppc/configs/ep405_defconfig
index 880b5f8..1a5ca87 100644
--- a/arch/ppc/configs/ep405_defconfig
+++ b/arch/ppc/configs/ep405_defconfig
@@ -494,7 +494,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/ev64260_defconfig b/arch/ppc/configs/ev64260_defconfig
index 587e9a3..4a1b120 100644
--- a/arch/ppc/configs/ev64260_defconfig
+++ b/arch/ppc/configs/ev64260_defconfig
@@ -676,7 +676,7 @@ CONFIG_DEVFS_FS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/ev64360_defconfig b/arch/ppc/configs/ev64360_defconfig
index f297c4b..f4772bd 100644
--- a/arch/ppc/configs/ev64360_defconfig
+++ b/arch/ppc/configs/ev64360_defconfig
@@ -715,7 +715,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 
diff --git a/arch/ppc/configs/hdpu_defconfig b/arch/ppc/configs/hdpu_defconfig
index 956a178..9ca3b5a 100644
--- a/arch/ppc/configs/hdpu_defconfig
+++ b/arch/ppc/configs/hdpu_defconfig
@@ -724,7 +724,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/katana_defconfig b/arch/ppc/configs/katana_defconfig
index 7311fe6..11f4b6a 100644
--- a/arch/ppc/configs/katana_defconfig
+++ b/arch/ppc/configs/katana_defconfig
@@ -852,7 +852,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 # CONFIG_RELAYFS_FS is not set
diff --git a/arch/ppc/configs/lite5200_defconfig b/arch/ppc/configs/lite5200_defconfig
index 7e7a943..e3044ad 100644
--- a/arch/ppc/configs/lite5200_defconfig
+++ b/arch/ppc/configs/lite5200_defconfig
@@ -336,7 +336,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 #
 # Miscellaneous filesystems
diff --git a/arch/ppc/configs/lopec_defconfig b/arch/ppc/configs/lopec_defconfig
index 85ea06b..781d2ce 100644
--- a/arch/ppc/configs/lopec_defconfig
+++ b/arch/ppc/configs/lopec_defconfig
@@ -740,7 +740,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/luan_defconfig b/arch/ppc/configs/luan_defconfig
index 71d7bf1..5dff932 100644
--- a/arch/ppc/configs/luan_defconfig
+++ b/arch/ppc/configs/luan_defconfig
@@ -571,7 +571,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/ml300_defconfig b/arch/ppc/configs/ml300_defconfig
index d66cacd..8ab5477 100644
--- a/arch/ppc/configs/ml300_defconfig
+++ b/arch/ppc/configs/ml300_defconfig
@@ -602,7 +602,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 # CONFIG_CONFIGFS_FS is not set
diff --git a/arch/ppc/configs/ml403_defconfig b/arch/ppc/configs/ml403_defconfig
index 71bcfa7..2703d4d 100644
--- a/arch/ppc/configs/ml403_defconfig
+++ b/arch/ppc/configs/ml403_defconfig
@@ -603,7 +603,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_RELAYFS_FS is not set
 # CONFIG_CONFIGFS_FS is not set
diff --git a/arch/ppc/configs/mvme5100_defconfig b/arch/ppc/configs/mvme5100_defconfig
index 46776b9..e5b41d7 100644
--- a/arch/ppc/configs/mvme5100_defconfig
+++ b/arch/ppc/configs/mvme5100_defconfig
@@ -666,7 +666,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/ocotea_defconfig b/arch/ppc/configs/ocotea_defconfig
index 9dcf575..3a6b0dd 100644
--- a/arch/ppc/configs/ocotea_defconfig
+++ b/arch/ppc/configs/ocotea_defconfig
@@ -512,7 +512,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/pplus_defconfig b/arch/ppc/configs/pplus_defconfig
index 5e459bc..7839d23 100644
--- a/arch/ppc/configs/pplus_defconfig
+++ b/arch/ppc/configs/pplus_defconfig
@@ -650,7 +650,7 @@ CONFIG_PROC_KCORE=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/prep_defconfig b/arch/ppc/configs/prep_defconfig
index b7cee2d..efcff67 100644
--- a/arch/ppc/configs/prep_defconfig
+++ b/arch/ppc/configs/prep_defconfig
@@ -1503,7 +1503,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/ppc/configs/prpmc750_defconfig b/arch/ppc/configs/prpmc750_defconfig
index 82d52f6..495d5c6 100644
--- a/arch/ppc/configs/prpmc750_defconfig
+++ b/arch/ppc/configs/prpmc750_defconfig
@@ -521,7 +521,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/prpmc800_defconfig b/arch/ppc/configs/prpmc800_defconfig
index 613c266..af8f0eb 100644
--- a/arch/ppc/configs/prpmc800_defconfig
+++ b/arch/ppc/configs/prpmc800_defconfig
@@ -583,7 +583,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/radstone_ppc7d_defconfig b/arch/ppc/configs/radstone_ppc7d_defconfig
index 9f64532..0e504b9 100644
--- a/arch/ppc/configs/radstone_ppc7d_defconfig
+++ b/arch/ppc/configs/radstone_ppc7d_defconfig
@@ -892,7 +892,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/redwood5_defconfig b/arch/ppc/configs/redwood5_defconfig
index 4c5486d..2d5e5d6 100644
--- a/arch/ppc/configs/redwood5_defconfig
+++ b/arch/ppc/configs/redwood5_defconfig
@@ -479,7 +479,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_KCORE=y
 # CONFIG_DEVFS_FS is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/redwood6_defconfig b/arch/ppc/configs/redwood6_defconfig
index 5752845..636df84 100644
--- a/arch/ppc/configs/redwood6_defconfig
+++ b/arch/ppc/configs/redwood6_defconfig
@@ -457,7 +457,7 @@ CONFIG_PROC_KCORE=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/rpx8260_defconfig b/arch/ppc/configs/rpx8260_defconfig
index a9c4544..c266484 100644
--- a/arch/ppc/configs/rpx8260_defconfig
+++ b/arch/ppc/configs/rpx8260_defconfig
@@ -454,7 +454,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/rpxcllf_defconfig b/arch/ppc/configs/rpxcllf_defconfig
index cf932f1..6a82240 100644
--- a/arch/ppc/configs/rpxcllf_defconfig
+++ b/arch/ppc/configs/rpxcllf_defconfig
@@ -470,8 +470,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/rpxlite_defconfig b/arch/ppc/configs/rpxlite_defconfig
index 828dd6e..632ec0f 100644
--- a/arch/ppc/configs/rpxlite_defconfig
+++ b/arch/ppc/configs/rpxlite_defconfig
@@ -470,8 +470,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/sandpoint_defconfig b/arch/ppc/configs/sandpoint_defconfig
index 9525e34..318e511 100644
--- a/arch/ppc/configs/sandpoint_defconfig
+++ b/arch/ppc/configs/sandpoint_defconfig
@@ -661,7 +661,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/spruce_defconfig b/arch/ppc/configs/spruce_defconfig
index 430dd9c..c9aa386 100644
--- a/arch/ppc/configs/spruce_defconfig
+++ b/arch/ppc/configs/spruce_defconfig
@@ -504,7 +504,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/sycamore_defconfig b/arch/ppc/configs/sycamore_defconfig
index 6996cca..df5e547 100644
--- a/arch/ppc/configs/sycamore_defconfig
+++ b/arch/ppc/configs/sycamore_defconfig
@@ -574,7 +574,7 @@ CONFIG_PROC_KCORE=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/ppc/configs/taishan_defconfig b/arch/ppc/configs/taishan_defconfig
index 1ca0204..470507a 100644
--- a/arch/ppc/configs/taishan_defconfig
+++ b/arch/ppc/configs/taishan_defconfig
@@ -950,7 +950,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/ppc/configs/walnut_defconfig b/arch/ppc/configs/walnut_defconfig
index bf9721a..4e5c47e 100644
--- a/arch/ppc/configs/walnut_defconfig
+++ b/arch/ppc/configs/walnut_defconfig
@@ -489,7 +489,7 @@ CONFIG_SYSFS=y
 # CONFIG_DEVFS_FS is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/s390/defconfig b/arch/s390/defconfig
index c5cdb97..404488d 100644
--- a/arch/s390/defconfig
+++ b/arch/s390/defconfig
@@ -676,8 +676,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/sh/configs/cayman_defconfig b/arch/sh/configs/cayman_defconfig
index a05b278..791ed45 100644
--- a/arch/sh/configs/cayman_defconfig
+++ b/arch/sh/configs/cayman_defconfig
@@ -1023,8 +1023,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/dreamcast_defconfig b/arch/sh/configs/dreamcast_defconfig
index 5772878..4218dc9 100644
--- a/arch/sh/configs/dreamcast_defconfig
+++ b/arch/sh/configs/dreamcast_defconfig
@@ -769,8 +769,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/hp6xx_defconfig b/arch/sh/configs/hp6xx_defconfig
index 756d38d..9ab5840 100644
--- a/arch/sh/configs/hp6xx_defconfig
+++ b/arch/sh/configs/hp6xx_defconfig
@@ -641,8 +641,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/landisk_defconfig b/arch/sh/configs/landisk_defconfig
index f52db12..41f173d 100644
--- a/arch/sh/configs/landisk_defconfig
+++ b/arch/sh/configs/landisk_defconfig
@@ -1327,8 +1327,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/lboxre2_defconfig b/arch/sh/configs/lboxre2_defconfig
index 9fa66d9..4260cbd 100644
--- a/arch/sh/configs/lboxre2_defconfig
+++ b/arch/sh/configs/lboxre2_defconfig
@@ -1135,8 +1135,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/magicpanelr2_defconfig b/arch/sh/configs/magicpanelr2_defconfig
index f8398a5..98811fa 100644
--- a/arch/sh/configs/magicpanelr2_defconfig
+++ b/arch/sh/configs/magicpanelr2_defconfig
@@ -722,8 +722,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/microdev_defconfig b/arch/sh/configs/microdev_defconfig
index e89d951..6dfac1c 100644
--- a/arch/sh/configs/microdev_defconfig
+++ b/arch/sh/configs/microdev_defconfig
@@ -745,8 +745,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/migor_defconfig b/arch/sh/configs/migor_defconfig
index 287408b..c8a949c 100644
--- a/arch/sh/configs/migor_defconfig
+++ b/arch/sh/configs/migor_defconfig
@@ -852,8 +852,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/r7780mp_defconfig b/arch/sh/configs/r7780mp_defconfig
index 1a07261..0a14cab 100644
--- a/arch/sh/configs/r7780mp_defconfig
+++ b/arch/sh/configs/r7780mp_defconfig
@@ -940,8 +940,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/sh/configs/r7785rp_defconfig b/arch/sh/configs/r7785rp_defconfig
index 0dc1ce7..3895035 100644
--- a/arch/sh/configs/r7785rp_defconfig
+++ b/arch/sh/configs/r7785rp_defconfig
@@ -935,8 +935,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_CONFIGFS_FS=m
 
 #
diff --git a/arch/sh/configs/rsk7203_defconfig b/arch/sh/configs/rsk7203_defconfig
index a0ebd43..4406188 100644
--- a/arch/sh/configs/rsk7203_defconfig
+++ b/arch/sh/configs/rsk7203_defconfig
@@ -717,7 +717,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/rts7751r2d1_defconfig b/arch/sh/configs/rts7751r2d1_defconfig
index 3a915fd..c6cdb15 100644
--- a/arch/sh/configs/rts7751r2d1_defconfig
+++ b/arch/sh/configs/rts7751r2d1_defconfig
@@ -1192,8 +1192,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/rts7751r2dplus_defconfig b/arch/sh/configs/rts7751r2dplus_defconfig
index 0a6d3b9..80a537b 100644
--- a/arch/sh/configs/rts7751r2dplus_defconfig
+++ b/arch/sh/configs/rts7751r2dplus_defconfig
@@ -1192,8 +1192,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/sdk7780_defconfig b/arch/sh/configs/sdk7780_defconfig
index bb9bcd6..d77001e 100644
--- a/arch/sh/configs/sdk7780_defconfig
+++ b/arch/sh/configs/sdk7780_defconfig
@@ -1187,8 +1187,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/se7206_defconfig b/arch/sh/configs/se7206_defconfig
index 6b34baa..6966f78 100644
--- a/arch/sh/configs/se7206_defconfig
+++ b/arch/sh/configs/se7206_defconfig
@@ -711,7 +711,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_CONFIGFS_FS=y
 
 #
diff --git a/arch/sh/configs/se7343_defconfig b/arch/sh/configs/se7343_defconfig
index 84c0075..5ba1de0 100644
--- a/arch/sh/configs/se7343_defconfig
+++ b/arch/sh/configs/se7343_defconfig
@@ -907,8 +907,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/se7619_defconfig b/arch/sh/configs/se7619_defconfig
index 3a3c3c1..80a10c2 100644
--- a/arch/sh/configs/se7619_defconfig
+++ b/arch/sh/configs/se7619_defconfig
@@ -591,7 +591,7 @@ CONFIG_PROC_FS=y
 CONFIG_PROC_SYSCTL=y
 # CONFIG_SYSFS is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/sh/configs/se7705_defconfig b/arch/sh/configs/se7705_defconfig
index 84717d8..0938e99 100644
--- a/arch/sh/configs/se7705_defconfig
+++ b/arch/sh/configs/se7705_defconfig
@@ -874,8 +874,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 # CONFIG_SYSFS is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/sh/configs/se7712_defconfig b/arch/sh/configs/se7712_defconfig
index 240a1ce..d1d8bdb 100644
--- a/arch/sh/configs/se7712_defconfig
+++ b/arch/sh/configs/se7712_defconfig
@@ -918,8 +918,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/se7721_defconfig b/arch/sh/configs/se7721_defconfig
index f3d4ca0..be7706f 100644
--- a/arch/sh/configs/se7721_defconfig
+++ b/arch/sh/configs/se7721_defconfig
@@ -882,8 +882,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/se7722_defconfig b/arch/sh/configs/se7722_defconfig
index 8e6a6ba..7ea07d5 100644
--- a/arch/sh/configs/se7722_defconfig
+++ b/arch/sh/configs/se7722_defconfig
@@ -786,8 +786,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/se7750_defconfig b/arch/sh/configs/se7750_defconfig
index c60b6fd..d8a4e9a 100644
--- a/arch/sh/configs/se7750_defconfig
+++ b/arch/sh/configs/se7750_defconfig
@@ -891,8 +891,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/se7751_defconfig b/arch/sh/configs/se7751_defconfig
index a909559..cea278f 100644
--- a/arch/sh/configs/se7751_defconfig
+++ b/arch/sh/configs/se7751_defconfig
@@ -809,8 +809,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/se7780_defconfig b/arch/sh/configs/se7780_defconfig
index 30f5ee4..9715181 100644
--- a/arch/sh/configs/se7780_defconfig
+++ b/arch/sh/configs/se7780_defconfig
@@ -1013,8 +1013,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/sh03_defconfig b/arch/sh/configs/sh03_defconfig
index 9fd5ea7..0ca45cd 100644
--- a/arch/sh/configs/sh03_defconfig
+++ b/arch/sh/configs/sh03_defconfig
@@ -951,8 +951,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/sh7710voipgw_defconfig b/arch/sh/configs/sh7710voipgw_defconfig
index 37e49a5..88035e7 100644
--- a/arch/sh/configs/sh7710voipgw_defconfig
+++ b/arch/sh/configs/sh7710voipgw_defconfig
@@ -723,8 +723,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sh/configs/shmin_defconfig b/arch/sh/configs/shmin_defconfig
index 8800fef..6c3b22a 100644
--- a/arch/sh/configs/shmin_defconfig
+++ b/arch/sh/configs/shmin_defconfig
@@ -766,8 +766,7 @@ CONFIG_PROC_SYSCTL=y
 # CONFIG_SYSFS is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/sh/configs/shx3_defconfig b/arch/sh/configs/shx3_defconfig
index a794c08..2756953 100644
--- a/arch/sh/configs/shx3_defconfig
+++ b/arch/sh/configs/shx3_defconfig
@@ -676,8 +676,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/snapgear_defconfig b/arch/sh/configs/snapgear_defconfig
index e4e5d21..ea5167f 100644
--- a/arch/sh/configs/snapgear_defconfig
+++ b/arch/sh/configs/snapgear_defconfig
@@ -706,8 +706,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/systemh_defconfig b/arch/sh/configs/systemh_defconfig
index af921b5..0b6dbf4 100644
--- a/arch/sh/configs/systemh_defconfig
+++ b/arch/sh/configs/systemh_defconfig
@@ -568,8 +568,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/sh/configs/titan_defconfig b/arch/sh/configs/titan_defconfig
index 0686ed6..b5c3316 100644
--- a/arch/sh/configs/titan_defconfig
+++ b/arch/sh/configs/titan_defconfig
@@ -1470,8 +1470,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 CONFIG_CONFIGFS_FS=m
 
diff --git a/arch/sparc/defconfig b/arch/sparc/defconfig
index 2e3a149..70de091 100644
--- a/arch/sparc/defconfig
+++ b/arch/sparc/defconfig
@@ -704,7 +704,7 @@ CONFIG_PROC_KCORE=y
 CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/sparc64/defconfig b/arch/sparc64/defconfig
index 76eb832..4cb94a4 100644
--- a/arch/sparc64/defconfig
+++ b/arch/sparc64/defconfig
@@ -1297,8 +1297,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/um/defconfig b/arch/um/defconfig
index 6bd456f..0871508 100644
--- a/arch/um/defconfig
+++ b/arch/um/defconfig
@@ -425,7 +425,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_POSIX_ACL is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 # CONFIG_CONFIGFS_FS is not set
 
 #
diff --git a/arch/v850/configs/rte-ma1-cb_defconfig b/arch/v850/configs/rte-ma1-cb_defconfig
index 1a5beda..889aba1 100644
--- a/arch/v850/configs/rte-ma1-cb_defconfig
+++ b/arch/v850/configs/rte-ma1-cb_defconfig
@@ -513,7 +513,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/v850/configs/rte-me2-cb_defconfig b/arch/v850/configs/rte-me2-cb_defconfig
index 15e6664..5834182 100644
--- a/arch/v850/configs/rte-me2-cb_defconfig
+++ b/arch/v850/configs/rte-me2-cb_defconfig
@@ -375,7 +375,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/v850/configs/sim_defconfig b/arch/v850/configs/sim_defconfig
index f31ba73..bd38752 100644
--- a/arch/v850/configs/sim_defconfig
+++ b/arch/v850/configs/sim_defconfig
@@ -364,7 +364,7 @@ CONFIG_DNOTIFY=y
 CONFIG_PROC_FS=y
 CONFIG_SYSFS=y
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/x86/configs/i386_defconfig b/arch/x86/configs/i386_defconfig
index ad7ddaa..3a5a5c0 100644
--- a/arch/x86/configs/i386_defconfig
+++ b/arch/x86/configs/i386_defconfig
@@ -1279,8 +1279,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
index 2d6f5b2..a3c9e03 100644
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -1202,8 +1202,7 @@ CONFIG_PROC_SYSCTL=y
 CONFIG_SYSFS=y
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
-CONFIG_HUGETLBFS=y
-CONFIG_HUGETLB_PAGE=y
+CONFIG_HUGETLB=y
 CONFIG_RAMFS=y
 # CONFIG_CONFIGFS_FS is not set
 
diff --git a/arch/xtensa/configs/common_defconfig b/arch/xtensa/configs/common_defconfig
index 1d230ee..01073a1 100644
--- a/arch/xtensa/configs/common_defconfig
+++ b/arch/xtensa/configs/common_defconfig
@@ -574,7 +574,7 @@ CONFIG_DEVFS_FS=y
 # CONFIG_DEVFS_DEBUG is not set
 # CONFIG_DEVPTS_FS_XATTR is not set
 # CONFIG_TMPFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #
diff --git a/arch/xtensa/configs/iss_defconfig b/arch/xtensa/configs/iss_defconfig
index f198540..e3cd4a7 100644
--- a/arch/xtensa/configs/iss_defconfig
+++ b/arch/xtensa/configs/iss_defconfig
@@ -439,7 +439,7 @@ CONFIG_DEVFS_MOUNT=y
 # CONFIG_DEVPTS_FS_XATTR is not set
 CONFIG_TMPFS=y
 # CONFIG_TMPFS_XATTR is not set
-# CONFIG_HUGETLB_PAGE is not set
+# CONFIG_HUGETLB is not set
 CONFIG_RAMFS=y
 
 #


-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
