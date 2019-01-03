Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCA988E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 00:04:53 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m19so33138993edc.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 21:04:53 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u9-v6si183033ejk.320.2019.01.02.21.04.52
        for <linux-mm@kvack.org>;
        Wed, 02 Jan 2019 21:04:52 -0800 (PST)
Subject: Re: [RESEND PATCH V3 0/5] arm64/mm: Enable HugeTLB migration
References: <1545121450-1663-1-git-send-email-anshuman.khandual@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <c2fbd55e-4413-1bcf-769c-fd1064e74a2c@arm.com>
Date: Thu, 3 Jan 2019 10:34:38 +0530
MIME-Version: 1.0
In-Reply-To: <1545121450-1663-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: suzuki.poulose@arm.com, will.deacon@arm.com, Steven.Price@arm.com, steve.capper@arm.com, catalin.marinas@arm.com, mhocko@kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com



On 12/18/2018 01:54 PM, Anshuman Khandual wrote:
> This patch series enables HugeTLB migration support for all supported
> huge page sizes at all levels including contiguous bit implementation.
> Following HugeTLB migration support matrix has been enabled with this
> patch series. All permutations have been tested except for the 16GB.
> 
>          CONT PTE    PMD    CONT PMD    PUD
>          --------    ---    --------    ---
> 4K:         64K     2M         32M     1G
> 16K:         2M    32M          1G
> 64K:         2M   512M         16G
> 
> First the series adds migration support for PUD based huge pages. It
> then adds a platform specific hook to query an architecture if a
> given huge page size is supported for migration while also providing
> a default fallback option preserving the existing semantics which just
> checks for (PMD|PUD|PGDIR)_SHIFT macros. The last two patches enables
> HugeTLB migration on arm64 and subscribe to this new platform specific
> hook by defining an override.
> 
> The second patch differentiates between movability and migratability
> aspects of huge pages and implements hugepage_movable_supported() which
> can then be used during allocation to decide whether to place the huge
> page in movable zone or not.
> 
> This is just a resend for the previous version (V3) after the rebase
> on current mainline kernel. Also added all the tags previous version
> had received.
> 
> Changes in V3:
> 
> - Re-ordered patches 1 and 2 per Michal
> - s/Movability/Migratability/ in unmap_and_move_huge_page() per Naoya
> 
> Changes in V2: (https://lkml.org/lkml/2018/10/12/190)
> 
> - Added a new patch which differentiates migratability and movability
>   of huge pages and implements hugepage_movable_supported() function
>   as suggested by Michal Hocko.
> 
> Anshuman Khandual (5):
>   mm/hugetlb: Distinguish between migratability and movability
>   mm/hugetlb: Enable PUD level huge page migration
>   mm/hugetlb: Enable arch specific huge page size support for migration
>   arm64/mm: Enable HugeTLB migration
>   arm64/mm: Enable HugeTLB migration for contiguous bit HugeTLB pages
> 

Hello Andrew,

Just wondering if there are any updates on this series ? Is there something we need to
improve or fix some where in this series for it to get merged. Please do let us know.
Thank you.

- Anshuman
