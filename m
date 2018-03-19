Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEBD46B0005
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:34:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n15so706486pff.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 16:34:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v3-v6si326042plb.522.2018.03.19.16.33.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 16:33:59 -0700 (PDT)
Date: Tue, 20 Mar 2018 07:33:20 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master] BUILD REGRESSION
 a5444cde9dc2120612e50fc5a56c975e67a041fb
Message-ID: <5ab048c0.wmRYTJi5ip8zBzJ4%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

tree/branch: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
branch HEAD: a5444cde9dc2120612e50fc5a56c975e67a041fb  Add linux-next specific files for 20180319

Regressions in current branch:

ERROR: "__sw_hweight8" [drivers/net/wireless/mediatek/mt76/mt76.ko] undefined!
Kconfig:12: can't open file "arch/cris/Kconfig"
Kconfig:12: can't open file "arch/m32r/Kconfig"
Kconfig:12: can't open file "arch/score/Kconfig"
Kconfig:12: can't open file "arch/tile/Kconfig"
make[1]: *** No rule to make target 'arch/m32r/Makefile'.
make[1]: *** No rule to make target 'arch/score/Makefile'.
Makefile:636: arch/m32r/Makefile: No such file or directory
Makefile:636: arch/score/Makefile: No such file or directory
net/netfilter/nft_ct.c:202:23: sparse: incorrect type in assignment (different base types)

Error ids grouped by kconfigs:

recent_errors
a??a??a?? cris-allyesconfig
a??A A  a??a??a?? Kconfig:can-t-open-file-arch-cris-Kconfig
a??a??a?? ia64-allmodconfig
a??A A  a??a??a?? ERROR:__sw_hweight8-drivers-net-wireless-mediatek-mt76-mt76.ko-undefined
a??a??a?? m32r-m32104ut_defconfig
a??A A  a??a??a?? Kconfig:can-t-open-file-arch-m32r-Kconfig
a??A A  a??a??a?? Makefile:arch-m32r-Makefile:No-such-file-or-directory
a??A A  a??a??a?? make:No-rule-to-make-target-arch-m32r-Makefile-.
a??a??a?? score-spct6600_defconfig
a??A A  a??a??a?? Kconfig:can-t-open-file-arch-score-Kconfig
a??A A  a??a??a?? Makefile:arch-score-Makefile:No-such-file-or-directory
a??A A  a??a??a?? make:No-rule-to-make-target-arch-score-Makefile-.
a??a??a?? tile-allyesconfig
a??A A  a??a??a?? Kconfig:can-t-open-file-arch-tile-Kconfig
a??a??a?? x86_64-allmodconfig
    a??a??a?? net-netfilter-nft_ct.c:sparse:incorrect-type-in-assignment-(different-base-types)-expected-unsigned-int-unsigned-usertype-noident-got-unsigned-int-unsigned-usertype-noident

elapsed time: 800m

configs tested: 135

parisc                        c3000_defconfig
parisc                         b180_defconfig
parisc                              defconfig
alpha                               defconfig
parisc                            allnoconfig
powerpc                   motionpro_defconfig
mips                      maltaaprp_defconfig
arm                          iop32x_defconfig
x86_64                 randconfig-a0-03192011
cris                 etrax-100lx_v2_defconfig
i386                               tinyconfig
i386                   randconfig-x013-201811
i386                   randconfig-x014-201811
i386                   randconfig-x012-201811
i386                   randconfig-x015-201811
i386                   randconfig-x016-201811
i386                   randconfig-x019-201811
i386                   randconfig-x010-201811
i386                   randconfig-x018-201811
i386                   randconfig-x011-201811
i386                   randconfig-x017-201811
i386                     randconfig-n0-201811
x86_64                 randconfig-x002-201811
x86_64                 randconfig-x006-201811
x86_64                 randconfig-x005-201811
x86_64                 randconfig-x009-201811
x86_64                 randconfig-x004-201811
x86_64                 randconfig-x001-201811
x86_64                 randconfig-x008-201811
x86_64                 randconfig-x003-201811
x86_64                 randconfig-x000-201811
x86_64                 randconfig-x007-201811
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
i386                     randconfig-i1-201811
i386                     randconfig-i0-201811
x86_64                                nfsroot
i386                   randconfig-a0-03190951
i386                   randconfig-a1-03190951
x86_64                                   rhel
i386                     randconfig-s1-201811
i386                     randconfig-s0-201811
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
frv                                 defconfig
tile                         tilegx_defconfig
arm                       cns3420vb_defconfig
powerpc                 mpc8313_rdb_defconfig
m68k                          sun3x_defconfig
arm                          badge4_defconfig
x86_64                 randconfig-b0-03192033
sparc64                           allnoconfig
sparc64                             defconfig
x86_64                           allmodconfig
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
sh                            hp6xx_defconfig
sparc                               defconfig
x86_64                 randconfig-x010-201811
x86_64                 randconfig-x013-201811
x86_64                 randconfig-x014-201811
x86_64                 randconfig-x019-201811
x86_64                 randconfig-x011-201811
x86_64                 randconfig-x015-201811
x86_64                 randconfig-x018-201811
x86_64                 randconfig-x016-201811
x86_64                 randconfig-x017-201811
x86_64                 randconfig-x012-201811
i386                   randconfig-x073-201811
i386                   randconfig-x075-201811
i386                   randconfig-x071-201811
i386                   randconfig-x076-201811
i386                   randconfig-x079-201811
i386                   randconfig-x070-201811
i386                   randconfig-x077-201811
i386                   randconfig-x074-201811
i386                   randconfig-x078-201811
i386                   randconfig-x072-201811
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
arm                         at91_dt_defconfig
arm                               allnoconfig
arm                           efm32_defconfig
arm64                               defconfig
arm                        multi_v5_defconfig
arm                           sunxi_defconfig
arm64                             allnoconfig
arm                          exynos_defconfig
arm                        shmobile_defconfig
arm                        multi_v7_defconfig
i386                             allmodconfig
powerpc                     powernv_defconfig
powerpc                    adder875_defconfig
arm                          ixp4xx_defconfig
i386                   randconfig-x006-201811
i386                   randconfig-x000-201811
i386                   randconfig-x008-201811
i386                   randconfig-x004-201811
i386                   randconfig-x009-201811
i386                   randconfig-x003-201811
i386                   randconfig-x005-201811
i386                   randconfig-x002-201811
i386                   randconfig-x001-201811
i386                   randconfig-x007-201811
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
i386                   randconfig-x0-03191945

Thanks,
Fengguang
