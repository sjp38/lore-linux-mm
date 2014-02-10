Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 23C956B0038
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 16:45:20 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id e4so3312986wiv.16
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 13:45:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ll10si8335006wjb.24.2014.02.10.13.45.13
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 13:45:14 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 00/11 v5] update page table walker
Date: Mon, 10 Feb 2014 16:44:25 -0500
Message-Id: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Hi,

This is ver.5 of page table walker patchset.
I rebased it onto v3.14-rc2.

- v1: http://article.gmane.org/gmane.linux.kernel.mm/108362
- v2: http://article.gmane.org/gmane.linux.kernel.mm/108827
- v3: http://article.gmane.org/gmane.linux.kernel.mm/110561
- v4: http://article.gmane.org/gmane.linux.kernel.mm/111832

Thanks,
Naoya Horiguchi
---
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
 mm/pagewalk.c                  | 372 ++++++++++++++++++++++++++---------------
 7 files changed, 506 insertions(+), 532 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
