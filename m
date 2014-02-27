Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id AEE586B006C
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 23:39:54 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id f15so1453645eak.2
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 20:39:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c43si6171807eeo.185.2014.02.26.20.39.51
        for <linux-mm@kvack.org>;
        Wed, 26 Feb 2014 20:39:52 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/3] fixes on page table walker and hugepage rmapping
Date: Wed, 26 Feb 2014 23:39:34 -0500
Message-Id: <1393475977-3381-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Sasha, could you test if the bug you reported recently [1] reproduces
on the latest next tree with this patchset? (I'm not sure of this
because the problem looks differently in my own testing...)

[1] http://thread.gmane.org/gmane.linux.kernel.mm/113374/focus=113
---
Summary:

Naoya Horiguchi (3):
      mm/pagewalk.c: fix end address calculation in walk_page_range()
      mm, hugetlbfs: fix rmapping for anonymous hugepages with page_pgoff()
      mm: call vma_adjust_trans_huge() only for thp-enabled vma

 include/linux/pagemap.h | 13 +++++++++++++
 mm/huge_memory.c        |  2 +-
 mm/hugetlb.c            |  5 +++++
 mm/memory-failure.c     |  4 ++--
 mm/mmap.c               |  3 ++-
 mm/pagewalk.c           |  5 +++--
 mm/rmap.c               |  8 ++------
 7 files changed, 28 insertions(+), 12 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
