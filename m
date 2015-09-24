Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 118BB6B026C
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 10:51:13 -0400 (EDT)
Received: by pacgz1 with SMTP id gz1so8602479pac.3
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 07:51:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id or5si18959154pab.13.2015.09.24.07.51.11
        for <linux-mm@kvack.org>;
        Thu, 24 Sep 2015 07:51:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 00/16] Refreshed page-flags patchset
Date: Thu, 24 Sep 2015 17:50:48 +0300
Message-Id: <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As requested, here's reworked version of page-flags patchset.
Updated version should fit more naturally into current code base.

Kirill A. Shutemov (16):
  page-flags: trivial cleanup for PageTrans* helpers
  page-flags: move code around
  page-flags: introduce page flags policies wrt compound pages
  page-flags: define PG_locked behavior on compound pages
  page-flags: define behavior of FS/IO-related flags on compound pages
  page-flags: define behavior of LRU-related flags on compound pages
  page-flags: define behavior SL*B-related flags on compound pages
  page-flags: define behavior of Xen-related flags on compound pages
  page-flags: define PG_reserved behavior on compound pages
  page-flags: define PG_swapbacked behavior on compound pages
  page-flags: define PG_swapcache behavior on compound pages
  page-flags: define PG_mlocked behavior on compound pages
  page-flags: define PG_uncached behavior on compound pages
  page-flags: define PG_uptodate behavior on compound pages
  page-flags: look at head page if the flag is encoded in page->mapping
  mm: sanitize page->mapping for tail pages

 fs/cifs/file.c             |   8 +-
 include/linux/page-flags.h | 236 +++++++++++++++++++++++++--------------------
 include/linux/pagemap.h    |  25 ++---
 include/linux/poison.h     |   4 +
 mm/filemap.c               |  15 +--
 mm/huge_memory.c           |   2 +-
 mm/ksm.c                   |   2 +-
 mm/memory-failure.c        |   2 +-
 mm/memory.c                |   2 +-
 mm/migrate.c               |   2 +-
 mm/page_alloc.c            |   6 ++
 mm/shmem.c                 |   4 +-
 mm/slub.c                  |   2 +
 mm/swap_state.c            |   4 +-
 mm/util.c                  |  10 +-
 mm/vmscan.c                |   2 +-
 16 files changed, 182 insertions(+), 144 deletions(-)

-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
