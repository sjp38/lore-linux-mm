Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 7F9DA6B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 17:28:12 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/2 v3] split page table lock for hugepage
Date: Thu,  5 Sep 2013 17:27:44 -0400
Message-Id: <1378416466-30913-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

I revised the split ptl patchset with small fixes.
See also the previous post [1] for the motivation and the numbers.

Any comments and reviews are welcomed.

[1] http://thread.gmane.org/gmane.linux.kernel.mm/106292/

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (2):
      hugetlbfs: support split page table lock
      thp: support split page table lock

 arch/powerpc/mm/pgtable_64.c |   8 +-
 arch/s390/mm/pgtable.c       |   4 +-
 arch/sparc/mm/tlb.c          |   4 +-
 fs/proc/task_mmu.c           |  17 +++--
 include/linux/huge_mm.h      |  11 +--
 include/linux/hugetlb.h      |  20 +++++
 include/linux/mm.h           |   3 +
 include/linux/mm_types.h     |   2 +
 mm/huge_memory.c             | 171 ++++++++++++++++++++++++++-----------------
 mm/hugetlb.c                 |  92 ++++++++++++++---------
 mm/memcontrol.c              |  14 ++--
 mm/memory.c                  |  15 ++--
 mm/mempolicy.c               |   5 +-
 mm/migrate.c                 |  12 +--
 mm/mprotect.c                |   5 +-
 mm/pgtable-generic.c         |  10 +--
 mm/rmap.c                    |  13 ++--
 17 files changed, 246 insertions(+), 160 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
