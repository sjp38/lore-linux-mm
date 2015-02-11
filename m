Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id CF13A6B006C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:12:19 -0500 (EST)
Received: by pdev10 with SMTP id v10so5576789pde.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 09:12:19 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bz2si1712627pad.86.2015.02.11.09.12.16
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 09:12:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/4] Cleanup mm_populate() codepath
Date: Wed, 11 Feb 2015 19:12:04 +0200
Message-Id: <1423674728-214192-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

While reading mlock()- and mm_populate()-related code, I've found several
things confusing. This patchset cleanup the codepath for future readers.

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
