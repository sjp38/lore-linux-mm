Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 496ED6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 16:57:37 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so171070440pab.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 13:57:37 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fd5si21299262pab.145.2015.05.04.13.57.36
        for <linux-mm@kvack.org>;
        Mon, 04 May 2015 13:57:36 -0700 (PDT)
Message-Id: <cover.1430772743.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Mon, 4 May 2015 13:52:23 -0700
Subject: [PATCH 0/3] Find mirrored memory, use for boot time allocations
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

UEFI published the spec that descibes the attribute bit we need to
find out which memory ranges are mirrored. So time to post the real
version of this series.

These patches are against 4.1-rc1 ... I think there are a couple of
trivial conflicts with the current mmotm.

Tony Luck (3):
  mm/memblock: Add extra "flag" to memblock to allow selection of memory
    based on attribute
  mm/memblock: Allocate boot time data structures from mirrored memory
  x86, mirror: x86 enabling - find mirrored memory ranges

 arch/s390/kernel/crash_dump.c |   4 +-
 arch/sparc/mm/init_64.c       |   4 +-
 arch/x86/kernel/check.c       |   2 +-
 arch/x86/kernel/e820.c        |   2 +-
 arch/x86/kernel/setup.c       |   3 ++
 arch/x86/mm/init_32.c         |   2 +-
 arch/x86/platform/efi/efi.c   |  21 ++++++++
 include/linux/efi.h           |   3 ++
 include/linux/memblock.h      |  43 ++++++++++------
 mm/cma.c                      |   4 +-
 mm/memblock.c                 | 113 ++++++++++++++++++++++++++++++++----------
 mm/memtest.c                  |   2 +-
 mm/nobootmem.c                |  12 ++++-
 13 files changed, 162 insertions(+), 53 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
