Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B6FC280730
	for <linux-mm@kvack.org>; Tue,  9 May 2017 12:00:41 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x14so2743551pgc.10
        for <linux-mm@kvack.org>; Tue, 09 May 2017 09:00:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l193si314850pga.7.2017.05.09.09.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 09:00:40 -0700 (PDT)
Date: Tue, 9 May 2017 23:59:55 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm, vmalloc: fix vmalloc users tracking properly
Message-ID: <201705092345.OV9tGwwX%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="d6Gm4EdcadzBjdND"
Content-Disposition: inline
In-Reply-To: <20170509144108.31910-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kbuild-all@01.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tobias Klauser <tklauser@distanz.ch>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Michal,

[auto build test ERROR on mmotm/master]
[also build test ERROR on next-20170509]
[cannot apply to v4.11]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-vmalloc-fix-vmalloc-users-tracking-properly/20170509-224536
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: c6x-evmc6678_defconfig (attached as .config)
compiler: c6x-elf-gcc (GCC) 6.2.0
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=c6x 

All errors (new ones prefixed by >>):

   mm/nommu.c:51:5: sparse: symbol 'sysctl_nr_trim_pages' was not declared. Should it be static?
   mm/nommu.c:52:5: sparse: symbol 'heap_stack_gap' was not declared. Should it be static?
   mm/nommu.c:63:35: sparse: symbol 'generic_file_vm_ops' was not declared. Should it be static?
   mm/nommu.c:240:6: sparse: symbol '__vmalloc_node_flags' was not declared. Should it be static?
   mm/nommu.c:1175:48: sparse: incorrect type in argument 2 (different address spaces)
   mm/nommu.c:1175:48:    expected char [noderef] <asn:1>*<noident>
   mm/nommu.c:1175:48:    got void *[assigned] base
   mm/nommu.c:1790:15: sparse: symbol 'arch_get_unmapped_area' was not declared. Should it be static?
   mm/nommu.c:638:9: sparse: context imbalance in '__put_nommu_region' - wrong count at exit
   mm/nommu.c:659:13: sparse: context imbalance in 'put_nommu_region' - unexpected unlock
   In file included from include/asm-generic/io.h:767:0,
                    from ./arch/c6x/include/generated/asm/io.h:1,
                    from include/linux/io.h:25,
                    from include/linux/irq.h:24,
                    from include/asm-generic/hardirq.h:12,
                    from arch/c6x/include/asm/hardirq.h:18,
                    from include/linux/hardirq.h:8,
                    from include/linux/memcontrol.h:24,
                    from include/linux/swap.h:8,
                    from mm/nommu.c:23:
   include/linux/vmalloc.h:85:21: error: conflicting types for '__vmalloc_node_flags_caller'
    static inline void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags, void* caller)
                        ^~~~~~~~~~~~~~~~~~~~~~~~~~~
   include/linux/vmalloc.h:84:14: note: previous declaration of '__vmalloc_node_flags_caller' was here
    extern void *__vmalloc_node_flags_caller(unsigned long size, int node, gfp_t flags);
                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~
   include/linux/vmalloc.h: In function '__vmalloc_node_flags_caller':
   include/linux/vmalloc.h:87:9: error: implicit declaration of function '__vmalloc_node_flags' [-Werror=implicit-function-declaration]
     return __vmalloc_node_flags(size, node, flags);
            ^~~~~~~~~~~~~~~~~~~~
   include/linux/vmalloc.h:87:9: warning: return makes pointer from integer without a cast [-Wint-conversion]
     return __vmalloc_node_flags(size, node, flags);
            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   mm/nommu.c: At top level:
>> mm/nommu.c:240:7: error: conflicting types for '__vmalloc_node_flags'
    void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags)
          ^~~~~~~~~~~~~~~~~~~~
   In file included from include/asm-generic/io.h:767:0,
                    from ./arch/c6x/include/generated/asm/io.h:1,
                    from include/linux/io.h:25,
                    from include/linux/irq.h:24,
                    from include/asm-generic/hardirq.h:12,
                    from arch/c6x/include/asm/hardirq.h:18,
                    from include/linux/hardirq.h:8,
                    from include/linux/memcontrol.h:24,
                    from include/linux/swap.h:8,
                    from mm/nommu.c:23:
   include/linux/vmalloc.h:87:9: note: previous implicit declaration of '__vmalloc_node_flags' was here
     return __vmalloc_node_flags(size, node, flags);
            ^~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/__vmalloc_node_flags +240 mm/nommu.c

8518609d Robert P. J. Day 2007-10-19  234  	 * returns only a logical address.
^1da177e Linus Torvalds   2005-04-16  235  	 */
84097518 Nick Piggin      2006-03-22  236  	return kmalloc(size, (gfp_mask | __GFP_COMP) & ~__GFP_HIGHMEM);
^1da177e Linus Torvalds   2005-04-16  237  }
b5073173 Paul Mundt       2007-07-21  238  EXPORT_SYMBOL(__vmalloc);
^1da177e Linus Torvalds   2005-04-16  239  
c7e6abdb Michal Hocko     2017-05-03 @240  void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags)
c7e6abdb Michal Hocko     2017-05-03  241  {
c7e6abdb Michal Hocko     2017-05-03  242  	return __vmalloc(size, flags, PAGE_KERNEL);
c7e6abdb Michal Hocko     2017-05-03  243  }

:::::: The code at line 240 was first introduced by commit
:::::: c7e6abdbe12a86cfa1bdba2bd3e9f5fdb1cb175b mm: introduce kv[mz]alloc helpers

:::::: TO: Michal Hocko <mhocko@suse.com>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--d6Gm4EdcadzBjdND
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--d6Gm4EdcadzBjdND--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
