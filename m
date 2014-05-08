Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8E94A6B00E8
	for <linux-mm@kvack.org>; Thu,  8 May 2014 08:41:55 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id i8so2705007qcq.4
        for <linux-mm@kvack.org>; Thu, 08 May 2014 05:41:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ot5si474035pbc.123.2014.05.08.05.41.54
        for <linux-mm@kvack.org>;
        Thu, 08 May 2014 05:41:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/2] remap_file_pages() decommission
Date: Thu,  8 May 2014 15:41:26 +0300
Message-Id: <1399552888-11024-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrew and Linus,

These two patches demonstrate how we can get rid nonlinear mappings.

The first patch documents remap_file_pages(2) deprecation and add printk
into syscall code. The patch could be propagated through stable kernel if
the approach with remap_file_pages() emulation is okay.

The second patch replaces remap_file_pages(2) with and emulation. I didn't
find any real code (apart LTP) to test it on. So I wrote simple test case.
See commit message for numbers.

I will prepare separate patchset to cleanup all nonlinear mappings
leftovers if the approach with emulation is desirable.

Comments?

Kirill A. Shutemov (2):
  mm: mark remap_file_pages() syscall as deprecated
  mm: replace remap_file_pages() syscall with emulation

 Documentation/vm/remap_file_pages.txt |  27 ++++
 include/linux/fs.h                    |   8 +-
 mm/Makefile                           |   2 +-
 mm/fremap.c                           | 282 ----------------------------------
 mm/mmap.c                             |  66 ++++++++
 mm/nommu.c                            |   8 -
 6 files changed, 100 insertions(+), 293 deletions(-)
 create mode 100644 Documentation/vm/remap_file_pages.txt
 delete mode 100644 mm/fremap.c

-- 
2.0.0.rc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
