Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 09DD66B01D9
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 01:49:38 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/7] hugepage migration
Date: Fri,  2 Jul 2010 14:47:19 +0900
Message-Id: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

This is a patchset for hugepage migration.

There are many users of page migration such as soft offlining,
memory hotplug, memory policy and memory compaction,
but this patchset adds hugepage support only for soft offlining
as the first step.

This patchset is based on 2.6.35-rc3 applied with "HWPOISON for
hugepage" patchset I previously posted (see Andi's git tree.)
http://git.kernel.org/?p=linux/kernel/git/ak/linux-mce-2.6.git;a=summary

I tested this patchset with 'make func' in libhugetlbfs and
have gotten the same result as one from 2.6.35-rc3.

 [PATCH 1/7] hugetlb: add missing unlock in avoidcopy path in hugetlb_cow()
 [PATCH 2/7] hugetlb, HWPOISON: move PG_HWPoison bit check
 [PATCH 3/7] hugetlb: add allocate function for hugepage migration
 [PATCH 4/7] hugetlb: add hugepage check in mem_cgroup_{register,end}_migration()
 [PATCH 5/7] hugetlb: pin oldpage in page migration
 [PATCH 6/7] hugetlb: hugepage migration core
 [PATCH 7/7] hugetlb, HWPOISON: soft offlining for hugepage

 fs/hugetlbfs/inode.c    |    2 +
 include/linux/hugetlb.h |    6 ++
 mm/hugetlb.c            |  138 +++++++++++++++++++++++++++++++++++-----------
 mm/memcontrol.c         |    5 ++
 mm/memory-failure.c     |   57 +++++++++++++++-----
 mm/migrate.c            |   70 ++++++++++++++++++++++--
 6 files changed, 226 insertions(+), 52 deletions(-)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
