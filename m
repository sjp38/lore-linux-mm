Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4236B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 05:05:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r16so9042878pfg.4
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 02:05:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q5si3819446pgh.39.2016.10.19.02.05.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 02:05:52 -0700 (PDT)
Date: Wed, 19 Oct 2016 17:05:48 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master] BUILD REGRESSION
 ff9a1f89bf4512a0b628792c096aea0eced8b83c
Message-ID: <5807376c.6mP3d3hqW7xPZ4Pp%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
ff9a1f89bf4512a0b628792c096aea0eced8b83c  Add linux-next specific files for 20161019

drivers/gpu/drm/i915/gvt/execlist.c:367:38: error: left shift count >= width of type [-Werror=shift-count-overflow]
drivers/gpu/drm/i915/gvt/execlist.c:501: error: 'drm_gem_object_unreference' is deprecated (declared at drivers/gpu/drm/i915/i915_drv.h:2354)

Error ids grouped by kconfigs:

recent_errors
a??a??a?? i386-randconfig-h0-10191202
a??A A  a??a??a?? drivers-gpu-drm-i915-gvt-execlist.c:error:left-shift-count-width-of-type
a??a??a?? x86_64-randconfig-s0-10191045
    a??a??a?? drivers-gpu-drm-i915-gvt-execlist.c:error:drm_gem_object_unreference-is-deprecated-(declared-at-drivers-gpu-drm-i915-i915_drv.h)

elapsed time: 238m

configs tested: 164

m68k                       m5275evb_defconfig
arm                           tegra_defconfig
h8300                    h8300h-sim_defconfig
i386                     randconfig-a0-201642
x86_64                 randconfig-a0-10191316
x86_64                 randconfig-a0-10191419
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
powerpc                      makalu_defconfig
sh                     magicpanelr2_defconfig
i386                   randconfig-c0-10191342
i386                   randconfig-c0-10191504
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
c6x                        evmc6678_defconfig
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
nios2                         10m50_defconfig
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
avr32            atngw100_evklcd101_defconfig
sh                             shx3_defconfig
cris                              allnoconfig
sh                         microdev_defconfig
x86_64                 randconfig-x014-201642
x86_64                 randconfig-x011-201642
x86_64                 randconfig-x017-201642
x86_64                 randconfig-x015-201642
x86_64                 randconfig-x012-201642
x86_64                 randconfig-x018-201642
x86_64                 randconfig-x019-201642
x86_64                 randconfig-x013-201642
x86_64                 randconfig-x010-201642
x86_64                 randconfig-x016-201642
arm                       omap2plus_defconfig
arm                                    sa1100
i386                     randconfig-s0-201642
i386                     randconfig-s1-201642
x86_64                 randconfig-s0-10191318
x86_64                 randconfig-s2-10191318
x86_64                 randconfig-s1-10191318
x86_64                 randconfig-s2-10191416
x86_64                 randconfig-s1-10191416
x86_64                 randconfig-s0-10191416
x86_64                 randconfig-s4-10191328
x86_64                 randconfig-s3-10191328
x86_64                 randconfig-s5-10191328
x86_64                 randconfig-s4-10191408
x86_64                 randconfig-s5-10191408
x86_64                 randconfig-s3-10191408
x86_64                 randconfig-s3-10191504
x86_64                 randconfig-s4-10191504
x86_64                 randconfig-s5-10191504
x86_64                   randconfig-i0-201642
i386                   randconfig-b0-10191419
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
i386                     randconfig-i1-201642
i386                     randconfig-i0-201642
x86_64                 randconfig-b0-10191321
mips                         bigsur_defconfig
arm                           viper_defconfig
x86_64                 randconfig-u0-10191334
x86_64                 randconfig-u0-10191422
ia64                             allyesconfig
sh                           se7721_defconfig
x86_64                 randconfig-n0-10190827
x86_64                 randconfig-n0-10191521
i386                               tinyconfig
i386                   randconfig-x014-201642
i386                   randconfig-x019-201642
i386                   randconfig-x018-201642
i386                   randconfig-x017-201642
i386                   randconfig-x015-201642
i386                   randconfig-x016-201642
i386                   randconfig-x012-201642
i386                   randconfig-x013-201642
i386                   randconfig-x011-201642
i386                   randconfig-x010-201642
i386                     randconfig-n0-201642
i386                   randconfig-h0-10191337
i386                   randconfig-h1-10191337
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
x86_64                                   rhel
x86_64                 randconfig-h0-10191456
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
avr32                      atngw100_defconfig
frv                                 defconfig
avr32                     atstk1006_defconfig
tile                         tilegx_defconfig
x86_64                 randconfig-n0-10191305
x86_64                 randconfig-n0-10191341
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
x86_64                           allmodconfig
x86_64                 randconfig-x001-201642
x86_64                 randconfig-x008-201642
x86_64                 randconfig-x009-201642
x86_64                 randconfig-x000-201642
x86_64                 randconfig-x003-201642
x86_64                 randconfig-x005-201642
x86_64                 randconfig-x007-201642
x86_64                 randconfig-x002-201642
x86_64                 randconfig-x004-201642
x86_64                 randconfig-x006-201642
i386                     randconfig-r0-201642
x86_64                 randconfig-r0-10191413
i386                             allmodconfig
i386                   randconfig-x004-201642
i386                   randconfig-x006-201642
i386                   randconfig-x007-201642
i386                   randconfig-x003-201642
i386                   randconfig-x008-201642
i386                   randconfig-x000-201642
i386                   randconfig-x009-201642
i386                   randconfig-x002-201642
i386                   randconfig-x001-201642
i386                   randconfig-x005-201642
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
mips                                   jz4740
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
i386                   randconfig-x0-10191333
i386                   randconfig-x0-10191416
i386                   randconfig-x0-10191453

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
