Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 747026B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 10:52:48 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/6 v5] pagemap handles transparent hugepage
Date: Wed,  8 Feb 2012 10:51:36 -0500
Message-Id: <1328716302-16871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi,

In this version, I applied the feedbacks about the return value of
__pmd_trans_huge_lock() and renaming newly added components.
I hope these patches go into mainline.

Naoya Horiguchi (6):
  pagemap: avoid splitting thp when reading /proc/pid/pagemap
  thp: optimize away unnecessary page table locking
  pagemap: export KPF_THP
  pagemap: document KPF_THP and make page-types aware of it
  introduce pmd_to_pte_t()
  pagemap: introduce data structure for pagemap entry

 Documentation/vm/page-types.c     |    2 +
 Documentation/vm/pagemap.txt      |    4 +
 arch/x86/include/asm/pgtable.h    |    5 ++
 fs/proc/page.c                    |    2 +
 fs/proc/task_mmu.c                |  138 ++++++++++++++++++++++---------------
 include/asm-generic/pgtable.h     |    4 +
 include/linux/huge_mm.h           |   17 +++++
 include/linux/kernel-page-flags.h |    1 +
 mm/huge_memory.c                  |  122 +++++++++++++++-----------------
 mm/mremap.c                       |    2 -
 10 files changed, 174 insertions(+), 123 deletions(-)

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
