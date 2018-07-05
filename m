Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9A816B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 23:31:47 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bf1-v6so1044128plb.2
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 20:31:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u8-v6si5101594pfl.87.2018.07.04.20.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 20:31:46 -0700 (PDT)
Date: Thu, 5 Jul 2018 11:31:08 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v5 07/11] filesystem-dax: Introduce
 dax_lock_mapping_entry()
Message-ID: <201807050930.1WGGXKLa%fengguang.wu@intel.com>
References: <153074046078.27838.5465590228767136915.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="d6Gm4EdcadzBjdND"
Content-Disposition: inline
In-Reply-To: <153074046078.27838.5465590228767136915.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: kbuild-all@01.org, linux-nvdimm@lists.01.org, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, ross.zwisler@linux.intel.com


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dan,

I love your patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.18-rc3]
[cannot apply to next-20180704]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Dan-Williams/device-dax-Convert-to-vmf_insert_mixed-and-vm_fault_t/20180705-075150
config: openrisc-or1ksim_defconfig (attached as .config)
compiler: or1k-linux-gcc (GCC) 6.0.0 20160327 (experimental)
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

All error/warnings (new ones prefixed by >>):

   In file included from include/linux/mempolicy.h:11:0,
                    from init/main.c:56:
   include/linux/dax.h: In function 'dax_lock_mapping_entry':
   include/linux/dax.h:128:15: error: 'page' redeclared as different kind of symbol
     struct page *page = pfn_to_page(pfn);
                  ^~~~
   include/linux/dax.h:126:56: note: previous definition of 'page' was here
    static inline bool dax_lock_mapping_entry(struct page *page)
                                                           ^~~~
   In file included from arch/openrisc/include/asm/page.h:98:0,
                    from arch/openrisc/include/asm/processor.h:23,
                    from arch/openrisc/include/asm/thread_info.h:26,
                    from include/linux/thread_info.h:38,
                    from include/asm-generic/preempt.h:5,
                    from ./arch/openrisc/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:81,
                    from include/linux/spinlock.h:51,
                    from include/linux/seqlock.h:36,
                    from include/linux/time.h:6,
                    from include/linux/stat.h:19,
                    from include/linux/module.h:10,
                    from init/main.c:16:
>> include/linux/dax.h:128:34: error: 'pfn' undeclared (first use in this function)
     struct page *page = pfn_to_page(pfn);
                                     ^
   include/asm-generic/memory_model.h:33:41: note: in definition of macro '__pfn_to_page'
    #define __pfn_to_page(pfn) (mem_map + ((pfn) - ARCH_PFN_OFFSET))
                                            ^~~
>> include/linux/dax.h:128:22: note: in expansion of macro 'pfn_to_page'
     struct page *page = pfn_to_page(pfn);
                         ^~~~~~~~~~~
   include/linux/dax.h:128:34: note: each undeclared identifier is reported only once for each function it appears in
     struct page *page = pfn_to_page(pfn);
                                     ^
   include/asm-generic/memory_model.h:33:41: note: in definition of macro '__pfn_to_page'
    #define __pfn_to_page(pfn) (mem_map + ((pfn) - ARCH_PFN_OFFSET))
                                            ^~~
>> include/linux/dax.h:128:22: note: in expansion of macro 'pfn_to_page'
     struct page *page = pfn_to_page(pfn);
                         ^~~~~~~~~~~
   In file included from include/linux/mempolicy.h:11:0,
                    from init/main.c:56:
   include/linux/dax.h: In function 'dax_lock_page':
   include/linux/dax.h:141:1: warning: no return statement in function returning non-void [-Wreturn-type]
    }
    ^

vim +/pfn +128 include/linux/dax.h

   124	
   125	
   126	static inline bool dax_lock_mapping_entry(struct page *page)
   127	{
 > 128		struct page *page = pfn_to_page(pfn);
   129	
   130		if (IS_DAX(page->mapping->host))
   131			return true;
   132		return false;
   133	}
   134	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--d6Gm4EdcadzBjdND
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--d6Gm4EdcadzBjdND--
