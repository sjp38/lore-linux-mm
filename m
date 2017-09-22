Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 78E106B025E
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 14:06:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 6so3481827pgh.0
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 11:06:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m21si194580pgn.782.2017.09.22.11.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 11:06:16 -0700 (PDT)
Date: Sat, 23 Sep 2017 02:06:07 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master] BUILD REGRESSION
 73527316e3fdde8a210b8ab66c1bf48538cf6b09
Message-ID: <59c5510f.nUG+uuK9sNAz2vhW%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
73527316e3fdde8a210b8ab66c1bf48538cf6b09  Add linux-next specific files for 20170922

grep: ./.config.32r2_defconfig: No such file or directory
WARNING: lib/test_rhashtable.o(.text+0x954): Section mismatch in reference from the function T.882() to the variable .init.data:rhlt
WARNING: vmlinux.o(.text+0x224586): Section mismatch in reference from the function T.971() to the variable .init.data:rhlt

Error ids grouped by kconfigs:

recent_errors
a??a??a?? mips-32r2_defconfig
a??A A  a??a??a?? grep:.-.config.32r2_defconfig:No-such-file-or-directory
a??a??a?? x86_64-randconfig-a0-09221646
a??A A  a??a??a?? Section-mismatch-in-reference-from-the-function-T971()-to-the-variable-.init.data:rhlt
a??a??a?? x86_64-randconfig-v0-09221815
    a??a??a?? Section-mismatch-in-reference-from-the-function-T882()-to-the-variable-.init.data:rhlt

elapsed time: 569m

configs tested: 239

powerpc                      katmai_defconfig
m32r                   mappi2.vdec2_defconfig
arm                           sunxi_defconfig
powerpc                    ge_imp3a_defconfig
x86_64                 randconfig-a0-09221828
x86_64                 randconfig-a0-09221900
x86_64                 randconfig-a0-09221928
i386                               tinyconfig
mips                       rbtx49xx_defconfig
arm                            xcep_defconfig
arm                       netwinder_defconfig
mn10300                     asb2364_defconfig
arm                                 defconfig
x86_64                randconfig-in0-09221652
x86_64                randconfig-in0-09221836
powerpc                      pasemi_defconfig
powerpc                     ppa8548_defconfig
m68k                       m5249evb_defconfig
mn10300                          allyesconfig
sh                   sh7770_generic_defconfig
arm                         lpc18xx_defconfig
i386                     randconfig-n0-201738
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
arm                        spear6xx_defconfig
powerpc                 mpc834x_itx_defconfig
arm                            lart_defconfig
powerpc                    adder875_defconfig
mips                      maltasmvp_defconfig
m68k                       bvme6000_defconfig
x86_64                 randconfig-v0-09221743
x86_64                 randconfig-v0-09221815
x86_64                 randconfig-v0-09221845
x86_64                 randconfig-v0-09221927
parisc                         b180_defconfig
parisc                              defconfig
arm                        mvebu_v5_defconfig
sh                        edosk7705_defconfig
m68k                            q40_defconfig
x86_64                 randconfig-g0-09221926
x86_64                 randconfig-x011-201738
x86_64                 randconfig-x016-201738
x86_64                 randconfig-x013-201738
x86_64                 randconfig-x018-201738
x86_64                 randconfig-x019-201738
x86_64                 randconfig-x014-201738
x86_64                 randconfig-x012-201738
x86_64                 randconfig-x015-201738
x86_64                 randconfig-x017-201738
x86_64                 randconfig-x010-201738
arm                       omap2plus_defconfig
arm                                    sa1100
arm                              allmodconfig
arm                                   samsung
arm                        mvebu_v7_defconfig
arm                          ixp4xx_defconfig
arm                       imx_v6_v7_defconfig
arm64                            allmodconfig
arm                           tegra_defconfig
arm                                      arm5
arm64                            alldefconfig
arm                                        sh
arm                                     arm67
i386                   randconfig-a1-09180847
i386                   randconfig-a0-09180847
cris                 etrax-100lx_v2_defconfig
blackfin                  TCM-BF537_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin                BF526-EZBRD_defconfig
powerpc64                         allnoconfig
sh                          rsk7264_defconfig
m68k                            mac_defconfig
powerpc                       holly_defconfig
arm                           stm32_defconfig
i386                     randconfig-s1-201738
i386                     randconfig-s0-201738
x86_64                 randconfig-s3-09221825
x86_64                 randconfig-s4-09221825
x86_64                 randconfig-s5-09221825
x86_64                 randconfig-s5-09221913
x86_64                 randconfig-s4-09221913
x86_64                 randconfig-s3-09221913
i386                             allmodconfig
arm                         assabet_defconfig
powerpc                       ebony_defconfig
blackfin             BF527-EZKIT-V2_defconfig
arm                              zx_defconfig
arm64                               defconfig
parisc                        c3000_defconfig
m32r                             allmodconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                         64r6el_defconfig
mips                           32r2_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
x86_64                   randconfig-i0-201738
i386                   randconfig-b0-09221652
i386                   randconfig-b0-09221728
i386                   randconfig-b0-09221758
i386                   randconfig-b0-09221831
i386                   randconfig-b0-09221859
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
blackfin                  CM-BF537E_defconfig
sh                 kfr2r09-romimage_defconfig
m68k                        m5272c3_defconfig
parisc                            allnoconfig
i386                     randconfig-i1-201738
i386                     randconfig-i0-201738
x86_64                 randconfig-b0-09221922
um                             i386_defconfig
blackfin                  CM-BF537U_defconfig
alpha                               defconfig
powerpc                    gamecube_defconfig
frv                               allnoconfig
mips                   sb1250_swarm_defconfig
c6x                         dsk6455_defconfig
blackfin                         alldefconfig
arm                           sama5_defconfig
i386                   randconfig-x013-201738
i386                   randconfig-x019-201738
i386                   randconfig-x018-201738
i386                   randconfig-x016-201738
i386                   randconfig-x012-201738
i386                   randconfig-x015-201738
i386                   randconfig-x011-201738
i386                   randconfig-x010-201738
i386                   randconfig-x017-201738
i386                   randconfig-x014-201738
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
frv                                 defconfig
tile                         tilegx_defconfig
powerpc                  iss476-smp_defconfig
mips                       capcella_defconfig
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
x86_64                           allmodconfig
i386                   randconfig-x000-201738
i386                   randconfig-x003-201738
i386                   randconfig-x009-201738
i386                   randconfig-x004-201738
i386                   randconfig-x008-201738
i386                   randconfig-x001-201738
i386                   randconfig-x005-201738
i386                   randconfig-x002-201738
i386                   randconfig-x006-201738
i386                   randconfig-x007-201738
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
x86_64                 randconfig-x000-201738
x86_64                 randconfig-x007-201738
x86_64                 randconfig-x001-201738
x86_64                 randconfig-x006-201738
x86_64                 randconfig-x004-201738
x86_64                 randconfig-x009-201738
x86_64                 randconfig-x003-201738
x86_64                 randconfig-x002-201738
x86_64                 randconfig-x005-201738
x86_64                 randconfig-x008-201738
x86_64                                  kexec
x86_64                                   rhel
arm                       cns3420vb_defconfig
powerpc                      ppc44x_defconfig
sh                         apsh4a3a_defconfig
powerpc                     kmeter1_defconfig
m32r                        oaks32r_defconfig
ia64                      gensparse_defconfig
x86_64                randconfig-ws0-09221709
x86_64                randconfig-ws0-09221811
x86_64                randconfig-ws0-09221919
m68k                          atari_defconfig
mips                          rb532_defconfig
arm                            mmp2_defconfig
sparc                            alldefconfig
xtensa                    smp_lx200_defconfig
arm                           viper_defconfig
x86_64                randconfig-ws0-09221717
x86_64                randconfig-ws0-09221816
c6x                        evmc6678_defconfig
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
score                      spct6600_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
nios2                         10m50_defconfig
h8300                    h8300h-sim_defconfig
arm                         at91_dt_defconfig
arm                               allnoconfig
arm                           efm32_defconfig
arm                        multi_v5_defconfig
arm64                             allnoconfig
arm                          exynos_defconfig
arm                        shmobile_defconfig
arm                        multi_v7_defconfig
i386                   randconfig-x075-201738
i386                   randconfig-x076-201738
i386                   randconfig-x071-201738
i386                   randconfig-x074-201738
i386                   randconfig-x070-201738
i386                   randconfig-x077-201738
i386                   randconfig-x078-201738
i386                   randconfig-x073-201738
i386                   randconfig-x072-201738
i386                   randconfig-x079-201738
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
x86_64                           allyesdebian
x86_64                                nfsroot
powerpc                    sam440ep_defconfig
powerpc                          allyesconfig
arm                         mv78xx0_defconfig
arm                       aspeed_g4_defconfig
arm                           acs5k_defconfig
x86_64                 randconfig-r0-09221729
x86_64                 randconfig-r0-09221806
x86_64                 randconfig-r0-09221836
powerpc                     powernv_defconfig
openrisc                         allmodconfig
i386                   randconfig-x0-09221723
i386                   randconfig-x0-09221819
i386                   randconfig-x0-09221908

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
