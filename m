Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6F6A6B0005
	for <linux-mm@kvack.org>; Sun, 24 Jul 2016 17:32:54 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id q2so301108809pap.1
        for <linux-mm@kvack.org>; Sun, 24 Jul 2016 14:32:54 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q72si29681998pfj.148.2016.07.24.14.32.53
        for <linux-mm@kvack.org>;
        Sun, 24 Jul 2016 14:32:54 -0700 (PDT)
Date: Mon, 25 Jul 2016 05:31:33 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 11825/12329] include/asm-generic/tlb.h:133:3:
 error: implicit declaration of function '__tlb_adjust_range'
Message-ID: <201607250530.R5iUcOan%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   6f9bfbf3e7da5b1038f3785fc3511c140e190aae
commit: f2d460300a2565ff4d818d14c0554ec03bbd11e3 [11825/12329] mm: change the interface for __tlb_remove_page()
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        git checkout f2d460300a2565ff4d818d14c0554ec03bbd11e3
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-next/master HEAD 6f9bfbf3e7da5b1038f3785fc3511c140e190aae builds fine.
      It may have been fixed somewhere.

All errors (new ones prefixed by >>):

   In file included from arch/x86/include/asm/tlb.h:16:0,
                    from arch/x86/include/asm/efi.h:7,
                    from arch/x86/kernel/setup.c:81:
   include/asm-generic/tlb.h: In function 'tlb_remove_page':
>> include/asm-generic/tlb.h:133:3: error: implicit declaration of function '__tlb_adjust_range' [-Werror=implicit-function-declaration]
      __tlb_adjust_range(tlb, tlb->addr);
      ^~~~~~~~~~~~~~~~~~
   include/asm-generic/tlb.h: At top level:
   include/asm-generic/tlb.h:138:20: warning: conflicting types for '__tlb_adjust_range'
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

--AqsLC8rIMeq19msA
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
wZgyUlgC8B+jHAwAwlkAAA==

--AqsLC8rIMeq19msA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
