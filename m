Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 1979B6B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 18:01:55 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/6 v4] pagemap handles transparent hugepage
Date: Fri, 27 Jan 2012 18:02:47 -0500
Message-Id: <1327705373-29395-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi,

I rebased the patchset onto 3.3-rc1, and made some fixes on thp
optimization patch based on the feedbacks from Andrea.

Naoya Horiguchi (6):
  pagemap: avoid splitting thp when reading
  thp: optimize away unnecessary page table locking
  pagemap: export KPF_THP
  pagemap: document KPF_THP and make page-types aware of
  introduce thp_ptep_get()
  pagemap: introduce data structure for pagemap entry

 Documentation/vm/page-types.c     |    2 +
 Documentation/vm/pagemap.txt      |    4 +
 arch/x86/include/asm/pgtable.h    |    5 ++
 fs/proc/page.c                    |    2 +
 fs/proc/task_mmu.c                |  135 +++++++++++++++++++++----------------
 include/asm-generic/pgtable.h     |    4 +
 include/linux/huge_mm.h           |   17 +++++
 include/linux/kernel-page-flags.h |    1 +
 mm/huge_memory.c                  |  120 +++++++++++++++-----------------
 9 files changed, 169 insertions(+), 121 deletions(-)

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
