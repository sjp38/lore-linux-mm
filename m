Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFEC6B0038
	for <linux-mm@kvack.org>; Mon, 16 Feb 2015 06:28:00 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id eu11so34663203pac.7
        for <linux-mm@kvack.org>; Mon, 16 Feb 2015 03:27:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id iw5si700657pbb.30.2015.02.16.03.27.58
        for <linux-mm@kvack.org>;
        Mon, 16 Feb 2015 03:27:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/4] Cleanup mm_populate() codepath
Date: Mon, 16 Feb 2015 13:27:50 +0200
Message-Id: <1424086074-200683-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

While reading mlock()- and mm_populate()-related code, I've found several
things confusing. This patchset cleanup the codepath for future readers.

v2:
 - Fix typos pointed by David Rientjes;
 - Apply acks;

Kirill A. Shutemov (4):
  mm: rename FOLL_MLOCK to FOLL_POPULATE
  mm: rename __mlock_vma_pages_range() to populate_vma_page_range()
  mm: move gup() -> posix mlock() error conversion out of __mm_populate
  mm: move mm_populate()-related code to mm/gup.c

 Documentation/vm/unevictable-lru.txt |  26 +++----
 include/linux/mm.h                   |   2 +-
 mm/gup.c                             | 124 ++++++++++++++++++++++++++++++++-
 mm/huge_memory.c                     |   2 +-
 mm/internal.h                        |   2 +-
 mm/mlock.c                           | 131 +++--------------------------------
 mm/mmap.c                            |   4 +-
 7 files changed, 142 insertions(+), 149 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
