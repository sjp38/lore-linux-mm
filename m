Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id B723F6B0044
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 11:13:26 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1042874eaa.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 08:13:25 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 0/2] numa/core updates
Date: Sun,  2 Dec 2012 17:13:14 +0100
Message-Id: <1354464796-14343-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

I've been testing wider workloads and here's two more small and
obvious patches rounding up numa/core behavior around the edges.

The NUMA code should now be pretty unintrusive to all but the
long-running, memory-intense workloads where it's expected to
make a (positive) difference.

Short-run workloads like kbuild or hackbench don't trigger the
NUMA code now. The limits can be reconsidered later on,
iteratively - the goal now is to not regress.

Thanks,

	Ingo

-------------->
Ingo Molnar (2):
  sched: Exclude pinned tasks from the NUMA-balancing logic
  sched: Add RSS filter to NUMA-balancing

 include/linux/sched.h   |  1 +
 kernel/sched/core.c     |  6 ++++++
 kernel/sched/debug.c    |  1 +
 kernel/sched/fair.c     | 53 +++++++++++++++++++++++++++++++++++++++++++++----
 kernel/sched/features.h |  1 +
 kernel/sysctl.c         |  7 +++++++
 6 files changed, 65 insertions(+), 4 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
