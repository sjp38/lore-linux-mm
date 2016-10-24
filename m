Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4CC6B025E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 07:31:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i85so121766080pfa.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 04:31:46 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w20si14918821pgj.165.2016.10.24.04.31.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 04:31:45 -0700 (PDT)
Date: Mon, 24 Oct 2016 19:31:11 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master] BUILD REGRESSION
 ce571494dee293003b31f7e2a15cc9819649ba05
Message-ID: <580df0ff.1eVKynH5QgM0p2vM%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
ce571494dee293003b31f7e2a15cc9819649ba05  Add linux-next specific files for 20161024

drivers/gpu/drm/i915/gvt/cmd_parser.c:722:13: error: cast to pointer from integer of different size [-Werror=int-to-pointer-cast]
drivers/gpu/drm/i915/gvt/cmd_parser.c:722:23: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
drivers/gpu/drm/i915/gvt/cmd_parser.c:927:35: error: left shift count >= width of type [-Werror=shift-count-overflow]
drivers/gpu/drm/i915/gvt/execlist.c:367:38: error: left shift count >= width of type [-Werror=shift-count-overflow]
drivers/gpu/drm/i915/gvt/gtt.c:1945:47: error: cast from pointer to integer of different size [-Werror=pointer-to-int-cast]
drivers/gpu/drm/i915/gvt/gtt.c:277:28: error: left shift count >= width of type [-Werror=shift-count-overflow]
drivers/gpu/drm/i915/gvt/gtt.c:436:44: error: right shift count >= width of type [-Werror=shift-count-overflow]
(.text+0x32f964): undefined reference to `__umoddi3'

Error ids grouped by kconfigs:

recent_errors
a??a??a?? i386-randconfig-c0-10241534
a??A A  a??a??a?? (.text):undefined-reference-to-__umoddi3
a??a??a?? i386-randconfig-x009-201643
    a??a??a?? drivers-gpu-drm-i915-gvt-cmd_parser.c:error:cast-from-pointer-to-integer-of-different-size
    a??a??a?? drivers-gpu-drm-i915-gvt-cmd_parser.c:error:cast-to-pointer-from-integer-of-different-size
    a??a??a?? drivers-gpu-drm-i915-gvt-cmd_parser.c:error:left-shift-count-width-of-type
    a??a??a?? drivers-gpu-drm-i915-gvt-execlist.c:error:left-shift-count-width-of-type
    a??a??a?? drivers-gpu-drm-i915-gvt-gtt.c:error:cast-from-pointer-to-integer-of-different-size
    a??a??a?? drivers-gpu-drm-i915-gvt-gtt.c:error:left-shift-count-width-of-type
    a??a??a?? drivers-gpu-drm-i915-gvt-gtt.c:error:right-shift-count-width-of-type

elapsed time: 242m

configs tested: 145

i386                   randconfig-a0-10240424
x86_64                 randconfig-a0-10241635
x86_64                             acpi-redef
x86_64                                nfsroot
sh                   sh7770_generic_defconfig
mn10300                          alldefconfig
i386                   randconfig-c0-10241534
i386                   randconfig-c0-10241719
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
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
c6x                        evmc6678_defconfig
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
nios2                         10m50_defconfig
h8300                    h8300h-sim_defconfig
x86_64                 randconfig-x014-201643
x86_64                 randconfig-x011-201643
x86_64                 randconfig-x017-201643
x86_64                 randconfig-x015-201643
x86_64                 randconfig-x012-201643
x86_64                 randconfig-x018-201643
x86_64                 randconfig-x019-201643
x86_64                 randconfig-x013-201643
x86_64                 randconfig-x010-201643
x86_64                 randconfig-x016-201643
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
i386                     randconfig-s0-201643
i386                     randconfig-s1-201643
x86_64                 randconfig-s2-10241550
x86_64                 randconfig-s0-10241550
x86_64                 randconfig-s1-10241550
x86_64                 randconfig-s1-10241642
x86_64                 randconfig-s0-10241642
x86_64                 randconfig-s2-10241642
x86_64                           allmodconfig
x86_64                 randconfig-s5-10241558
x86_64                 randconfig-s4-10241558
x86_64                 randconfig-s3-10241558
x86_64                 randconfig-s5-10241635
x86_64                 randconfig-s3-10241635
x86_64                 randconfig-s4-10241635
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
avr32                      atngw100_defconfig
frv                                 defconfig
avr32                     atstk1006_defconfig
tile                         tilegx_defconfig
x86_64                   randconfig-i0-201643
i386                   randconfig-b0-10241650
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
i386                     randconfig-i1-201643
i386                     randconfig-i0-201643
powerpc64                        alldefconfig
ia64                          tiger_defconfig
arm                         em_x270_defconfig
x86_64                 randconfig-u0-10241603
x86_64                 randconfig-u0-10241652
powerpc               mpc85xx_basic_defconfig
x86_64                 randconfig-n0-10241527
x86_64                 randconfig-n0-10241557
x86_64                 randconfig-n0-10241642
x86_64                 randconfig-n0-10241730
i386                   randconfig-x014-201643
i386                   randconfig-x019-201643
i386                   randconfig-x017-201643
i386                   randconfig-x018-201643
i386                   randconfig-x015-201643
i386                   randconfig-x016-201643
i386                   randconfig-x012-201643
i386                   randconfig-x013-201643
i386                   randconfig-x011-201643
i386                   randconfig-x010-201643
i386                     randconfig-n0-201643
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
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
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
x86_64                 randconfig-x001-201643
x86_64                 randconfig-x008-201643
x86_64                 randconfig-x009-201643
x86_64                 randconfig-x000-201643
x86_64                 randconfig-x003-201643
x86_64                 randconfig-x005-201643
x86_64                 randconfig-x007-201643
x86_64                 randconfig-x002-201643
x86_64                 randconfig-x004-201643
x86_64                 randconfig-x006-201643
x86_64                                  kexec
x86_64                                   rhel
x86_64                               rhel-7.2
i386                     randconfig-r0-201643
i386                             allmodconfig
i386                   randconfig-x004-201643
i386                   randconfig-x006-201643
i386                   randconfig-x007-201643
i386                   randconfig-x003-201643
i386                   randconfig-x008-201643
i386                   randconfig-x000-201643
i386                   randconfig-x002-201643
i386                   randconfig-x009-201643
i386                   randconfig-x001-201643
i386                   randconfig-x005-201643
mips                                   jz4740
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
i386                   randconfig-x0-10241604

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
