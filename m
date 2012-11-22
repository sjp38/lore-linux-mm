Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 545398D0006
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:09 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so6043409eek.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:08 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 16/33] sched, numa, mm: Add credits for NUMA placement
Date: Thu, 22 Nov 2012 23:49:37 +0100
Message-Id: <1353624594-1118-17-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Rik van Riel <riel@redhat.com>

The NUMA placement code has been rewritten several times, but
the basic ideas took a lot of work to develop. The people who
put in the work deserve credit for it. Thanks Andrea & Peter :)

[ The Documentation/scheduler/numa-problem.txt file should
  probably be rewritten once we figure out the final details of
  what the NUMA code needs to do, and why. ]

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Hugh Dickins <hughd@google.com>
Link: http://lkml.kernel.org/r/20121018171928.24d06af4@cuia.bos.redhat.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
----
This is against tip.git numa/core
---
 CREDITS             | 1 +
 kernel/sched/fair.c | 3 +++
 mm/memory.c         | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/CREDITS b/CREDITS
index d8fe12a..b4cdc8f 100644
--- a/CREDITS
+++ b/CREDITS
@@ -125,6 +125,7 @@ D: Author of pscan that helps to fix lp/parport bugs
 D: Author of lil (Linux Interrupt Latency benchmark)
 D: Fixed the shm swap deallocation at swapoff time (try_to_unuse message)
 D: VM hacker
+D: NUMA task placement
 D: Various other kernel hacks
 S: Imola 40026
 S: Italy
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 511fbb8..8af0208 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -18,6 +18,9 @@
  *
  *  Adaptive scheduling granularity, math enhancements by Peter Zijlstra
  *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ *  NUMA placement, statistics and algorithm by Andrea Arcangeli,
+ *  CFS balancing changes by Peter Zijlstra. Copyright (C) 2012 Red Hat, Inc.
  */
 
 #include <linux/latencytop.h>
diff --git a/mm/memory.c b/mm/memory.c
index 52ad29d..1f733dc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -36,6 +36,8 @@
  *		(Gerhard.Wichert@pdb.siemens.de)
  *
  * Aug/Sep 2004 Changed to four level page tables (Andi Kleen)
+ *
+ * 2012 - NUMA placement page faults (Andrea Arcangeli, Peter Zijlstra)
  */
 
 #include <linux/kernel_stat.h>
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
