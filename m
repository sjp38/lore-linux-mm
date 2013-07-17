Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 5AB476B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 06:54:30 -0400 (EDT)
Date: Wed, 17 Jul 2013 12:54:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 16/18] sched: Avoid overloading CPUs on a preferred NUMA
 node
Message-ID: <20130717105423.GC17211@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <1373901620-2021-17-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373901620-2021-17-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 15, 2013 at 04:20:18PM +0100, Mel Gorman wrote:
> +static long effective_load(struct task_group *tg, int cpu, long wl, long wg);

And this -- which suggests you always build with cgroups enabled? I generally
try and disable all that nonsense when building new stuff, the scheduler is a
'lot' simpler that way. Once that works make it 'interesting' again.

---

--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -3367,8 +3367,7 @@ static long effective_load(struct task_g
 }
 #else
 
-static unsigned long effective_load(struct task_group *tg, int cpu,
-		unsigned long wl, unsigned long wg)
+static long effective_load(struct task_group *tg, int cpu, long wl, long wg)
 {
 	return wl;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
