Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id E69BB6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:09:53 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so3137908eek.21
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:09:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j47si21063063eeo.116.2013.12.11.14.09.52
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:09:52 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 00/11 v3] update page table walker
Date: Wed, 11 Dec 2013 17:08:56 -0500
Message-Id: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Hi,

This is ver.3 of page table walker patchset.
I rebased it onto v3.13-rc3-mmots-2013-12-10-16-38.

As for the motivation and/or brief summary, please refer to patch 1/11 and/or
the cover letter of ver.1.
- v1: http://article.gmane.org/gmane.linux.kernel.mm/108362
- v2: http://article.gmane.org/gmane.linux.kernel.mm/108827

Thanks,
Naoya Horiguchi
---
GitHub:
  git://github.com/Naoya-Horiguchi/linux.git v3.13-rc3-mmots-2013-12-10-16-38/update_page_table_walker.v3

Test code:
  git://github.com/Naoya-Horiguchi/test_rewrite_page_table_walker.git
---
Summary:

Naoya Horiguchi (11):
      pagewalk: update page table walker core
      pagewalk: add walk_page_vma()
      smaps: redefine callback functions for page table walker
      clear_refs: redefine callback functions for page table walker
      pagemap: redefine callback functions for page table walker
      numa_maps: redefine callback functions for page table walker
      memcg: redefine callback functions for page table walker
      madvise: redefine callback functions for page table walker
      arch/powerpc/mm/subpage-prot.c: use walk_page_vma() instead of walk_page_range()
      pagewalk: remove argument hmask from hugetlb_entry()
      mempolicy: apply page table walker on queue_pages_range()

 arch/powerpc/mm/subpage-prot.c |   6 +-
 fs/proc/task_mmu.c             | 267 ++++++++++++-----------------
 include/linux/mm.h             |  24 ++-
 mm/madvise.c                   |  43 ++---
 mm/memcontrol.c                |  71 +++-----
 mm/mempolicy.c                 | 255 +++++++++++-----------------
 mm/pagewalk.c                  | 370 ++++++++++++++++++++++++++---------------
 7 files changed, 501 insertions(+), 535 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
