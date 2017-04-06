Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5716B03DA
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 21:25:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r129so21109451pgr.18
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 18:25:50 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j185si78209pge.320.2017.04.05.18.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 18:25:49 -0700 (PDT)
Date: Thu, 6 Apr 2017 09:25:32 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 6/9] mm: rmap: Use correct helper when poisoning
 hugepages
Message-ID: <201704060916.o3JFLNRt%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Content-Disposition: inline
In-Reply-To: <20170405133722.6406-7-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: kbuild-all@01.org, catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org, mark.rutland@arm.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, tbaicar@codeaurora.org, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, steve.capper@arm.com


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Punit,

[auto build test ERROR on arm64/for-next/core]
[also build test ERROR on v4.11-rc5 next-20170405]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Punit-Agrawal/Support-swap-entries-for-contiguous-pte-hugepages/20170406-090327
base:   https://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git for-next/core
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/rmap.c: In function 'try_to_unmap_one':
>> mm/rmap.c:1393:5: error: implicit declaration of function 'set_huge_swap_pte_at' [-Werror=implicit-function-declaration]
        set_huge_swap_pte_at(mm, address,
        ^~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/set_huge_swap_pte_at +1393 mm/rmap.c

  1387	
  1388			if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
  1389				pteval = swp_entry_to_pte(make_hwpoison_entry(subpage));
  1390				if (PageHuge(page)) {
  1391					int nr = 1 << compound_order(page);
  1392					hugetlb_count_sub(nr, mm);
> 1393					set_huge_swap_pte_at(mm, address,
  1394							     pvmw.pte, pteval,
  1395							     vma_mmu_pagesize(vma));
  1396				} else {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--FCuugMFkClbJLl1L
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--FCuugMFkClbJLl1L--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
