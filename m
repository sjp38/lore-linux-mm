Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA586B0292
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 09:26:20 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id m4so3724680pgc.23
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 06:26:20 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id m12si13834994pgn.415.2017.11.22.06.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 06:26:18 -0800 (PST)
Date: Wed, 22 Nov 2017 22:25:31 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master] BUILD REGRESSION
 f5ef1cb6700e8b570adae945b1e0bd4ab95d8a26
Message-ID: <5a1588db.3mvsfOfqb5sFz4uO%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

tree/branch: git://git.cmpxchg.org/linux-mmotm.git  master
branch HEAD: f5ef1cb6700e8b570adae945b1e0bd4ab95d8a26  pci: test for unexpectedly disabled bridges

Regressions in current branch:

arch/x86/kvm/mmu.c:5485:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers//android/binder_alloc.c:1008:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers/gpu/drm/ttm/ttm_page_alloc.c:451:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers/gpu/drm/ttm/ttm_page_alloc_dma.c:1185:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers/md/bcache/btree.c:810:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers/md/dm-bufio.c:1752:19: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers/md/dm-bufio.c:1752:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers/staging/android/ashmem.c:865:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
drivers/staging/android/ion/ion_heap.c:315:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
fs/cramfs/inode.c:641: undefined reference to `mtd_point'
fs/cramfs/inode.c:658: undefined reference to `mtd_unpoint'
fs/cramfs/inode.c:959: undefined reference to `mount_mtd'
fs/quota/dquot.c:2988:19: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
fs//quota/dquot.c:2988:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
fs/quota/dquot.c:2988:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]
fs/super.c:521:2: warning: ignoring return value of 'register_shrinker', declared with attribute warn_unused_result [-Wunused-result]

Error ids grouped by kconfigs:

recent_errors
a??a??a?? arm64-defconfig
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? arm-at91_dt_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? arm-exynos_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? arm-multi_v5_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? arm-multi_v7_defconfig
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? arm-sunxi_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? i386-allmodconfig
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-bcache-btree.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? i386-randconfig-i0-201747
a??A A  a??a??a?? drivers-md-bcache-btree.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? i386-randconfig-i1-201747
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-cramfs-inode.c:undefined-reference-to-mount_mtd
a??A A  a??a??a?? fs-cramfs-inode.c:undefined-reference-to-mtd_point
a??A A  a??a??a?? fs-cramfs-inode.c:undefined-reference-to-mtd_unpoint
a??a??a?? i386-randconfig-n0-201747
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? ia64-defconfig
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? m32r-m32104ut_defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? m32r-mappi3.smp_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? m32r-opsput_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? m32r-usrv_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? m68k-multi_defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? m68k-sun3_defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? microblaze-mmu_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? microblaze-nommu_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? nios2-10m50_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? parisc-c3000_defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? powerpc-defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? powerpc-ppc64_defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? s390-default_defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? score-spct6600_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? sparc64-defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? sparc-defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? tile-tilegx_defconfig
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? um-i386_defconfig
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? um-x86_64_defconfig
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? x86_64-allmodconfig
a??A A  a??a??a?? drivers-android-binder_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-bcache-btree.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-staging-android-ashmem.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-staging-android-ion-ion_heap.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? x86_64-allyesdebian
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? x86_64-kexec
a??A A  a??a??a?? arch-x86-kvm-mmu.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? x86_64-nfsroot
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? x86_64-rhel
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? x86_64-rhel-7.2
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-gpu-drm-ttm-ttm_page_alloc_dma.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? drivers-md-dm-bufio.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??A A  a??a??a?? fs-quota-dquot.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? xtensa-common_defconfig
a??A A  a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result
a??a??a?? xtensa-iss_defconfig
    a??a??a?? fs-super.c:warning:ignoring-return-value-of-register_shrinker-declared-with-attribute-warn_unused_result

elapsed time: 725m

configs tested: 131

parisc                        c3000_defconfig
parisc                         b180_defconfig
parisc                              defconfig
alpha                               defconfig
parisc                            allnoconfig
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
i386                   randconfig-x019-201747
i386                   randconfig-x015-201747
i386                   randconfig-x014-201747
i386                   randconfig-x013-201747
i386                   randconfig-x011-201747
i386                   randconfig-x018-201747
i386                   randconfig-x010-201747
i386                   randconfig-x012-201747
i386                   randconfig-x017-201747
i386                   randconfig-x016-201747
microblaze                      mmu_defconfig
microblaze                    nommu_defconfig
i386                     randconfig-n0-201747
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
i386                     randconfig-i1-201747
i386                     randconfig-i0-201747
x86_64                 randconfig-x018-201747
x86_64                 randconfig-x011-201747
x86_64                 randconfig-x013-201747
x86_64                 randconfig-x019-201747
x86_64                 randconfig-x012-201747
x86_64                 randconfig-x017-201747
x86_64                 randconfig-x016-201747
x86_64                 randconfig-x014-201747
x86_64                 randconfig-x015-201747
x86_64                 randconfig-x010-201747
i386                     randconfig-a0-201747
i386                     randconfig-a1-201747
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
i386                     randconfig-s0-201747
i386                     randconfig-s1-201747
i386                               tinyconfig
x86_64                   randconfig-i0-201747
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
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
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
frv                                 defconfig
tile                         tilegx_defconfig
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
x86_64                           allmodconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                         64r6el_defconfig
mips                           32r2_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
x86_64                                  kexec
x86_64                                   rhel
x86_64                               rhel-7.2
cris                 etrax-100lx_v2_defconfig
blackfin                  TCM-BF537_defconfig
blackfin            BF561-EZKIT-SMP_defconfig
blackfin                BF533-EZKIT_defconfig
blackfin                BF526-EZBRD_defconfig
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
i386                   randconfig-x074-201747
i386                   randconfig-x077-201747
i386                   randconfig-x076-201747
i386                   randconfig-x071-201747
i386                   randconfig-x073-201747
i386                   randconfig-x078-201747
i386                   randconfig-x072-201747
i386                   randconfig-x079-201747
i386                   randconfig-x070-201747
i386                   randconfig-x075-201747
x86_64                 randconfig-x000-201747
x86_64                 randconfig-x001-201747
x86_64                 randconfig-x008-201747
x86_64                 randconfig-x004-201747
x86_64                 randconfig-x005-201747
x86_64                 randconfig-x007-201747
x86_64                 randconfig-x006-201747
x86_64                 randconfig-x003-201747
x86_64                 randconfig-x009-201747
x86_64                 randconfig-x002-201747
i386                             allmodconfig
i386                   randconfig-x001-201747
i386                   randconfig-x008-201747
i386                   randconfig-x002-201747
i386                   randconfig-x003-201747
i386                   randconfig-x004-201747
i386                   randconfig-x006-201747
i386                   randconfig-x007-201747
i386                   randconfig-x005-201747
i386                   randconfig-x000-201747
i386                   randconfig-x009-201747

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
