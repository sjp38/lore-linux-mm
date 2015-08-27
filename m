Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8416B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:03:43 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so1222929pac.3
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:03:43 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id uw7si2558849pac.8.2015.08.27.02.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 02:03:42 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 00/11] THP support for ARC
Date: Thu, 27 Aug 2015 14:33:03 +0530
Message-ID: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Hi,

This series brings THP support to ARC. It also introduces an optional new
thp hook for arches to possibly optimize the TLB flush in thp regime.

Rebased against linux-next of today so includes new hook for Minchan's
madvise(MADV_FREE).

Please review !

Thx,
-Vineet

Vineet Gupta (11):
  ARC: mm: pte flags comsetic cleanups, comments
  ARC: mm: Introduce PTE_SPECIAL
  Documentation/features/vm: pte_special now supported by ARC
  ARCv2: mm: THP support
  ARCv2: mm: THP: boot validation/reporting
  Documentation/features/vm: THP now supported by ARC
  mm: move some code around
  mm,thp: reduce ifdef'ery for THP in generic code
  mm,thp: introduce flush_pmd_tlb_range
  ARCv2: mm: THP: Implement flush_pmd_tlb_range() optimization
  ARCv2: Add a DT which enables THP

 Documentation/features/vm/THP/arch-support.txt     |  2 +-
 .../features/vm/pte_special/arch-support.txt       |  2 +-
 arch/arc/Kconfig                                   |  4 +
 arch/arc/boot/dts/hs_thp.dts                       | 59 +++++++++++++
 arch/arc/include/asm/hugepage.h                    | 82 ++++++++++++++++++
 arch/arc/include/asm/page.h                        |  1 +
 arch/arc/include/asm/pgtable.h                     | 60 +++++++------
 arch/arc/mm/tlb.c                                  | 79 ++++++++++++++++-
 arch/arc/mm/tlbex.S                                | 21 +++--
 include/asm-generic/pgtable.h                      | 20 +++++
 mm/huge_memory.c                                   |  2 +-
 mm/pgtable-generic.c                               | 99 ++++++++++------------
 12 files changed, 345 insertions(+), 86 deletions(-)
 create mode 100644 arch/arc/boot/dts/hs_thp.dts
 create mode 100644 arch/arc/include/asm/hugepage.h

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
