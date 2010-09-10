Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E2FA76B004A
	for <linux-mm@kvack.org>; Fri, 10 Sep 2010 00:25:17 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/4] hugetlb, rmap: fixes and cleanups
Date: Fri, 10 Sep 2010 13:23:02 +0900
Message-Id: <1284092586-1179-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

These are fix and cleanup patches for hugepage rmapping.
All these were pointed out in the following thread (last 4 messages.)

  http://thread.gmane.org/gmane.linux.kernel.mm/52334

Summary:

 [PATCH 1/4] hugetlb, rmap: always use anon_vma root pointer
 [PATCH 2/4] hugetlb, rmap: use hugepage_add_new_anon_rmap() in hugetlb_cow()
 [PATCH 3/4] hugetlb, rmap: fix confusing page locking in hugetlb_cow()
 [PATCH 4/4] hugetlb, rmap: add BUG_ON(!PageLocked) in hugetlb_add_anon_rmap()

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
