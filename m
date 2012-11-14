Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 3102F6B0072
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 03:50:50 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so136854eek.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 00:50:48 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 0/2] change_protection(): Count the number of pages affected
Date: Wed, 14 Nov 2012 09:50:27 +0100
Message-Id: <1352883029-7885-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>

What do you guys think about this mprotect() optimization?

Thanks,

	Ingo

--
Ingo Molnar (1):
  mm: Optimize the TLB flush of sys_mprotect() and change_protection()
    users

Peter Zijlstra (1):
  sched, numa, mm: Count WS scanning against present PTEs, not virtual
    memory ranges

 include/linux/hugetlb.h |  8 ++++++--
 include/linux/mm.h      |  6 +++---
 kernel/sched/fair.c     | 37 +++++++++++++++++++++----------------
 mm/hugetlb.c            | 10 ++++++++--
 mm/mprotect.c           | 46 ++++++++++++++++++++++++++++++++++------------
 5 files changed, 72 insertions(+), 35 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
