Subject: Re: [patch 3/7] mm: speculative page references
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080605094825.699347000@nick.local0.net>
References: <20080605094300.295184000@nick.local0.net>
	 <20080605094825.699347000@nick.local0.net>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 16:20:04 +0200
Message-Id: <1212762004.23439.119.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, Paul E McKenney <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-06-05 at 19:43 +1000, npiggin@suse.de wrote:
> plain text document attachment (mm-speculative-get_page-hugh.patch)

> +static inline int page_cache_get_speculative(struct page *page)
> +{
> +	VM_BUG_ON(in_interrupt());
> +
> +#ifndef CONFIG_SMP
> +# ifdef CONFIG_PREEMPT
> +	VM_BUG_ON(!in_atomic());
> +# endif
> +	/*
> +	 * Preempt must be disabled here - we rely on rcu_read_lock doing
> +	 * this for us.

Preemptible RCU is already in the tree, so I guess you'll have to
explcitly disable preemption if you require it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
