Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE6488E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 22:36:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 11-v6so73462pgd.1
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 19:36:19 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q16-v6si24844568pgm.185.2018.09.20.19.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 19:36:17 -0700 (PDT)
Date: Fri, 21 Sep 2018 10:34:44 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH 6/7] mm/gup: Combine parameters into struct
Message-ID: <201809211027.xFW3I0Gz%fengguang.wu@intel.com>
References: <20180919210250.28858-7-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Content-Disposition: inline
In-Reply-To: <20180919210250.28858-7-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Keith,

I love your patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.19-rc4 next-20180920]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Keith-Busch/mm-faster-get-user-pages/20180920-184931
config: sh-rsk7201_defconfig (attached as .config)
compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=sh 

All warnings (new ones prefixed by >>):

   In file included from include/linux/mm.h:506:0,
                    from arch/sh/kernel/asm-offsets.c:14:
>> include/linux/huge_mm.h:344:53: warning: 'struct gup_context' declared inside parameter list will not be visible outside of this definition or declaration
    static inline struct page *follow_devmap_pmd(struct gup_context *ctx, pmd_t *pmd)
                                                        ^~~~~~~~~~~
   include/linux/huge_mm.h:349:53: warning: 'struct gup_context' declared inside parameter list will not be visible outside of this definition or declaration
    static inline struct page *follow_devmap_pud(struct gup_context *ctx, pud_t *pud)
                                                        ^~~~~~~~~~~
--
   In file included from include/linux/mm.h:506:0,
                    from arch/sh/kernel/asm-offsets.c:14:
>> include/linux/huge_mm.h:344:53: warning: 'struct gup_context' declared inside parameter list will not be visible outside of this definition or declaration
    static inline struct page *follow_devmap_pmd(struct gup_context *ctx, pmd_t *pmd)
                                                        ^~~~~~~~~~~
   include/linux/huge_mm.h:349:53: warning: 'struct gup_context' declared inside parameter list will not be visible outside of this definition or declaration
    static inline struct page *follow_devmap_pud(struct gup_context *ctx, pud_t *pud)
                                                        ^~~~~~~~~~~
   <stdin>:1317:2: warning: #warning syscall pkey_mprotect not implemented [-Wcpp]
   <stdin>:1320:2: warning: #warning syscall pkey_alloc not implemented [-Wcpp]
   <stdin>:1323:2: warning: #warning syscall pkey_free not implemented [-Wcpp]
   <stdin>:1326:2: warning: #warning syscall statx not implemented [-Wcpp]
   <stdin>:1332:2: warning: #warning syscall io_pgetevents not implemented [-Wcpp]
   <stdin>:1335:2: warning: #warning syscall rseq not implemented [-Wcpp]

vim +344 include/linux/huge_mm.h

   343	
 > 344	static inline struct page *follow_devmap_pmd(struct gup_context *ctx, pmd_t *pmd)
   345	{
   346		return NULL;
   347	}
   348	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--x+6KMIRAuhnl3hBn
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--x+6KMIRAuhnl3hBn--
