Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 932546B006E
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:25:34 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so432634eaa.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 08:25:32 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 00/19] latest numa/base patches
Date: Fri, 16 Nov 2012 17:25:02 +0100
Message-Id: <1353083121-4560-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

This is the split-out series of mm/ patches that got no objections
from the latest (v15) posting of numa/core. If everyone is still
fine with these then these will be merge candidates for v3.8.

I left out the more contentious policy bits that people are still
arguing about.

The numa/base tree can also be found here:

   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git numa/base

Thanks,

    Ingo

------------------->

Andrea Arcangeli (1):
  numa, mm: Support NUMA hinting page faults from gup/gup_fast

Gerald Schaefer (1):
  sched, numa, mm, s390/thp: Implement pmd_pgprot() for s390

Ingo Molnar (1):
  mm/pgprot: Move the pgprot_modify() fallback definition to mm.h

Lee Schermerhorn (3):
  mm/mpol: Add MPOL_MF_NOOP
  mm/mpol: Check for misplaced page
  mm/mpol: Add MPOL_MF_LAZY

Peter Zijlstra (7):
  sched, numa, mm: Make find_busiest_queue() a method
  sched, numa, mm: Describe the NUMA scheduling problem formally
  mm/thp: Preserve pgprot across huge page split
  mm/mpol: Make MPOL_LOCAL a real policy
  mm/mpol: Create special PROT_NONE infrastructure
  mm/migrate: Introduce migrate_misplaced_page()
  mm/mpol: Use special PROT_NONE to migrate pages

Ralf Baechle (1):
  sched, numa, mm, MIPS/thp: Add pmd_pgprot() implementation

Rik van Riel (5):
  mm/generic: Only flush the local TLB in ptep_set_access_flags()
  x86/mm: Only do a local tlb flush in ptep_set_access_flags()
  x86/mm: Introduce pte_accessible()
  mm: Only flush the TLB when clearing an accessible pte
  x86/mm: Completely drop the TLB flush from ptep_set_access_flags()

 Documentation/scheduler/numa-problem.txt | 230 +++++++++++++++++++++++++++++++
 arch/mips/include/asm/pgtable.h          |   2 +
 arch/s390/include/asm/pgtable.h          |  13 ++
 arch/x86/include/asm/pgtable.h           |   7 +
 arch/x86/mm/pgtable.c                    |   8 +-
 include/asm-generic/pgtable.h            |   4 +
 include/linux/huge_mm.h                  |  19 +++
 include/linux/mempolicy.h                |   8 ++
 include/linux/migrate.h                  |   7 +
 include/linux/migrate_mode.h             |   3 +
 include/linux/mm.h                       |  32 +++++
 include/uapi/linux/mempolicy.h           |  16 ++-
 kernel/sched/fair.c                      |  20 +--
 mm/huge_memory.c                         | 174 +++++++++++++++--------
 mm/memory.c                              | 119 +++++++++++++++-
 mm/mempolicy.c                           | 143 +++++++++++++++----
 mm/migrate.c                             |  85 ++++++++++--
 mm/mprotect.c                            |  31 +++--
 mm/pgtable-generic.c                     |   9 +-
 19 files changed, 807 insertions(+), 123 deletions(-)
 create mode 100644 Documentation/scheduler/numa-problem.txt

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
