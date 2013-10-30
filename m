Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2716B0036
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 17:45:57 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so537721pbb.11
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 14:45:57 -0700 (PDT)
Received: from psmtp.com ([74.125.245.121])
        by mx.google.com with SMTP id hj4si315197pac.329.2013.10.30.14.45.55
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 14:45:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 00/11 v2] update page table walker
Date: Wed, 30 Oct 2013 17:44:48 -0400
Message-Id: <1383169499-25144-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

Hi,

This is the ver.2 of page table walker patchset.
I rebased it onto the latest mmots (solved conflicts with split PMD locks),
and added a few small changes.

As for the motivation and/or brief summary, please refer to ver.1's cover letter.
http://article.gmane.org/gmane.linux.kernel.mm/108362

Thanks,
Naoya Horiguchi
---
GitHub:
  git://github.com/Naoya-Horiguchi/linux.git v3.12-rc7-mmots-2013-10-29-16-24/rewrite_pagewalker.v2

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
