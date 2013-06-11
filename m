Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 166896B004D
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:33:11 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/8] Transparent huge page cache: phase 0, prep work
Date: Tue, 11 Jun 2013 18:35:11 +0300
Message-Id: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

My patchset which introduces transparent huge page cache is pretty big and
hardly reviewable. Dave Hansen suggested to split it in few parts.

This is the first part: preparation work. I think it's useful without rest
patches.

There's one fix for bug in lru_add_page_tail(). I doubt it's possible to
trigger it on current code, but nice to have it upstream anyway.
Rest is cleanups.

Patch 8 depends on patch 7. Other patches are independent and can be
applied separately.

Please, consider applying.

Kirill A. Shutemov (8):
  mm: drop actor argument of do_generic_file_read()
  thp, mm: avoid PageUnevictable on active/inactive lru lists
  thp: account anon transparent huge pages into NR_ANON_PAGES
  mm: cleanup add_to_page_cache_locked()
  thp, mm: locking tail page is a bug
  thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
  thp: do_huge_pmd_anonymous_page() cleanup
  thp: consolidate code between handle_mm_fault() and
    do_huge_pmd_anonymous_page()

 drivers/base/node.c     |    6 ---
 fs/proc/meminfo.c       |    6 ---
 include/linux/huge_mm.h |    3 --
 include/linux/mm.h      |    3 +-
 mm/filemap.c            |   60 ++++++++++++-----------
 mm/huge_memory.c        |  125 ++++++++++++++++++++---------------------------
 mm/memory.c             |    9 ++--
 mm/rmap.c               |   18 +++----
 mm/swap.c               |   20 +-------
 9 files changed, 104 insertions(+), 146 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
