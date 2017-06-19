Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 037CC6B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 13:02:03 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f185so117525237pgc.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 10:02:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g1si9687594plb.271.2017.06.19.10.02.01
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 10:02:01 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: [PATCH v5 0/8] Support for contiguous pte hugepages
Date: Mon, 19 Jun 2017 18:01:37 +0100
Message-Id: <20170619170145.25577-1-punit.agrawal@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com

Hi Andrew,

This is v5 of the patchset to update the hugetlb code to support
contiguous hugepages. Previous version of the patchset can be found at
[0].

The main changes in this version are updating Patch 4 and 7 due to
issues highlighted in the previous postings (ltp and build failure).

Please update the patches in your queue with this version.

Thanks,
Punit

Changes since v4:

* Patch 4 updated to fix arm64 ltp failure (pth_str01, pth_str03) [1]
* Patch 7 update to fix build failure when CONFIG_HUGETLB_PAGE is disabled

[0] https://lkml.org/lkml/2017/5/24/463
[1] https://lkml.org/lkml/2017/6/5/332

Punit Agrawal (5):
  mm, gup: Ensure real head page is ref-counted when using hugepages
  mm/hugetlb: add size parameter to huge_pte_offset()
  mm/hugetlb: Allow architectures to override huge_pte_clear()
  mm/hugetlb: Introduce set_huge_swap_pte_at() helper
  mm: rmap: Use correct helper when poisoning hugepages

Steve Capper (2):
  arm64: hugetlb: Refactor find_num_contig
  arm64: hugetlb: Remove spurious calls to huge_ptep_offset

Will Deacon (1):
  mm, gup: Remove broken VM_BUG_ON_PAGE compound check for hugepages

 arch/arm64/mm/hugetlbpage.c     | 53 +++++++++++++++++------------------------
 arch/ia64/mm/hugetlbpage.c      |  4 ++--
 arch/metag/mm/hugetlbpage.c     |  3 ++-
 arch/mips/mm/hugetlbpage.c      |  3 ++-
 arch/parisc/mm/hugetlbpage.c    |  3 ++-
 arch/powerpc/mm/hugetlbpage.c   |  2 +-
 arch/s390/include/asm/hugetlb.h |  2 +-
 arch/s390/mm/hugetlbpage.c      |  3 ++-
 arch/sh/mm/hugetlbpage.c        |  3 ++-
 arch/sparc/mm/hugetlbpage.c     |  3 ++-
 arch/tile/mm/hugetlbpage.c      |  3 ++-
 arch/x86/mm/hugetlbpage.c       |  2 +-
 fs/userfaultfd.c                |  7 ++++--
 include/asm-generic/hugetlb.h   |  4 +++-
 include/linux/hugetlb.h         | 18 ++++++++++++--
 mm/gup.c                        | 15 +++++-------
 mm/hugetlb.c                    | 33 +++++++++++++++----------
 mm/page_vma_mapped.c            |  3 ++-
 mm/pagewalk.c                   |  3 ++-
 mm/rmap.c                       |  7 ++++--
 20 files changed, 100 insertions(+), 74 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
