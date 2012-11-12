Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 950066B006E
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 11:23:22 -0500 (EST)
Message-Id: <20121112161215.584642205@chello.nl>
Date: Mon, 12 Nov 2012 17:04:54 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/8] sched, numa, mm: Add credits for NUMA placement
References: <20121112160451.189715188@chello.nl>
Content-Disposition: inline; filename=0003-sched-numa-mm-Add-credits-for-NUMA-placement.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

The NUMA placement code has been rewritten several times, but
the basic ideas took a lot of work to develop. The people who
put in the work deserve credit for it. Thanks Andrea & Peter :)

[ The Documentation/scheduler/numa-problem.txt file should
  probably be rewritten once we figure out the final details of
  what the NUMA code needs to do, and why. ]

Signed-off-by: Rik van Riel <riel@redhat.com>
Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
----
This is against tip.git numa/core
---
 CREDITS             |    1 +
 kernel/sched/fair.c |    3 +++
 mm/memory.c         |    2 ++
 3 files changed, 6 insertions(+)

Index: linux/CREDITS
===================================================================
--- linux.orig/CREDITS
+++ linux/CREDITS
@@ -125,6 +125,7 @@ D: Author of pscan that helps to fix lp/
 D: Author of lil (Linux Interrupt Latency benchmark)
 D: Fixed the shm swap deallocation at swapoff time (try_to_unuse message)
 D: VM hacker
+D: NUMA task placement
 D: Various other kernel hacks
 S: Imola 40026
 S: Italy
Index: linux/kernel/sched/fair.c
===================================================================
--- linux.orig/kernel/sched/fair.c
+++ linux/kernel/sched/fair.c
@@ -18,6 +18,9 @@
  *
  *  Adaptive scheduling granularity, math enhancements by Peter Zijlstra
  *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ *  NUMA placement, statistics and algorithm by Andrea Arcangeli,
+ *  CFS balancing changes by Peter Zijlstra. Copyright (C) 2012 Red Hat, Inc.
  */
 
 #include <linux/latencytop.h>
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c
+++ linux/mm/memory.c
@@ -36,6 +36,8 @@
  *		(Gerhard.Wichert@pdb.siemens.de)
  *
  * Aug/Sep 2004 Changed to four level page tables (Andi Kleen)
+ *
+ * 2012 - NUMA placement page faults (Andrea Arcangeli, Peter Zijlstra)
  */
 
 #include <linux/kernel_stat.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
