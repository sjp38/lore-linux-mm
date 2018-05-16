Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90DBC6B034F
	for <linux-mm@kvack.org>; Wed, 16 May 2018 14:09:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b25-v6so1018690pfn.10
        for <linux-mm@kvack.org>; Wed, 16 May 2018 11:09:15 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id g12-v6si3012954pla.194.2018.05.16.11.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 11:09:14 -0700 (PDT)
Date: Thu, 17 May 2018 02:08:25 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [linux-next:master] BUILD REGRESSION
 005b4ec128460ddb3b9a6d15534d79cfb331399e
Message-ID: <5afc7399.0tDGNYRzjev9w7lz%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

tree/branch: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
branch HEAD: 005b4ec128460ddb3b9a6d15534d79cfb331399e  Add linux-next specific files for 20180516

Regressions in current branch:

arch/mips/kernel/traps.c:732:2: error: 'si_code' may be used uninitialized in this function [-Werror=maybe-uninitialized]
include/linux/mlx5/driver.h:1299:13: error: 'struct irq_desc' has no member named 'affinity_hint'
sound/isa/ad1816a/ad1816a_lib.c:253:53: sparse: incorrect type in argument 2 (different base types)
sound/isa/ad1816a/ad1816a_lib.c:93:14: sparse: restricted snd_pcm_format_t degrades to integer
WARNING: vmlinux.o(.text+0x164c): Section mismatch in reference from the function inet_put_port() to the function .init.text:find_pa_parent_type()

Error ids grouped by kconfigs:

recent_errors
a??a??a?? mips-allnoconfig
a??A A  a??a??a?? arch-mips-kernel-traps.c:error:si_code-may-be-used-uninitialized-in-this-function
a??a??a?? mips-decstation_defconfig
a??A A  a??a??a?? arch-mips-kernel-traps.c:error:si_code-may-be-used-uninitialized-in-this-function
a??a??a?? mips-fuloong2e_defconfig
a??A A  a??a??a?? arch-mips-kernel-traps.c:error:si_code-may-be-used-uninitialized-in-this-function
a??a??a?? mips-malta_kvm_defconfig
a??A A  a??a??a?? arch-mips-kernel-traps.c:error:si_code-may-be-used-uninitialized-in-this-function
a??a??a?? mips-malta_kvm_guest_defconfig
a??A A  a??a??a?? arch-mips-kernel-traps.c:error:si_code-may-be-used-uninitialized-in-this-function
a??a??a?? mips-sb1250_swarm_defconfig
a??A A  a??a??a?? arch-mips-kernel-traps.c:error:si_code-may-be-used-uninitialized-in-this-function
a??a??a?? parisc-allmodconfig
a??A A  a??a??a?? Section-mismatch-in-reference-from-the-function-inet_put_port()-to-the-function-.init.text:find_pa_parent_type()
a??a??a?? x86_64-allmodconfig
a??A A  a??a??a?? sound-isa-ad1816a-ad1816a_lib.c:sparse:incorrect-type-in-argument-(different-base-types)-expected-unsigned-int-unsigned-format-got-restricted-snd_unsigned-int-unsigned-format
a??A A  a??a??a?? sound-isa-ad1816a-ad1816a_lib.c:sparse:restricted-snd_pcm_format_t-degrades-to-integer
a??a??a?? x86_64-randconfig-s4-05161958
    a??a??a?? include-linux-mlx5-driver.h:error:struct-irq_desc-has-no-member-named-affinity_hint

elapsed time: 387m

configs tested: 246

s390                          debug_defconfig
arm                          iop33x_defconfig
powerpc                 mpc8272_ads_defconfig
x86_64                 randconfig-a0-05161950
x86_64                 randconfig-a0-05162046
x86_64                 randconfig-a0-05162126
m68k                            mac_defconfig
arm                         s5pv210_defconfig
arm                           sama5_defconfig
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
i386                   randconfig-c0-05162019
i386                   randconfig-c0-05162101
i386                   randconfig-c0-05162149
mips                     loongson1c_defconfig
x86_64                randconfig-in0-05162029
i386                               tinyconfig
i386                   randconfig-x013-201819
i386                   randconfig-x014-201819
i386                   randconfig-x016-201819
i386                   randconfig-x019-201819
i386                   randconfig-x012-201819
i386                   randconfig-x015-201819
i386                   randconfig-x018-201819
i386                   randconfig-x010-201819
i386                   randconfig-x011-201819
i386                   randconfig-x017-201819
i386                     randconfig-n0-201819
x86_64                 randconfig-x002-201819
x86_64                 randconfig-x006-201819
x86_64                 randconfig-x005-201819
x86_64                 randconfig-x001-201819
x86_64                 randconfig-x009-201819
x86_64                 randconfig-x004-201819
x86_64                 randconfig-x003-201819
x86_64                 randconfig-x000-201819
x86_64                 randconfig-x007-201819
x86_64                 randconfig-x008-201819
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
i386                     randconfig-i1-201819
i386                     randconfig-i0-201819
sh                         ap325rxa_defconfig
x86_64                 randconfig-v0-05162057
arm                         at91_dt_defconfig
arm                               allnoconfig
arm                           efm32_defconfig
arm64                               defconfig
arm                           sunxi_defconfig
arm64                             allnoconfig
arm                          exynos_defconfig
arm                        shmobile_defconfig
arm                        multi_v7_defconfig
arm                        multi_v5_defconfig
powerpc                    socrates_defconfig
arm                         nhk8815_defconfig
x86_64                                  kexec
x86_64                                   rhel
x86_64                               rhel-7.2
x86_64                              fedora-25
x86_64                 randconfig-g0-05162018
x86_64                 randconfig-g0-05162124
c6x                        evmc6678_defconfig
xtensa                       common_defconfig
xtensa                          iss_defconfig
nios2                         10m50_defconfig
h8300                    h8300h-sim_defconfig
i386                             allmodconfig
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
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
i386                     randconfig-a0-201819
i386                     randconfig-a1-201819
x86_64                 randconfig-s2-05161930
x86_64                 randconfig-s0-05161930
x86_64                 randconfig-s1-05161930
x86_64                 randconfig-s0-05162008
x86_64                 randconfig-s1-05162008
x86_64                 randconfig-s2-05162008
x86_64                 randconfig-s2-05162047
x86_64                 randconfig-s0-05162047
x86_64                 randconfig-s1-05162047
x86_64                 randconfig-s0-05162129
x86_64                 randconfig-s2-05162129
x86_64                 randconfig-s1-05162129
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
parisc                        c3000_defconfig
parisc                         b180_defconfig
parisc                              defconfig
alpha                               defconfig
parisc                            allnoconfig
arm                       omap2plus_defconfig
powerpc                     tqm8560_defconfig
nios2                         3c120_defconfig
alpha                            alldefconfig
sparc64                          allyesconfig
powerpc                     mpc83xx_defconfig
powerpc                  mpc885_ads_defconfig
x86_64                 randconfig-x010-201819
x86_64                 randconfig-x013-201819
x86_64                 randconfig-x014-201819
x86_64                 randconfig-x011-201819
x86_64                 randconfig-x015-201819
x86_64                 randconfig-x019-201819
x86_64                 randconfig-x016-201819
x86_64                 randconfig-x018-201819
x86_64                 randconfig-x012-201819
x86_64                 randconfig-x017-201819
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
i386                     randconfig-s1-201819
i386                     randconfig-s0-201819
x86_64                 randconfig-s3-05161923
x86_64                 randconfig-s5-05161923
x86_64                 randconfig-s4-05161923
x86_64                 randconfig-s4-05161958
x86_64                 randconfig-s3-05161958
x86_64                 randconfig-s5-05161958
x86_64                 randconfig-s3-05162043
x86_64                 randconfig-s4-05162043
x86_64                 randconfig-s5-05162043
x86_64                 randconfig-s4-05162116
x86_64                 randconfig-s3-05162116
x86_64                 randconfig-s5-05162116
x86_64                 randconfig-s3-05162149
x86_64                 randconfig-s5-05162149
x86_64                 randconfig-s4-05162149
parisc                           allmodconfig
powerpc                       eiger_defconfig
arm                           viper_defconfig
xtensa                generic_kc705_defconfig
arm                             rpc_defconfig
sh                           se7721_defconfig
x86_64                   randconfig-i0-201819
i386                   randconfig-b0-05161930
i386                   randconfig-b0-05162015
i386                   randconfig-b0-05162056
i386                   randconfig-b0-05162144
x86_64                 randconfig-b0-05162053
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
x86_64                           allmodconfig
powerpc                     asp8347_defconfig
mips                     decstation_defconfig
arm                         cm_x2xx_defconfig
arm                    vt8500_v6_v7_defconfig
x86_64                 randconfig-u0-05161950
x86_64                 randconfig-u0-05162023
x86_64                 randconfig-u0-05162055
x86_64                 randconfig-u0-05162159
sh                          landisk_defconfig
powerpc                    amigaone_defconfig
i386                   randconfig-h1-05162033
i386                   randconfig-h0-05162033
i386                   randconfig-h1-05162158
i386                   randconfig-h0-05162158
arm                     eseries_pxa_defconfig
alpha                            allmodconfig
arm                         palmz72_defconfig
x86_64                randconfig-ne0-05161959
x86_64                randconfig-ne0-05162048
x86_64                randconfig-ne0-05162131
x86_64                randconfig-ne0-05162214
mips                malta_kvm_guest_defconfig
powerpc                       holly_defconfig
powerpc                         ps3_defconfig
powerpc                     ppa8548_defconfig
x86_64                 randconfig-h0-05162000
x86_64                 randconfig-h0-05162038
x86_64                 randconfig-h0-05162154
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
i386                   randconfig-x073-201819
i386                   randconfig-x075-201819
i386                   randconfig-x079-201819
i386                   randconfig-x071-201819
i386                   randconfig-x076-201819
i386                   randconfig-x074-201819
i386                   randconfig-x078-201819
i386                   randconfig-x070-201819
i386                   randconfig-x077-201819
i386                   randconfig-x072-201819
i386                  randconfig-sb0-05162050
i386                  randconfig-sb0-05162145
x86_64                              defconfig
x86_64                            allnoconfig
i386                   randconfig-x008-201819
i386                   randconfig-x006-201819
i386                   randconfig-x000-201819
i386                   randconfig-x004-201819
i386                   randconfig-x009-201819
i386                   randconfig-x003-201819
i386                   randconfig-x001-201819
i386                   randconfig-x005-201819
i386                   randconfig-x002-201819
i386                   randconfig-x007-201819
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
arm                          tango4_defconfig
powerpc                      obs600_defconfig
m68k                            q40_defconfig
x86_64                randconfig-ws0-05161952
x86_64                randconfig-ws0-05162059
i386                             allyesconfig
mips                   sb1250_swarm_defconfig
x86_64                randconfig-ws0-05161932
x86_64                randconfig-ws0-05162040
x86_64                randconfig-ws0-05162153
arm                        vexpress_defconfig
sh                           se7712_defconfig
x86_64                 randconfig-r0-05162113
s390                    performance_defconfig
s390                             allyesconfig
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
i386                   randconfig-x0-05161949
i386                   randconfig-x0-05162031
i386                   randconfig-x0-05162104
i386                   randconfig-x0-05162142

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
