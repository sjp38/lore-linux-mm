Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92E6D6B03A3
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 04:43:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i15so2605250wmf.19
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 01:43:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si11253039wmc.94.2017.04.10.01.43.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 01:43:29 -0700 (PDT)
Date: Mon, 10 Apr 2017 10:43:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [HMM 10/16] mm/hmm/mirror: helper to snapshot CPU page table v2
Message-ID: <20170410084326.GB4625@dhcp22.suse.cz>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-11-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405204026.3940-11-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

There are more for alpha allmodconfig

=== Config /home/mhocko/work/build-test/configs/alpha/allmodconfig
mm/hmm.c: In function 'hmm_vma_walk_pmd':
mm/hmm.c:370:4: error: implicit declaration of function 'pmd_pfn' [-Werror=implicit-function-declaration]
    unsigned long pfn = pmd_pfn(pmd) + pte_index(addr);
    ^
mm/hmm.c:370:4: error: implicit declaration of function 'pte_index' [-Werror=implicit-function-declaration]
mm/hmm.c: In function 'hmm_devmem_radix_release':
mm/hmm.c:784:30: error: 'PA_SECTION_SHIFT' undeclared (first use in this function)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
                              ^
mm/hmm.c:790:36: note: in expansion of macro 'SECTION_SIZE'
  align_start = resource->start & ~(SECTION_SIZE - 1);
                                    ^
mm/hmm.c:784:30: note: each undeclared identifier is reported only once for each function it appears in
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
                              ^
mm/hmm.c:790:36: note: in expansion of macro 'SECTION_SIZE'
  align_start = resource->start & ~(SECTION_SIZE - 1);
                                    ^
mm/hmm.c: In function 'hmm_devmem_release':
mm/hmm.c:784:30: error: 'PA_SECTION_SHIFT' undeclared (first use in this function)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
                              ^
mm/hmm.c:812:36: note: in expansion of macro 'SECTION_SIZE'
  align_start = resource->start & ~(SECTION_SIZE - 1);
                                    ^
mm/hmm.c:816:2: error: implicit declaration of function 'arch_remove_memory' [-Werror=implicit-function-declaration]
  arch_remove_memory(align_start, align_size, devmem->pagemap.type);
  ^
mm/hmm.c: In function 'hmm_devmem_find':
mm/hmm.c:827:54: error: 'PA_SECTION_SHIFT' undeclared (first use in this function)
  return radix_tree_lookup(&hmm_devmem_radix, phys >> PA_SECTION_SHIFT);
                                                      ^
mm/hmm.c: In function 'hmm_devmem_pages_create':
mm/hmm.c:784:30: error: 'PA_SECTION_SHIFT' undeclared (first use in this function)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
                              ^
mm/hmm.c:838:44: note: in expansion of macro 'SECTION_SIZE'
  align_start = devmem->resource->start & ~(SECTION_SIZE - 1);
                                            ^
In file included from ./include/linux/cache.h:4:0,
                 from ./include/linux/printk.h:8,
                 from ./include/linux/kernel.h:13,
                 from ./include/asm-generic/bug.h:13,
                 from ./arch/alpha/include/asm/bug.h:22,
                 from ./include/linux/bug.h:4,
                 from ./include/linux/mmdebug.h:4,
                 from ./include/linux/mm.h:8,
                 from mm/hmm.c:20:
mm/hmm.c: In function 'hmm_devmem_add':
mm/hmm.c:784:30: error: 'PA_SECTION_SHIFT' undeclared (first use in this function)
 #define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
                              ^
./include/uapi/linux/kernel.h:10:47: note: in definition of macro '__ALIGN_KERNEL_MASK'
 #define __ALIGN_KERNEL_MASK(x, mask) (((x) + (mask)) & ~(mask))
                                               ^
./include/linux/kernel.h:49:22: note: in expansion of macro '__ALIGN_KERNEL'
 #define ALIGN(x, a)  __ALIGN_KERNEL((x), (a))
                      ^
mm/hmm.c:982:9: note: in expansion of macro 'ALIGN'
  size = ALIGN(size, SECTION_SIZE);
         ^
mm/hmm.c:982:21: note: in expansion of macro 'SECTION_SIZE'
  size = ALIGN(size, SECTION_SIZE);
                     ^
mm/hmm.c: In function 'hmm_devmem_find':
mm/hmm.c:828:1: warning: control reaches end of non-void function [-Wreturn-type]
 }
 ^
cc1: some warnings being treated as errors
make[1]: *** [mm/hmm.o] Error 1
make[1]: *** Waiting for unfinished jobs....
make: *** [mm] Error 2
make: *** Waiting for unfinished jobs....
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
