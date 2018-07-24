Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF1A6B0006
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:11:43 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m25-v6so2441756pgv.22
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 05:11:43 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x3-v6si12443279pfj.289.2018.07.24.05.11.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 05:11:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 0/3] Fix crash due to vma_is_anonymous() false-positives
Date: Tue, 24 Jul 2018 15:11:36 +0300
Message-Id: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Fix crash found by syzkaller.

Build on top of Linus' changes in 4.18-rc6.

Andrew, could you please drop mm-drop-unneeded-vm_ops-checks-v2.patch for
now. Infiniband drivers have to be fixed first.

Kirill A. Shutemov (3):
  mm: Introduce vma_init()
  mm: Use vma_init() to initialize VMAs on stack and data segments
  mm: Fix vma_is_anonymous() false-positives

 arch/arm/kernel/process.c    |  1 +
 arch/arm/mach-rpc/ecard.c    |  2 +-
 arch/arm64/include/asm/tlb.h |  4 +++-
 arch/arm64/mm/hugetlbpage.c  |  7 +++++--
 arch/ia64/include/asm/tlb.h  |  2 +-
 arch/ia64/mm/init.c          |  2 +-
 arch/x86/um/mem_32.c         |  2 +-
 drivers/char/mem.c           |  1 +
 fs/exec.c                    |  1 +
 fs/hugetlbfs/inode.c         |  2 ++
 include/linux/mm.h           | 14 ++++++++++++++
 kernel/fork.c                |  6 ++----
 mm/mempolicy.c               |  1 +
 mm/mmap.c                    |  3 +++
 mm/nommu.c                   |  2 ++
 mm/shmem.c                   |  1 +
 16 files changed, 40 insertions(+), 11 deletions(-)

-- 
2.18.0
