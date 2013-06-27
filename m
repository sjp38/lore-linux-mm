Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 256456B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 11:57:57 -0400 (EDT)
Date: Thu, 27 Jun 2013 17:57:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/8] sched: Track NUMA hinting faults on per-node basis
Message-ID: <20130627155748.GX28407@twins.programming.kicks-ass.net>
References: <1372257487-9749-1-git-send-email-mgorman@suse.de>
 <1372257487-9749-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372257487-9749-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 26, 2013 at 03:38:01PM +0100, Mel Gorman wrote:
> @@ -503,6 +503,18 @@ DECLARE_PER_CPU(struct rq, runqueues);
>  #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
>  #define raw_rq()		(&__raw_get_cpu_var(runqueues))
>  
> +#ifdef CONFIG_NUMA_BALANCING
> +extern void sched_setnuma(struct task_struct *p, int node, int shared);

Stray line; you're introducing that function later with a different
signature.

> +static inline void task_numa_free(struct task_struct *p)
> +{
> +	kfree(p->numa_faults);
> +}
> +#else /* CONFIG_NUMA_BALANCING */
> +static inline void task_numa_free(struct task_struct *p)
> +{
> +}
> +#endif /* CONFIG_NUMA_BALANCING */
> +
>  #ifdef CONFIG_SMP
>  
>  #define rcu_dereference_check_sched_domain(p) \
> -- 
> 1.8.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
