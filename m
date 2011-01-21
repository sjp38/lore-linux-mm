Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 07C8B8D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:32:37 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/7] HWPOISON for hugepage backed KVM guest
Date: Fri, 21 Jan 2011 15:28:53 +0900
Message-Id: <1295591340-1862-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <tatsu@ab.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>, tony.luck@intel.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

I wrote "HWPOISON for hugepage" patchset last year, but it didn't
cover the hugepages used by KVM guest because follow_hugetlb_pages()
called in a guest page fault code path didn't know about swap entry
formatted pmd entry.
This patchset fixes it and makes both soft and hard offline available
on hugepage backed KVM guest.

I appreciate all of your comments and reviews.

Thanks,
Naoya Horiguchi

Summary:

  [PATCH 1/7] hugetlb: check swap entry in follow_hugetlb_page()
  [PATCH 2/7] check hugepage swap entry in get_user_pages_fast()
  [PATCH 3/7] remove putback_lru_pages() in hugepage migration context
  [PATCH 4/7] hugetlb, migration: add migration_hugepage_entry_wait()
  [PATCH 5/7] hugetlb: fix race condition between hugepage soft offline and page fault
  [PATCH 6/7] HWPOISON: pass order to set/clear_page_hwpoison_huge_page()
  [PATCH 7/7] HWPOISON, hugetlb: fix hard offline for hugepage backed KVM guest

  arch/x86/mm/gup.c       |    9 +++++++++
  include/linux/swapops.h |   20 ++++++++++++++++++++
  mm/hugetlb.c            |   39 +++++++++++++++++++++++++++++----------
  mm/memory-failure.c     |   24 +++++++++++++-----------
  mm/migrate.c            |   33 +++++++++++++++++++++++++++++++++
  5 files changed, 104 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
