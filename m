Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDAE96B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 21:09:13 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id di3so117787998pab.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 18:09:13 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 70si10822615pfk.238.2016.06.03.18.09.12
        for <linux-mm@kvack.org>;
        Fri, 03 Jun 2016 18:09:12 -0700 (PDT)
Date: Sat, 4 Jun 2016 08:55:10 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 86/178] include/asm-generic/tlb.h:133:3: error:
 implicit declaration of function '__tlb_adjust_range'
Message-ID: <201606040808.POQy02Tx%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZPt4rx8FFjLCG7dd"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   2e0066ec9585a5074c8040d639c3c669eb4e905f
commit: d219cbe49c1d86c9ff2be25d9238047e878295b1 [86/178] mm: change the interface for __tlb_remove_page()
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        git checkout d219cbe49c1d86c9ff2be25d9238047e878295b1
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the mmotm/master HEAD 2e0066ec9585a5074c8040d639c3c669eb4e905f builds fine.
      It only hurts bisectibility.

All error/warnings (new ones prefixed by >>):

   In file included from arch/x86/include/asm/tlb.h:16:0,
                    from arch/x86/include/asm/efi.h:7,
                    from arch/x86/kernel/setup.c:81:
   include/asm-generic/tlb.h: In function 'tlb_remove_page':
>> include/asm-generic/tlb.h:133:3: error: implicit declaration of function '__tlb_adjust_range' [-Werror=implicit-function-declaration]
      __tlb_adjust_range(tlb, tlb->addr);
      ^~~~~~~~~~~~~~~~~~
   include/asm-generic/tlb.h: At top level:
>> include/asm-generic/tlb.h:138:20: warning: conflicting types for '__tlb_adjust_range'
    static inline void __tlb_adjust_range(struct mmu_gather *tlb,
                       ^~~~~~~~~~~~~~~~~~
>> include/asm-generic/tlb.h:138:20: error: static declaration of '__tlb_adjust_range' follows non-static declaration
   include/asm-generic/tlb.h:133:3: note: previous implicit declaration of '__tlb_adjust_range' was here
      __tlb_adjust_range(tlb, tlb->addr);
      ^~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/__tlb_adjust_range +133 include/asm-generic/tlb.h

   127	 *	required.
   128	 */
   129	static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
   130	{
   131		if (__tlb_remove_page(tlb, page)) {
   132			tlb_flush_mmu(tlb);
 > 133			__tlb_adjust_range(tlb, tlb->addr);
   134			__tlb_remove_page(tlb, page);
   135		}
   136	}
   137	
 > 138	static inline void __tlb_adjust_range(struct mmu_gather *tlb,
   139					      unsigned long address)
   140	{
   141		tlb->start = min(tlb->start, address);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--ZPt4rx8FFjLCG7dd
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
8Og60SXzOrim9LQsAfgPa3usCKxZAAA=

--ZPt4rx8FFjLCG7dd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
