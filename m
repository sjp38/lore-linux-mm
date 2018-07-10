Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B519D6B0005
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 09:48:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w11-v6so7931303pfk.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:48:21 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x5-v6si16070209pgb.399.2018.07.10.06.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 06:48:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Fix crash due to vma_is_anonymous() false-positives
Date: Tue, 10 Jul 2018 16:48:19 +0300
Message-Id: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Fix crash found by syzkaller.

The fix allows to remove ->vm_ops checks.

Kirill A. Shutemov (2):
  mm: Fix vma_is_anonymous() false-positives
  mm: Drop unneeded ->vm_ops checks

 drivers/char/mem.c   |  1 +
 fs/binfmt_elf.c      |  2 +-
 fs/exec.c            |  1 +
 fs/hugetlbfs/inode.c |  1 +
 fs/kernfs/file.c     | 20 +-------------------
 fs/proc/task_mmu.c   |  2 +-
 include/linux/mm.h   |  5 ++++-
 kernel/events/core.c |  2 +-
 kernel/fork.c        |  2 +-
 mm/hugetlb.c         |  2 +-
 mm/khugepaged.c      |  4 ++--
 mm/memory.c          | 12 ++++++------
 mm/mempolicy.c       | 10 +++++-----
 mm/mmap.c            | 27 ++++++++++++++++++++-------
 mm/mremap.c          |  2 +-
 mm/nommu.c           |  4 ++--
 mm/shmem.c           |  1 +
 17 files changed, 50 insertions(+), 48 deletions(-)

-- 
2.18.0
