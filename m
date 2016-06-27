Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F202C6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 11:41:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so407616143pfa.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 08:41:26 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id h82si27232024pfd.43.2016.06.27.08.41.25
        for <linux-mm@kvack.org>;
        Mon, 27 Jun 2016 08:41:25 -0700 (PDT)
Date: Mon, 27 Jun 2016 23:40:40 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 6012/6704] include/asm-generic/tlb.h:133:3:
 error: implicit declaration of function '__tlb_adjust_range'
Message-ID: <201606272339.TRfrgkTK%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="6c2NcOVqGQ03X4Wi"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   aa20c9aa490a2b73f97bceae9828ccfaa9cb1b4f
commit: dbea3efdd0c92695c1697b6a20e5b4cff09a3312 [6012/6704] mm: change the interface for __tlb_remove_page()
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        git checkout dbea3efdd0c92695c1697b6a20e5b4cff09a3312
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-next/master HEAD aa20c9aa490a2b73f97bceae9828ccfaa9cb1b4f builds fine.
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

--6c2NcOVqGQ03X4Wi
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--6c2NcOVqGQ03X4Wi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
