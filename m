Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DABE6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 18:25:31 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so197416900pad.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 15:25:31 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id 79si5941283pfl.71.2016.09.09.15.25.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 15:25:27 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 0/2] refactor shmem_get_unmapped_area()
Date: Fri,  9 Sep 2016 16:24:21 -0600
Message-Id: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, mawilcox@microsoft.com, hughd@google.com, kirill.shutemov@linux.intel.com, toshi.kani@hpe.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

shmem_get_unmapped_area() provides a functionality similar
to __thp_get_unmapped_area() as both allocate a pmd-aligned
address.  This patchset changes shmem_get_unmapped_area()
to call __thp_get_unmapped_area() to share the code.

Patch 1 fixes a bug in shmem_get_unmapped_area() first.
Patch 2 changes shmem_get_unmapped_area() to call
__thp_get_unmapped_area() for sharing the code.

This patch-set applies on top of my patchset below.
https://lkml.org/lkml/2016/8/29/560

---
Toshi Kani (2):
 1/2 shmem: fix tmpfs to handle the huge= option properly
 2/2 shmem: call __thp_get_unmapped_area to alloc a pmd-aligned addr

---
 include/linux/huge_mm.h | 10 +++++++
 mm/shmem.c              | 70 ++++++++++---------------------------------------
 2 files changed, 24 insertions(+), 56 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
