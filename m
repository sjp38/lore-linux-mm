Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6E582F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 10:27:27 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so21269949pab.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 07:27:27 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id iu6si42992693pac.81.2015.11.03.07.27.26
        for <linux-mm@kvack.org>;
        Tue, 03 Nov 2015 07:27:26 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] Bugfixes for THP refcounting
Date: Tue,  3 Nov 2015 17:26:11 +0200
Message-Id: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi,

There's few bugfixes for THP refcounting patchset. It should address most
reported bugs.

I need to track down one more bug: rss-counter mismatch on exit.

Kirill A. Shutemov (4):
  mm: do not crash on PageDoubleMap() for non-head pages
  mm: duplicate rmap reference for hugetlb pages as compound
  thp: fix split vs. unmap race
  mm: prepare page_referenced() and page_idle to new THP refcounting

 include/linux/huge_mm.h    |   4 --
 include/linux/mm.h         |  19 +++++++
 include/linux/page-flags.h |   3 +-
 mm/huge_memory.c           |  76 ++++++-------------------
 mm/migrate.c               |   2 +-
 mm/page_idle.c             |  64 ++++++++++++++++++---
 mm/rmap.c                  | 137 ++++++++++++++++++++++++++++-----------------
 7 files changed, 180 insertions(+), 125 deletions(-)

-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
