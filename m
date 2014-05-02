Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id B996C6B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 09:41:48 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id f10so4130797yha.30
        for <linux-mm@kvack.org>; Fri, 02 May 2014 06:41:48 -0700 (PDT)
Received: from cam-smtp0.cambridge.arm.com (fw-tnat.cambridge.arm.com. [217.140.96.21])
        by mx.google.com with ESMTPS id h54si38479697yhf.153.2014.05.02.06.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:41:47 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 0/6] Kmemleak updates
Date: Fri,  2 May 2014 14:41:04 +0100
Message-Id: <1399038070-1540-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>

Hi,

This series contains a few kmemleak updates:

- Avoid false positives caused by not tracking all memblock allocations
  and disabling the kmemleak early logging slightly earlier
- Debugging improvements for places where pre-allocation happens
  (mempool and radix tree)
- minor printk correction

Catalin Marinas (5):
  mm: Introduce kmemleak_update_trace()
  lib: Update the kmemleak allocation stack trace for kmemleak
  mm: Update the kmemleak stack trace for mempool allocations
  mm: Call kmemleak directly from memblock_(alloc|free)
  mm: Postpone the disabling of kmemleak early logging

Jianpeng Ma (1):
  mm/kmemleak.c: Use %u to print ->checksum.

 Documentation/kmemleak.txt |  1 +
 include/linux/kmemleak.h   |  4 ++++
 lib/radix-tree.c           |  6 ++++++
 mm/kmemleak.c              | 43 ++++++++++++++++++++++++++++++++++++++-----
 mm/memblock.c              |  9 ++++++++-
 mm/mempool.c               |  6 ++++++
 mm/nobootmem.c             |  2 --
 7 files changed, 63 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
