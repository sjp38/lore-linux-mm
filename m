Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 922E8831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 22:00:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i63so47976597pgd.15
        for <linux-mm@kvack.org>; Thu, 18 May 2017 19:00:00 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y70si6965025pfj.169.2017.05.18.18.59.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 18:59:59 -0700 (PDT)
Date: Fri, 19 May 2017 10:08:44 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master] BUILD REGRESSION
 ecfddce33be51ebedf97f1e03d954c14e575afb6
Message-ID: <591e53ac.LxEPO2bYH9oU0ZzP%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

git://git.cmpxchg.org/linux-mmotm.git  master
ecfddce33be51ebedf97f1e03d954c14e575afb6  pci: test for unexpectedly disabled bridges

include/asm-generic/memory_model.h:54:52: warning: 'page' is used uninitialized in this function [-Wuninitialized]
include/asm-generic/memory_model.h:54:52: warning: 'page' may be used uninitialized in this function [-Wmaybe-uninitialized]
mm/vmstat.c:1224:16: warning: 'page' may be used uninitialized in this function [-Wmaybe-uninitialized]
mm/vmstat.c:1230:8: warning: 'page' may be used uninitialized in this function [-Wmaybe-uninitialized]

Error ids grouped by kconfigs:

recent_errors
a??a??a?? alpha-allyesconfig
a??A A  a??a??a?? mm-vmstat.c:warning:page-may-be-used-uninitialized-in-this-function
a??a??a?? arm64-defconfig
a??A A  a??a??a?? mm-vmstat.c:warning:page-may-be-used-uninitialized-in-this-function
a??a??a?? arm-exynos_defconfig
a??A A  a??a??a?? mm-vmstat.c:warning:page-may-be-used-uninitialized-in-this-function
a??a??a?? arm-multi_v7_defconfig
a??A A  a??a??a?? mm-vmstat.c:warning:page-may-be-used-uninitialized-in-this-function
a??a??a?? i386-allmodconfig
a??A A  a??a??a?? mm-vmstat.c:warning:page-may-be-used-uninitialized-in-this-function
a??a??a?? i386-defconfig
a??A A  a??a??a?? mm-vmstat.c:warning:page-may-be-used-uninitialized-in-this-function
a??a??a?? x86_64-allmodconfig
a??A A  a??a??a?? mm-vmstat.c:warning:page-may-be-used-uninitialized-in-this-function
a??a??a?? x86_64-kexec
a??A A  a??a??a?? include-asm-generic-memory_model.h:warning:page-is-used-uninitialized-in-this-function
a??a??a?? x86_64-rhel
    a??a??a?? include-asm-generic-memory_model.h:warning:page-may-be-used-uninitialized-in-this-function

elapsed time: 238m

configs tested: 112

i386                               tinyconfig
x86_64                           allmodconfig
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
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
x86_64                                  kexec
x86_64                                   rhel
x86_64                               rhel-7.2
i386                   randconfig-a0-05181312
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
frv                                 defconfig
tile                         tilegx_defconfig
c6x                        evmc6678_defconfig
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
nios2                         10m50_defconfig
h8300                    h8300h-sim_defconfig
parisc                        c3000_defconfig
parisc                         b180_defconfig
parisc                              defconfig
alpha                               defconfig
parisc                            allnoconfig
cris                 etrax-100lx_v2_defconfig
blackfin                  TCM-BF537_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin                BF526-EZBRD_defconfig
x86_64                 randconfig-x019-201720
x86_64                 randconfig-x010-201720
x86_64                 randconfig-x015-201720
x86_64                 randconfig-x014-201720
x86_64                 randconfig-x012-201720
x86_64                 randconfig-x018-201720
x86_64                 randconfig-x017-201720
x86_64                 randconfig-x016-201720
x86_64                 randconfig-x013-201720
x86_64                 randconfig-x011-201720
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                         64r6el_defconfig
mips                           32r2_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
i386                   randconfig-x016-201720
i386                   randconfig-x017-201720
i386                   randconfig-x012-201720
i386                   randconfig-x018-201720
i386                   randconfig-x010-201720
i386                   randconfig-x019-201720
i386                   randconfig-x013-201720
i386                   randconfig-x014-201720
i386                   randconfig-x015-201720
i386                   randconfig-x011-201720
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
i386                 randconfig-x074-05150639
i386                 randconfig-x076-05150639
i386                 randconfig-x070-05150639
i386                 randconfig-x077-05150639
i386                 randconfig-x078-05150639
i386                 randconfig-x075-05150639
i386                 randconfig-x072-05150639
i386                 randconfig-x071-05150639
i386                 randconfig-x079-05150639
i386                 randconfig-x073-05150639
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
x86_64                 randconfig-x006-201720
x86_64                 randconfig-x007-201720
x86_64                 randconfig-x001-201720
x86_64                 randconfig-x004-201720
x86_64                 randconfig-x005-201720
x86_64                 randconfig-x000-201720
x86_64                 randconfig-x008-201720
x86_64                 randconfig-x002-201720
x86_64                 randconfig-x003-201720
x86_64                 randconfig-x009-201720
i386                             allmodconfig

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
