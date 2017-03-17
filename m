Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27ACF6B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:36:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o126so116850997pfb.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 20:36:19 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 1si5131369pfg.224.2017.03.16.20.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 20:36:17 -0700 (PDT)
Date: Fri, 17 Mar 2017 11:35:43 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master] BUILD REGRESSION
 8276ddb3c638602509386f1a05f75326dbf5ce09
Message-ID: <58cb598f.2ppM+jJeYceavjwt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

git://git.cmpxchg.org/linux-mmotm.git  master
8276ddb3c638602509386f1a05f75326dbf5ce09  pci: test for unexpectedly disabled bridges

arch/arm64/boot/dts/allwinner/sun50i-h5.dtsi:43:28: fatal error: sunxi-h3-h5.dtsi: No such file or directory
dma-mapping.c:(.text+0x2): undefined reference to `bad_dma_ops'
drivers/crypto/cavium/zip/zip_main.c:489:18: warning: format '%ld' expects argument of type 'long int', but argument 4 has type 'long long int' [-Wformat=]
include/asm-generic/atomic-instrumented.h:70: undefined reference to `__arch_atomic_add_unless'
include/linux/kernel.h:49:22: note: in expansion of macro '__ALIGN_KERNEL'
include/linux/migrate.h:128:32: warning: left shift count >= width of type [-Wshift-count-overflow]
include/linux/migrate.h:137:15: note: in expansion of macro 'MIGRATE_PFN_VALID'
include/linux/migrate.h:139:15: note: in expansion of macro 'MIGRATE_PFN_VALID'
include/linux/migrate.h:139:20: warning: left shift count >= width of type [-Wshift-count-overflow]
include/linux/migrate.h:139:28: note: in expansion of macro 'MIGRATE_PFN_MASK'
include/linux/migrate.h:139:2: warning: left shift count >= width of type
include/linux/migrate.h:139:2: warning: left shift count >= width of type [enabled by default]
include/linux/migrate.h:141:28: note: in expansion of macro 'MIGRATE_PFN_MASK'
include/linux/migrate.h:144:16: note: in expansion of macro 'MIGRATE_PFN_HUGE'
include/linux/migrate.h:144:35: error: 'PMD_SIZE' undeclared (first use in this function)
include/linux/migrate.h:146:16: note: in expansion of macro 'MIGRATE_PFN_HUGE'
include/linux/migrate.h:146:35: error: 'PMD_SIZE' undeclared (first use in this function)
include/linux/migrate.h:146:36: error: 'PMD_SIZE' undeclared (first use in this function)
include/linux/migrate.h:147:1: warning: control reaches end of non-void function [-Wreturn-type]
mm/hmm.c:1002:9: note: in expansion of macro 'ALIGN'
mm/hmm.c:1003:9: note: in expansion of macro 'ALIGN'
mm/hmm.c:1129:15: note: in expansion of macro 'MIGRATE_PFN_ERROR'
mm/hmm.c:1130:15: note: in expansion of macro 'MIGRATE_PFN_ERROR'
mm/hmm.c:331:10: error: implicit declaration of function 'pgd_addr_end' [-Werror=implicit-function-declaration]
mm/hmm.c:332:10: error: implicit declaration of function 'pgd_offset' [-Werror=implicit-function-declaration]
mm/hmm.c:332:8: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
mm/hmm.c:345:10: error: implicit declaration of function 'pmd_addr_end' [-Werror=implicit-function-declaration]
mm/hmm.c:347:7: error: incompatible types when assigning to type 'pmd_t {aka struct <anonymous>}' from type 'int'
mm/hmm.c:347:9: error: implicit declaration of function 'pmd_read_atomic' [-Werror=implicit-function-declaration]
mm/hmm.c:353:7: error: implicit declaration of function 'pmd_trans_huge' [-Werror=implicit-function-declaration]
mm/hmm.c:354:24: error: implicit declaration of function 'pmd_pfn' [-Werror=implicit-function-declaration]
mm/hmm.c:354:39: error: implicit declaration of function 'pte_index' [-Werror=implicit-function-declaration]
mm/hmm.c:357:8: error: implicit declaration of function 'pmd_protnone' [-Werror=implicit-function-declaration]
mm/hmm.c:361:13: error: implicit declaration of function 'pmd_write' [-Werror=implicit-function-declaration]
mm/hmm.c:368:10: error: implicit declaration of function 'pte_offset_map' [-Werror=implicit-function-declaration]
mm/hmm.c:375:8: error: implicit declaration of function 'pte_none' [-Werror=implicit-function-declaration]
mm/hmm.c:381:9: error: implicit declaration of function 'pte_present' [-Werror=implicit-function-declaration]
mm/hmm.c:386:32: error: implicit declaration of function 'pte_pfn' [-Werror=implicit-function-declaration]
mm/hmm.c:387:16: error: implicit declaration of function 'pte_write' [-Werror=implicit-function-declaration]
mm/hmm.c:406:3: error: implicit declaration of function 'pte_unmap' [-Werror=implicit-function-declaration]
mm/hmm.c:441:24: error: implicit declaration of function 'pmd_pfn' [-Werror=implicit-function-declaration]
mm/hmm.c:809:30: error: 'PA_SECTION_SHIFT' undeclared (first use in this function)
mm/hmm.c:810:30: error: 'PA_SECTION_SHIFT' undeclared (first use in this function)
mm/hmm.c:815:36: note: in expansion of macro 'SECTION_SIZE'
mm/hmm.c:816:36: note: in expansion of macro 'SECTION_SIZE'
mm/hmm.c:839:2: error: implicit declaration of function 'arch_remove_memory' [-Werror=implicit-function-declaration]
mm/hmm.c:840:2: error: implicit declaration of function 'arch_remove_memory' [-Werror=implicit-function-declaration]
mm/hmm.c:849:1: warning: control reaches end of non-void function [-Wreturn-type]
mm/hmm.c:850:1: warning: control reaches end of non-void function [-Wreturn-type]
mm/madvise.c:341:4: note: in expansion of macro 'free_swap_and_cache'
mm/migrate.c:2102:38: note: in expansion of macro 'MIGRATE_PFN_HUGE'
mm/migrate.c:2168:11: note: in expansion of macro 'MIGRATE_PFN_VALID'
mm/migrate.c:2168:31: note: in expansion of macro 'MIGRATE_PFN_MIGRATE'
mm/migrate.c:2169:29: note: in expansion of macro 'MIGRATE_PFN_WRITE'
mm/migrate.c:2173:12: note: in expansion of macro 'MIGRATE_PFN_VALID'
mm/migrate.c:2174:5: note: in expansion of macro 'MIGRATE_PFN_DEVICE'
mm/migrate.c:2175:5: note: in expansion of macro 'MIGRATE_PFN_MIGRATE'
mm/migrate.c:2177:14: note: in expansion of macro 'MIGRATE_PFN_WRITE'
mm/migrate.c:2184:5: note: in expansion of macro 'MIGRATE_PFN_DEVICE'
mm/migrate.c:2211:13: note: in expansion of macro 'MIGRATE_PFN_LOCKED'
mm/migrate.c:2266:22: note: in expansion of macro 'MIGRATE_PFN_LOCKED'
mm/migrate.c:2487:14: note: in expansion of macro 'MIGRATE_PFN_HUGE'
mm/shmem.c:646:2: note: in expansion of macro 'free_swap_and_cache'
warning: (HMM_MIRROR && HMM_DEVMEM) selects HMM which has unmet direct dependencies (MMU)

Error ids grouped by kconfigs:

recent_errors
a??a??a?? alpha-allyesconfig
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_pfn
a??a??a?? arm64-allnoconfig
a??A A  a??a??a?? arch-arm64-boot-dts-allwinner-sun50i-h5.dtsi:fatal-error:sunxi-h3-h5.dtsi:No-such-file-or-directory
a??a??a?? arm64-defconfig
a??A A  a??a??a?? arch-arm64-boot-dts-allwinner-sun50i-h5.dtsi:fatal-error:sunxi-h3-h5.dtsi:No-such-file-or-directory
a??a??a?? arm-allnoconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? arm-at91_dt_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-madvise.c:note:in-expansion-of-macro-free_swap_and_cache
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??A A  a??a??a?? mm-shmem.c:note:in-expansion-of-macro-free_swap_and_cache
a??a??a?? arm-efm32_defconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? arm-exynos_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? arm-multi_v5_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? arm-multi_v7_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? arm-shmobile_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? arm-sunxi_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? blackfin-allmodconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:warning:control-reaches-end-of-non-void-function
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pgd_addr_end
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pgd_offset
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_addr_end
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_protnone
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_read_atomic
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_trans_huge
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_write
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pte_index
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pte_none
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pte_offset_map
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pte_pfn
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pte_present
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pte_unmap
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pte_write
a??A A  a??a??a?? mm-hmm.c:error:incompatible-types-when-assigning-to-type-pmd_t-aka-struct-anonymous-from-type-int
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-MIGRATE_PFN_ERROR
a??A A  a??a??a?? mm-hmm.c:warning:assignment-makes-pointer-from-integer-without-a-cast
a??a??a?? blackfin-allyesconfig
a??A A  a??a??a?? include-linux-kernel.h:note:in-expansion-of-macro-__ALIGN_KERNEL
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-arch_remove_memory
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_pfn
a??A A  a??a??a?? mm-hmm.c:error:PA_SECTION_SHIFT-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-ALIGN
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-SECTION_SIZE
a??A A  a??a??a?? mm-hmm.c:warning:control-reaches-end-of-non-void-function
a??a??a?? blackfin-BF526-EZBRD_defconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? blackfin-BF533-EZKIT_defconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? blackfin-BF561-EZKIT-SMP_defconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? blackfin-TCM-BF537_defconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? c6x-evmc6678_defconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? cris-etrax-100lx_v2_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-madvise.c:note:in-expansion-of-macro-free_swap_and_cache
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??A A  a??a??a?? mm-shmem.c:note:in-expansion-of-macro-free_swap_and_cache
a??a??a?? frv-defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? h8300-h8300h-sim_defconfig
a??A A  a??a??a?? include-linux-migrate.h:error:PMD_SIZE-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? i386-allmodconfig
a??A A  a??a??a?? include-linux-kernel.h:note:in-expansion-of-macro-__ALIGN_KERNEL
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-arch_remove_memory
a??A A  a??a??a?? mm-hmm.c:error:PA_SECTION_SHIFT-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-ALIGN
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-MIGRATE_PFN_ERROR
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-SECTION_SIZE
a??A A  a??a??a?? mm-hmm.c:warning:control-reaches-end-of-non-void-function
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? i386-randconfig-i0-201711
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? i386-randconfig-i1-201711
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? i386-randconfig-s0-201711
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-madvise.c:note:in-expansion-of-macro-free_swap_and_cache
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? i386-randconfig-s1-201711
a??A A  a??a??a?? mm-shmem.c:note:in-expansion-of-macro-free_swap_and_cache
a??a??a?? ia64-allmodconfig
a??A A  a??a??a?? include-linux-kernel.h:note:in-expansion-of-macro-__ALIGN_KERNEL
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-arch_remove_memory
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_pfn
a??A A  a??a??a?? mm-hmm.c:error:PA_SECTION_SHIFT-undeclared-(first-use-in-this-function)
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-ALIGN
a??A A  a??a??a?? mm-hmm.c:note:in-expansion-of-macro-SECTION_SIZE
a??A A  a??a??a?? mm-hmm.c:warning:control-reaches-end-of-non-void-function
a??a??a?? ia64-allyesconfig
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_pfn
a??a??a?? m32r-m32104ut_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? m32r-mappi3.smp_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? m32r-opsput_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? m32r-usrv_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? m68k-m5475evb_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? m68k-multi_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? m68k-sun3_defconfig
a??A A  a??a??a?? dma-mapping.c:(.text):undefined-reference-to-bad_dma_ops
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? mips-allnoconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? mips-jz4740
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? mips-malta_kvm_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? mips-txx9
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? mn10300-asb2364_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? nios2-10m50_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? openrisc-or1ksim_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? parisc-allnoconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? parisc-allyesconfig
a??A A  a??a??a?? mm-hmm.c:error:implicit-declaration-of-function-pmd_pfn
a??a??a?? parisc-b180_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? parisc-c3000_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? parisc-defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? powerpc-allnoconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? sh-allmodconfig
a??A A  a??a??a?? warning:(HMM_MIRROR-HMM_DEVMEM)-selects-HMM-which-has-unmet-direct-dependencies-(MMU)
a??a??a?? sh-allnoconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? sh-rsk7269_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? sh-sh7785lcr_32bit_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? sh-titan_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? sparc-defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_DEVICE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_LOCKED
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_MIGRATE
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? mm-migrate.c:note:in-expansion-of-macro-MIGRATE_PFN_WRITE
a??a??a?? um-i386_defconfig
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_HUGE
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_MASK
a??A A  a??a??a?? include-linux-migrate.h:note:in-expansion-of-macro-MIGRATE_PFN_VALID
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? um-x86_64_defconfig
a??A A  a??a??a?? include-asm-generic-atomic-instrumented.h:undefined-reference-to-__arch_atomic_add_unless
a??a??a?? x86_64-allmodconfig
a??A A  a??a??a?? drivers-crypto-cavium-zip-zip_main.c:warning:format-ld-expects-argument-of-type-long-int-but-argument-has-type-long-long-int
a??a??a?? xtensa-common_defconfig
a??A A  a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type
a??a??a?? xtensa-iss_defconfig
    a??a??a?? include-linux-migrate.h:warning:left-shift-count-width-of-type

elapsed time: 204m

configs tested: 129

i386                     randconfig-a0-201711
sh                            titan_defconfig
sh                          rsk7269_defconfig
sh                  sh7785lcr_32bit_defconfig
sh                                allnoconfig
x86_64                           allmodconfig
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
x86_64                 randconfig-x015-201711
x86_64                 randconfig-x012-201711
x86_64                 randconfig-x017-201711
x86_64                 randconfig-x010-201711
x86_64                 randconfig-x018-201711
x86_64                 randconfig-x011-201711
x86_64                 randconfig-x019-201711
x86_64                 randconfig-x014-201711
x86_64                 randconfig-x013-201711
x86_64                 randconfig-x016-201711
i386                              allnoconfig
i386                                defconfig
i386                             alldefconfig
i386                     randconfig-s0-201711
i386                     randconfig-s1-201711
i386                               tinyconfig
mips                                   jz4740
mips                      malta_kvm_defconfig
mips                         64r6el_defconfig
mips                           32r2_defconfig
mips                              allnoconfig
mips                      fuloong2e_defconfig
mips                                     txx9
powerpc                             defconfig
s390                        default_defconfig
powerpc                       ppc64_defconfig
powerpc                           allnoconfig
x86_64                   randconfig-i0-201711
sparc                               defconfig
sparc64                           allnoconfig
sparc64                             defconfig
i386                     randconfig-i0-201711
i386                     randconfig-i1-201711
c6x                        evmc6678_defconfig
xtensa                       common_defconfig
m32r                       m32104ut_defconfig
xtensa                          iss_defconfig
m32r                         opsput_defconfig
m32r                           usrv_defconfig
m32r                     mappi3.smp_defconfig
nios2                         10m50_defconfig
h8300                    h8300h-sim_defconfig
i386                   randconfig-x014-201711
i386                   randconfig-x010-201711
i386                   randconfig-x016-201711
i386                   randconfig-x017-201711
i386                   randconfig-x013-201711
i386                   randconfig-x019-201711
i386                   randconfig-x015-201711
i386                   randconfig-x012-201711
i386                   randconfig-x011-201711
i386                   randconfig-x018-201711
x86_64                                    lkp
x86_64                                   rhel
mn10300                     asb2364_defconfig
openrisc                    or1ksim_defconfig
um                           x86_64_defconfig
um                             i386_defconfig
avr32                      atngw100_defconfig
frv                                 defconfig
avr32                     atstk1006_defconfig
tile                         tilegx_defconfig
m68k                           sun3_defconfig
m68k                          multi_defconfig
m68k                       m5475evb_defconfig
x86_64                 randconfig-x004-201711
x86_64                 randconfig-x009-201711
x86_64                 randconfig-x003-201711
x86_64                 randconfig-x008-201711
x86_64                 randconfig-x002-201711
x86_64                 randconfig-x007-201711
x86_64                 randconfig-x000-201711
x86_64                 randconfig-x005-201711
x86_64                 randconfig-x006-201711
x86_64                 randconfig-x001-201711
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
i386                   randconfig-x077-201711
i386                   randconfig-x070-201711
i386                   randconfig-x073-201711
i386                   randconfig-x076-201711
i386                   randconfig-x072-201711
i386                   randconfig-x078-201711
i386                   randconfig-x074-201711
i386                   randconfig-x075-201711
i386                   randconfig-x079-201711
i386                   randconfig-x071-201711
x86_64                             acpi-redef
x86_64                           allyesdebian
x86_64                                nfsroot
ia64                              allnoconfig
ia64                                defconfig
ia64                             alldefconfig
i386                     randconfig-r0-201711
i386                             allmodconfig
i386                   randconfig-x002-201711
i386                   randconfig-x005-201711
i386                   randconfig-x006-201711
i386                   randconfig-x003-201711
i386                   randconfig-x007-201711
i386                   randconfig-x008-201711
i386                   randconfig-x001-201711
i386                   randconfig-x000-201711
i386                   randconfig-x009-201711
i386                   randconfig-x004-201711

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
