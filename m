Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD67F6B0279
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:48:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v9so24154616pfk.5
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:48:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u72si1788824pfk.160.2017.06.27.04.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 04:48:53 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 0/5] v2 mm subsystem refcounter conversions
Date: Tue, 27 Jun 2017 14:48:42 +0300
Message-Id: <1498564127-11097-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, keescook@chromium.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>

Changes in v2:
No changes in patches apart from trivial rebases, but now by
default refcount_t = atomic_t and uses all atomic standard operations
unless CONFIG_REFCOUNT_FULL is enabled. This is a compromize for the
systems that are critical on performance and cannot accept even
slight delay on the refcounter operations.


Elena Reshetova (5):
  mm: convert bdi_writeback_congested.refcnt from atomic_t to refcount_t
  mm: convert anon_vma.refcount from atomic_t to refcount_t
  mm: convert kmemleak_object.use_count from atomic_t to refcount_t
  mm: convert mm_struct.mm_users from atomic_t to refcount_t
  mm: convert mm_struct.mm_count from atomic_t to refcount_t

 arch/alpha/kernel/smp.c                  |  6 +++---
 arch/arc/mm/tlb.c                        |  2 +-
 arch/blackfin/mach-common/smp.c          |  4 ++--
 arch/ia64/include/asm/tlbflush.h         |  2 +-
 arch/ia64/kernel/smp.c                   |  2 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c        |  4 ++--
 arch/mips/kernel/process.c               |  2 +-
 arch/mips/kernel/smp.c                   |  6 +++---
 arch/parisc/include/asm/mmu_context.h    |  2 +-
 arch/powerpc/mm/hugetlbpage.c            |  2 +-
 arch/powerpc/mm/icswx.c                  |  4 ++--
 arch/sh/kernel/smp.c                     |  6 +++---
 arch/sparc/kernel/smp_64.c               |  6 +++---
 arch/sparc/mm/srmmu.c                    |  2 +-
 arch/um/kernel/tlb.c                     |  2 +-
 arch/x86/kernel/tboot.c                  |  4 ++--
 drivers/firmware/efi/arm-runtime.c       |  4 ++--
 drivers/gpu/drm/amd/amdkfd/kfd_process.c |  2 +-
 fs/coredump.c                            |  2 +-
 fs/proc/base.c                           |  2 +-
 fs/proc/task_nommu.c                     |  4 ++--
 fs/userfaultfd.c                         |  3 +--
 include/linux/backing-dev-defs.h         |  3 ++-
 include/linux/backing-dev.h              |  4 ++--
 include/linux/mm_types.h                 |  5 +++--
 include/linux/rmap.h                     |  7 ++++---
 include/linux/sched/mm.h                 | 10 +++++-----
 kernel/events/uprobes.c                  |  2 +-
 kernel/exit.c                            |  2 +-
 kernel/fork.c                            | 12 ++++++------
 kernel/sched/core.c                      |  2 +-
 lib/is_single_threaded.c                 |  2 +-
 mm/backing-dev.c                         | 13 +++++++------
 mm/debug.c                               |  4 ++--
 mm/init-mm.c                             |  4 ++--
 mm/khugepaged.c                          |  2 +-
 mm/kmemleak.c                            | 16 ++++++++--------
 mm/ksm.c                                 |  2 +-
 mm/memory.c                              |  2 +-
 mm/mmu_notifier.c                        | 10 +++++-----
 mm/mprotect.c                            |  2 +-
 mm/oom_kill.c                            |  2 +-
 mm/rmap.c                                | 14 +++++++-------
 mm/swapfile.c                            |  2 +-
 mm/vmacache.c                            |  2 +-
 45 files changed, 100 insertions(+), 97 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
