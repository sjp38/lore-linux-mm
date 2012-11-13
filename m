Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 9D70F6B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:56:06 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3430190eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 03:56:05 -0800 (PST)
Date: Tue, 13 Nov 2012 12:55:56 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4/8] sched, numa, mm: Add last_cpu to page flags
Message-ID: <20121113115556.GG21522@gmail.com>
References: <20121112160451.189715188@chello.nl>
 <20121112161215.685202629@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121112161215.685202629@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>


A cleanliness side note, this bit does not belong into this 
patch:

> Index: linux/include/linux/mm_types.h
> ===================================================================
> --- linux.orig/include/linux/mm_types.h
> +++ linux/include/linux/mm_types.h
> @@ -398,6 +403,10 @@ struct mm_struct {
>  #ifdef CONFIG_CPUMASK_OFFSTACK
>  	struct cpumask cpumask_allocation;
>  #endif
> +#ifdef CONFIG_SCHED_NUMA
> +	unsigned long numa_next_scan;
> +	int numa_scan_seq;
> +#endif
>  	struct uprobes_state uprobes_state;
>  };
>  

I've moved it over into the 5th patch.

Thanks,	

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
