Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 90A636B025E
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 09:36:14 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id n5so29436613pfn.2
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 06:36:14 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id y8si20774052pas.240.2016.03.15.06.36.13
        for <linux-mm@kvack.org>;
        Tue, 15 Mar 2016 06:36:13 -0700 (PDT)
Date: Tue, 15 Mar 2016 21:35:26 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master] 6fdeb671774e468e2a7fa6ef8fe19bce6e8d638a
 BUILD DONE
Message-ID: <56e80f9e.ozaVqNmURfRyCAc1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
6fdeb671774e468e2a7fa6ef8fe19bce6e8d638a  Add linux-next specific files for 20160315

aio.c:(.text+0x456dc): undefined reference to `__get_user_unknown'
aio.c:(.text+0x471b0): undefined reference to `__get_user_unknown'
arch/parisc/include/asm/uaccess.h:40:18: note: in expansion of macro '__get_user'
arch/parisc/include/asm/uaccess.h:43:26: note: in expansion of macro 'BUILD_BUG'
arch/parisc/include/asm/uaccess.h:93:14: note: in expansion of macro 'LDD_KERNEL'
drivers/mfd/syscon.c:67:9: error: implicit declaration of function 'ioremap' [-Werror=implicit-function-declaration]
fs/aio.c:1775:11: error: call to '__compiletime_assert_1775' declared with attribute error: BUILD_BUG_ON failed: ptr_size >= 8
fs/aio.c:1775: undefined reference to `__get_user_bad'
fs/aio.c:1775: undefined reference to `__user_bad'
fs/aio.c:1786:20: note: in expansion of macro 'get_user'
fs/aio.c:1786: undefined reference to `__user_bad'
fs/aio.c:1787: undefined reference to `__get_user_unknown'
fs/aio.c:1799: undefined reference to `__get_user_unknown'
fs/open.c:822: undefined reference to `__get_user_unknown'
include/linux/compiler.h:472:2: note: in expansion of macro '__compiletime_assert'
include/linux/compiler.h:494:2: note: in expansion of macro '__compiletime_assert'
signalfd.c:(.text+0x2b448): undefined reference to `__get_user_bad'
./usr/include/asm/siginfo.h:96: found __[us]{8,16,32,64} type without #include <linux/types.h>

Error ids grouped by kconfigs:

recent_errors
a??a??a?? avr32-atngw100_defconfig
a??A A  a??a??a?? signalfd.c:(.text):undefined-reference-to-__get_user_bad
a??a??a?? blackfin-allyesconfig
a??A A  a??a??a?? fs-aio.c:error:call-to-__compiletime_assert_NNN-declared-with-attribute-error:BUILD_BUG_ON-failed:ptr_size
a??a??a?? m32r-opsput_defconfig
a??A A  a??a??a?? fs-aio.c:undefined-reference-to-__get_user_bad
a??a??a?? microblaze-mmu_defconfig
a??A A  a??a??a?? fs-aio.c:undefined-reference-to-__user_bad
a??a??a?? microblaze-nommu_defconfig
a??A A  a??a??a?? fs-aio.c:undefined-reference-to-__user_bad
a??a??a?? mips-fuloong2e_defconfig
a??A A  a??a??a?? usr-include-asm-siginfo.h:found-__-us-type-without-include-linux-types.h
a??a??a?? mips-malta_kvm_guest_defconfig
a??A A  a??a??a?? usr-include-asm-siginfo.h:found-__-us-type-without-include-linux-types.h
a??a??a?? mips-markeins_defconfig
a??A A  a??a??a?? usr-include-asm-siginfo.h:found-__-us-type-without-include-linux-types.h
a??a??a?? mips-txx9
a??A A  a??a??a?? usr-include-asm-siginfo.h:found-__-us-type-without-include-linux-types.h
a??a??a?? mips-xway_defconfig
a??A A  a??a??a?? usr-include-asm-siginfo.h:found-__-us-type-without-include-linux-types.h
a??a??a?? mn10300-asb2364_defconfig
a??A A  a??a??a?? fs-open.c:undefined-reference-to-__get_user_unknown
a??a??a?? parisc-b180_defconfig
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-BUILD_BUG
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-__get_user
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-LDD_KERNEL
a??A A  a??a??a?? fs-aio.c:note:in-expansion-of-macro-get_user
a??A A  a??a??a?? include-linux-compiler.h:note:in-expansion-of-macro-__compiletime_assert
a??a??a?? parisc-c3000_defconfig
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-BUILD_BUG
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-__get_user
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-LDD_KERNEL
a??A A  a??a??a?? fs-aio.c:note:in-expansion-of-macro-get_user
a??A A  a??a??a?? include-linux-compiler.h:note:in-expansion-of-macro-__compiletime_assert
a??a??a?? parisc-defconfig
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-BUILD_BUG
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-__get_user
a??A A  a??a??a?? arch-parisc-include-asm-uaccess.h:note:in-expansion-of-macro-LDD_KERNEL
a??A A  a??a??a?? fs-aio.c:note:in-expansion-of-macro-get_user
a??A A  a??a??a?? include-linux-compiler.h:note:in-expansion-of-macro-__compiletime_assert
a??a??a?? sh-alldefconfig
a??A A  a??a??a?? aio.c:(.text):undefined-reference-to-__get_user_unknown
a??a??a?? sh-r7785rp_defconfig
a??A A  a??a??a?? fs-aio.c:undefined-reference-to-__get_user_unknown
a??a??a?? sh-sh7785lcr_32bit_defconfig
a??A A  a??a??a?? fs-aio.c:undefined-reference-to-__get_user_unknown
a??a??a?? sh-titan_defconfig
a??A A  a??a??a?? aio.c:(.text):undefined-reference-to-__get_user_unknown
a??a??a?? um-allmodconfig
    a??a??a?? drivers-mfd-syscon.c:error:implicit-declaration-of-function-ioremap

elapsed time: 236m

configs tested: 185

i386                     randconfig-a0-201611
x86_64                 randconfig-a0-03151743
x86_64                 randconfig-a0-03151917
m68k                       m5275evb_defconfig
arm                             rpc_defconfig
mips                           xway_defconfig
powerpc               mpc85xx_basic_defconfig
mn10300                             defconfig
powerpc                 canyonlands_defconfig
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
i386                   randconfig-c0-03151705
i386                   randconfig-c0-03151752
i386                   randconfig-c0-03151846
i386                   randconfig-c0-03152002
arm                         at91_dt_defconfig
arm                               allnoconfig
arm                           efm32_defconfig
arm                        multi_v5_defconfig
arm                           sunxi_defconfig
arm                          exynos_defconfig
arm                        shmobile_defconfig
arm                        multi_v7_defconfig
x86_64                 randconfig-v0-03151707
x86_64                 randconfig-v0-03151901
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
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
um                               allmodconfig
sh                          r7785rp_defconfig
arm                          iop33x_defconfig
x86_64                 randconfig-x010-201611
x86_64                 randconfig-x018-201611
x86_64                 randconfig-x011-201611
x86_64                 randconfig-x019-201611
x86_64                 randconfig-x012-201611
x86_64                 randconfig-x013-201611
x86_64                 randconfig-x014-201611
x86_64                 randconfig-x016-201611
x86_64                 randconfig-x015-201611
x86_64                 randconfig-x017-201611
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
i386                     randconfig-s0-201611
x86_64                 randconfig-s0-03151711
x86_64                 randconfig-s2-03151711
x86_64                 randconfig-s1-03151711
x86_64                 randconfig-s1-03151827
x86_64                 randconfig-s0-03151827
x86_64                 randconfig-s2-03151827
x86_64                 randconfig-s0-03151900
x86_64                 randconfig-s1-03151900
x86_64                 randconfig-s2-03151900
x86_64                 randconfig-s1-03151936
x86_64                 randconfig-s0-03151936
x86_64                 randconfig-s2-03151936
x86_64                 randconfig-s0-03152004
x86_64                 randconfig-s2-03152004
x86_64                 randconfig-s1-03152004
x86_64                 randconfig-s4-03151724
x86_64                 randconfig-s5-03151724
x86_64                 randconfig-s3-03151724
x86_64                 randconfig-s5-03151757
x86_64                 randconfig-s4-03151757
x86_64                 randconfig-s3-03151757
x86_64                 randconfig-s5-03151853
x86_64                 randconfig-s4-03151853
x86_64                 randconfig-s3-03151853
x86_64                 randconfig-s5-03151929
x86_64                 randconfig-s4-03151929
x86_64                 randconfig-s3-03151929
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
avr32                      atngw100_defconfig
frv                                 defconfig
avr32                     atstk1006_defconfig
tile                         tilegx_defconfig
powerpc                             defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
x86_64                   randconfig-i0-201611
i386                   randconfig-b0-03151742
i386                   randconfig-b0-03151918
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
arm                             ezx_defconfig
sparc                            allyesconfig
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-i1-201611
i386                     randconfig-i0-201611
x86_64                 randconfig-b0-03151724
x86_64                 randconfig-b0-03151752
x86_64                 randconfig-b0-03151956
parisc                        c8000_defconfig
sh                               alldefconfig
x86_64                 randconfig-n0-03151734
x86_64                 randconfig-n0-03151855
x86_64                 randconfig-n0-03151925
i386                   randconfig-x013-201611
i386                   randconfig-x012-201611
i386                   randconfig-x019-201611
i386                   randconfig-x015-201611
i386                   randconfig-x011-201611
i386                   randconfig-x018-201611
i386                   randconfig-x010-201611
i386                   randconfig-x016-201611
i386                   randconfig-x017-201611
i386                   randconfig-x014-201611
i386                     randconfig-n0-201611
i386                   randconfig-h0-03151715
i386                   randconfig-h1-03151715
i386                   randconfig-h0-03151849
i386                   randconfig-h1-03151849
x86_64                 randconfig-h0-03151754
x86_64                 randconfig-h0-03151932
arm                        mvebu_v5_defconfig
s390                             allyesconfig
x86_64                 randconfig-n0-03151818
x86_64                 randconfig-n0-03151910
x86_64                 randconfig-n0-03151955
i386                  randconfig-sb0-03151843
powerpc                 mpc8313_rdb_defconfig
powerpc                     asp8347_defconfig
mips                       markeins_defconfig
x86_64                 randconfig-x001-201611
x86_64                 randconfig-x000-201611
x86_64                 randconfig-x007-201611
x86_64                 randconfig-x005-201611
x86_64                 randconfig-x006-201611
x86_64                 randconfig-x004-201611
x86_64                 randconfig-x009-201611
x86_64                 randconfig-x008-201611
x86_64                 randconfig-x003-201611
x86_64                 randconfig-x002-201611
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
x86_64                                    lkp
x86_64                 randconfig-r0-03151715
x86_64                 randconfig-r0-03151855
powerpc                    klondike_defconfig
mips                malta_kvm_guest_defconfig
arm                         em_x270_defconfig
i386                   randconfig-x000-201611
i386                   randconfig-x003-201611
i386                   randconfig-x009-201611
i386                   randconfig-x004-201611
i386                   randconfig-x005-201611
i386                   randconfig-x002-201611
i386                   randconfig-x006-201611
i386                   randconfig-x007-201611
i386                   randconfig-x001-201611
i386                   randconfig-x008-201611
mips                                   jz4740
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
i386                   randconfig-x0-03151753
i386                   randconfig-x0-03151919

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
