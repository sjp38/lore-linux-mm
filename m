Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AB7956B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 08:06:03 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so965412pab.4
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 05:06:03 -0700 (PDT)
Date: Wed, 9 Oct 2013 14:05:44 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009120544.GE3081@twins.programming.kicks-ass.net>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009110353.GA19370@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009110353.GA19370@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 09, 2013 at 01:03:54PM +0200, Ingo Molnar wrote:
>  kernel/sched/fair.c:819:22: warning: 'task_h_load' declared 'static' but never defined [-Wunused-function]

Not too pretty, but it avoids the warning:

---
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -681,6 +681,8 @@ static u64 sched_vslice(struct cfs_rq *c
 }
 
 #ifdef CONFIG_SMP
+static unsigned long task_h_load(struct task_struct *p);
+
 static inline void __update_task_entity_contrib(struct sched_entity *se);
 
 /* Give new task start runnable values to heavy its load in infant time */
@@ -816,8 +818,6 @@ update_stats_curr_start(struct cfs_rq *c
  * Scheduling class queueing methods:
  */
 
-static unsigned long task_h_load(struct task_struct *p);
-
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * Approximate time to scan a full NUMA task in ms. The task scan period is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
