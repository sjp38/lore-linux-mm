Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3C40F6B0280
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 02:02:46 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so7973193igb.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 23:02:46 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id n100si3467140ioi.136.2015.09.30.23.02.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 23:02:45 -0700 (PDT)
Subject: Re: [PATCH v2 00/12] THP support for ARC
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <560CCC73.9080705@synopsys.com>
Date: Thu, 1 Oct 2015 11:32:27 +0530
MIME-Version: 1.0
In-Reply-To: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tuesday 22 September 2015 04:04 PM, Vineet Gupta wrote:
> Hi,
> 
> This series brings THP support to ARC. It also introduces an optional new
> thp hook for arches to possibly optimize the TLB flush in thp regime.
> 
> Please review !
> 
> Changes Since v1 [*]
>    - Rebased against v4.3-rc2
>    - Switched ARC pgtable_t to pte_t * 		(Kiril)
>    - Removed stub implementations for		(Andrew)
> 	pmdp_set_access_flags, pmdp_test_and_clear_young, pmdp_set_wrprotect,
> 	pmdp_collapse_flush, pmd_same
> 
> [*] http://lkml.kernel.org/r/1440666194-21478-1-git-send-email-vgupta@synopsys.com
> 
> Vineet Gupta (12):
>   ARC: mm: switch pgtable_to to pte_t *
>   ARC: mm: pte flags comsetic cleanups, comments
>   ARC: mm: Introduce PTE_SPECIAL
>   Documentation/features/vm: pte_special now supported by ARC
>   ARCv2: mm: THP support
>   ARCv2: mm: THP: boot validation/reporting
>   Documentation/features/vm: THP now supported by ARC
>   mm: move some code around
>   mm,thp: reduce ifdef'ery for THP in generic code
>   mm,thp: introduce flush_pmd_tlb_range
>   ARCv2: mm: THP: Implement flush_pmd_tlb_range() optimization
>   ARCv2: Add a DT which enables THP
> 
>  Documentation/features/vm/THP/arch-support.txt     |  2 +-
>  .../features/vm/pte_special/arch-support.txt       |  2 +-
>  arch/arc/Kconfig                                   |  4 +
>  arch/arc/boot/dts/hs_thp.dts                       | 59 +++++++++++++
>  arch/arc/include/asm/hugepage.h                    | 82 ++++++++++++++++++
>  arch/arc/include/asm/page.h                        |  5 +-
>  arch/arc/include/asm/pgalloc.h                     |  6 +-
>  arch/arc/include/asm/pgtable.h                     | 60 +++++++------
>  arch/arc/mm/tlb.c                                  | 76 ++++++++++++++++-
>  arch/arc/mm/tlbex.S                                | 21 +++--
>  include/asm-generic/pgtable.h                      | 49 ++++-------
>  mm/huge_memory.c                                   |  2 +-
>  mm/pgtable-generic.c                               | 99 ++++++++++------------
>  13 files changed, 345 insertions(+), 122 deletions(-)
>  create mode 100644 arch/arc/boot/dts/hs_thp.dts
>  create mode 100644 arch/arc/include/asm/hugepage.h

Andrew, Kirill, could you please review/ack the generic mm bits atleast so I can
proceed with moving the stuff into linux-next !

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
