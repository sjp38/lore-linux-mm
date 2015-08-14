Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B091C6B0253
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 06:30:55 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so57421323pab.0
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 03:30:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rr7si8339694pab.86.2015.08.14.03.30.54
        for <linux-mm@kvack.org>;
        Fri, 14 Aug 2015 03:30:54 -0700 (PDT)
Date: Fri, 14 Aug 2015 18:30:37 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master] f6a6014bf6b3c724cff30194681f219ac230c898 BUILD
 DONE
Message-ID: <55cdc34d.ikXLlB/1ZzB1s53C%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

git://git.cmpxchg.org/linux-mmotm.git  master
f6a6014bf6b3c724cff30194681f219ac230c898  pci: test for unexpectedly disabled bridges

arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:205:12: warning: '__decompress' defined but not used [-Wunused-function]
arch/arm/boot/compressed/../../../../lib/decompress_inflate.c:205:17: warning: '__decompress' defined but not used [-Wunused-function]
arch/arm/boot/compressed/../../../../lib/decompress_unlzma.c:680:17: warning: '__decompress' defined but not used [-Wunused-function]
arch/arm/boot/compressed/../../../../lib/decompress_unlzo.c:301:17: warning: '__decompress' defined but not used [-Wunused-function]
arch/m32r/boot/compressed/../../../../lib/decompress_inflate.c:205:17: warning: '__decompress' defined but not used [-Wunused-function]
arch/sh/boot/compressed/../../../../lib/decompress_inflate.c:205:17: warning: '__decompress' defined but not used [-Wunused-function]
include/linux/mm_types.h:371:22: error: 'HUGE_MAX_HSTATE' undeclared here (not in a function)
kernel/kexec_file.c:126:1: sparse: symbol 'arch_kexec_apply_relocations' was not declared. Should it be static?
mm/hugetlb.c:2812:4: warning: format '%d' expects argument of type 'int', but argument 4 has type 'long unsigned int' [-Wformat=]

Error ids grouped by kconfigs:

recent_errors
a??a??a?? arm-arm5
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? arm-arm67
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? arm-imx_v6_v7_defconfig
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_unlzo.c:warning:__decompress-defined-but-not-used
a??a??a?? arm-mmp
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? arm-omap2plus_defconfig
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_unlzma.c:warning:__decompress-defined-but-not-used
a??a??a?? arm-s3c2410_defconfig
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? arm-sa1100
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? arm-tegra_defconfig
a??A A  a??a??a?? arch-arm-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? i386-randconfig-i1-201532
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? i386-randconfig-n0-201532
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? ia64-defconfig
a??A A  a??a??a?? include-linux-mm_types.h:error:HUGE_MAX_HSTATE-undeclared-here-(not-in-a-function)
a??a??a?? m32r-m32104ut_defconfig
a??A A  a??a??a?? arch-m32r-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? powerpc-defconfig
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? powerpc-ppc64_defconfig
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? sh-sh7785lcr_32bit_defconfig
a??A A  a??a??a?? include-linux-mm_types.h:error:HUGE_MAX_HSTATE-undeclared-here-(not-in-a-function)
a??a??a?? sh-titan_defconfig
a??A A  a??a??a?? arch-sh-boot-compressed-..-..-..-..-lib-decompress_inflate.c:warning:__decompress-defined-but-not-used
a??a??a?? sparc64-defconfig
a??A A  a??a??a?? include-linux-mm_types.h:error:HUGE_MAX_HSTATE-undeclared-here-(not-in-a-function)
a??a??a?? x86_64-acpi-redef
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? x86_64-allmodconfig
a??A A  a??a??a?? kernel-kexec_file.c:sparse:symbol-arch_kexec_apply_relocations-was-not-declared.-Should-it-be-static
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? x86_64-allyesdebian
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? x86_64-nfsroot
a??A A  a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int
a??a??a?? x86_64-rhel
    a??a??a?? mm-hugetlb.c:warning:format-d-expects-argument-of-type-int-but-argument-has-type-long-unsigned-int

elapsed time: 676m

configs tested: 101

parisc                        c3000_defconfig
parisc                              defconfig
alpha                               defconfig
parisc                            allnoconfig
i386                     randconfig-a0-201532
cris                 etrax-100lx_v2_defconfig
blackfin                  TCM-BF537_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin                BF526-EZBRD_defconfig
x86_64                           allmodconfig
x86_64                            allnoconfig
i386                              allnoconfig
i386                                defconfig
i386                             allmodconfig
i386                             alldefconfig
powerpc                             defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
x86_64                   randconfig-i0-201532
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-i1-201532
i386                     randconfig-i0-201532
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
x86_64                                    lkp
i386                     randconfig-n0-201532
arm                       omap2plus_defconfig
arm                         s3c2410_defconfig
arm                                       mmp
arm                           tegra_defconfig
arm                                      arm5
arm                                     arm67
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
x86_64                                   rhel
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
avr32                      atngw100_defconfig
frv                                 defconfig
avr32                     atstk1006_defconfig
tile                         tilegx_defconfig
arm                                    sa1100
arm                          prima2_defconfig
arm                         at91_dt_defconfig
arm                               allnoconfig
arm                                   samsung
arm                       spear13xx_defconfig
arm                                  iop-adma
arm                       imx_v6_v7_defconfig
arm                          marzen_defconfig
arm                                  at_hdmac
arm                                    ep93xx
arm                                        sh
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
m68k                          amiga_defconfig
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
x86_64               randconfig-x002-08121450
x86_64               randconfig-x009-08121450
x86_64               randconfig-x004-08121450
x86_64               randconfig-x003-08121450
x86_64               randconfig-x006-08121450
x86_64               randconfig-x008-08121450
x86_64               randconfig-x007-08121450
x86_64               randconfig-x001-08121450
x86_64               randconfig-x000-08121450
x86_64               randconfig-x005-08121450
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
i386                     randconfig-r0-201532
i386                 randconfig-x000-08101704
i386                 randconfig-x006-08101704
i386                 randconfig-x003-08101704
i386                 randconfig-x005-08101704
i386                 randconfig-x001-08101704
i386                 randconfig-x008-08101704
i386                 randconfig-x009-08101704
i386                 randconfig-x002-08101704
i386                 randconfig-x007-08101704
i386                 randconfig-x004-08101704
mips                                   jz4740
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
