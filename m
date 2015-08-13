Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2848A6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 11:55:03 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so20958535pdb.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 08:55:02 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tr10si4394566pac.236.2015.08.13.08.55.02
        for <linux-mm@kvack.org>;
        Thu, 13 Aug 2015 08:55:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Fix compound_head() race
Date: Thu, 13 Aug 2015 18:54:44 +0300
Message-Id: <1439481286-81093-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's my attempt on fixing recently discovered race in compound_head().
It should make compound_head() reliable in all contexts.

The patchset is against Linus' tree. Let me know if it need to be rebased
onto different baseline.

It's expected to have conflicts with my page-flags patchset and probably
should be applied before it.

Kirill A. Shutemov (2):
  zsmalloc: use page->private instead of page->first_page
  mm: make compound_head() robust

 Documentation/vm/split_page_table_lock |  4 +-
 arch/xtensa/configs/iss_defconfig      |  1 -
 include/linux/mm.h                     | 53 ++--------------------
 include/linux/mm_types.h               | 15 ++++---
 include/linux/page-flags.h             | 80 ++++++++--------------------------
 mm/Kconfig                             | 12 -----
 mm/debug.c                             |  7 ---
 mm/hugetlb.c                           |  8 +---
 mm/internal.h                          |  4 +-
 mm/memory-failure.c                    |  7 ---
 mm/page_alloc.c                        | 36 +++++++--------
 mm/swap.c                              |  4 +-
 mm/zsmalloc.c                          | 11 +++--
 13 files changed, 61 insertions(+), 181 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
