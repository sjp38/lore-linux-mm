Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 536AF6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 08:48:51 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so873371pdj.12
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 05:48:51 -0700 (PDT)
Received: by mail-ea0-f174.google.com with SMTP id z15so381983ead.33
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 05:48:47 -0700 (PDT)
Date: Wed, 9 Oct 2013 14:48:44 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/63] Basic scheduler support for automatic NUMA
 balancing V9
Message-ID: <20131009124844.GA21428@gmail.com>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
 <20131009110353.GA19370@gmail.com>
 <20131009120544.GE3081@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131009120544.GE3081@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Wed, Oct 09, 2013 at 01:03:54PM +0200, Ingo Molnar wrote:
> >  kernel/sched/fair.c:819:22: warning: 'task_h_load' declared 'static' but never defined [-Wunused-function]
> 
> Not too pretty, but it avoids the warning:
> 
> ---
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -681,6 +681,8 @@ static u64 sched_vslice(struct cfs_rq *c
>  }
>  
>  #ifdef CONFIG_SMP
> +static unsigned long task_h_load(struct task_struct *p);
> +
>  static inline void __update_task_entity_contrib(struct sched_entity *se);
>  
>  /* Give new task start runnable values to heavy its load in infant time */
> @@ -816,8 +818,6 @@ update_stats_curr_start(struct cfs_rq *c
>   * Scheduling class queueing methods:
>   */
>  
> -static unsigned long task_h_load(struct task_struct *p);
> -
>  #ifdef CONFIG_NUMA_BALANCING

Hm, so we really want to do a split-up of this file once things have 
calmed down - that will address such dependency issues.

Until then this fix will do, I've backmerged it to the originating patch.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
