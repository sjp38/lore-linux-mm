Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A7BBC6B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:13 -0400 (EDT)
Received: by pdco4 with SMTP id o4so8338035pdc.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ox5si882960pbc.7.2015.08.04.12.58.12
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:12 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 00/11] DAX fixes for 4.3
Date: Tue,  4 Aug 2015 15:57:54 -0400
Message-Id: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Hi Andrew,

I believe this entire patch series should apply cleanly to your tree.

The first patch I have already sent to Ted.  It should be applied for 4.2.

Patch 4 depends on patch 1 having been applied first, patch 5 depends
on patch 4, and patch 6 depends on patch 5, so I can't wait for those
patches to go in via the ext4 tree.

Most of these patches aren't needed for 4.2 and earlier, because they
pertain to the PMD support which is only in the -mm tree.

Kirill A. Shutemov (3):
  thp: Decrement refcount on huge zero page if it is split
  thp: Fix zap_huge_pmd() for DAX
  dax: Don't use set_huge_zero_page()

Matthew Wilcox (8):
  ext4: Use ext4_get_block_write() for DAX
  thp: Change insert_pfn's return type to void
  dax: Improve comment about truncate race
  ext4: Add ext4_get_block_dax()
  ext4: Start transaction before calling into DAX
  dax: Fix race between simultaneous faults
  dax: Ensure that zero pages are removed from other processes
  dax: Use linear_page_index()

 fs/dax.c                | 66 ++++++++++++++++++++++++---------------
 fs/ext4/ext4.h          |  2 ++
 fs/ext4/file.c          | 61 ++++++++++++++++++++++++++++++++----
 fs/ext4/inode.c         | 11 +++++++
 include/linux/huge_mm.h |  3 --
 mm/huge_memory.c        | 83 ++++++++++++++++++++++---------------------------
 mm/memory.c             | 11 +++++--
 7 files changed, 155 insertions(+), 82 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
