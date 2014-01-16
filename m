Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f172.google.com (mail-gg0-f172.google.com [209.85.161.172])
	by kanga.kvack.org (Postfix) with ESMTP id 72D6E6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 18:22:18 -0500 (EST)
Received: by mail-gg0-f172.google.com with SMTP id x14so1087406ggx.3
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:22:18 -0800 (PST)
Received: from mail-yh0-x229.google.com (mail-yh0-x229.google.com [2607:f8b0:4002:c01::229])
        by mx.google.com with ESMTPS id j50si6734010yhc.250.2014.01.16.15.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 15:22:17 -0800 (PST)
Received: by mail-yh0-f41.google.com with SMTP id i7so438482yha.0
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 15:22:16 -0800 (PST)
Date: Thu, 16 Jan 2014 15:22:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: vmstat: Do not display stats for TLB flushes unless
 debugging
In-Reply-To: <20140116111205.GN4963@suse.de>
Message-ID: <alpine.DEB.2.02.1401161515540.4182@chino.kir.corp.google.com>
References: <1389278098-27154-1-git-send-email-mgorman@suse.de> <1389278098-27154-2-git-send-email-mgorman@suse.de> <20140116111205.GN4963@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 16 Jan 2014, Mel Gorman wrote:

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7249614..def5dd2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -851,12 +851,14 @@ const char * const vmstat_text[] = {
>  	"thp_zero_page_alloc",
>  	"thp_zero_page_alloc_failed",
>  #endif
> +#ifdef CONFIG_DEBUG_TLBFLUSH
>  #ifdef CONFIG_SMP
>  	"nr_tlb_remote_flush",
>  	"nr_tlb_remote_flush_received",
> -#endif
> +#endif /* CONFIG_SMP */
>  	"nr_tlb_local_flush_all",
>  	"nr_tlb_local_flush_one",
> +#endif /* CONFIG_DEBUG_TLBFLUSH */
>  
>  #endif /* CONFIG_VM_EVENTS_COUNTERS */
>  };

Hmm, so why are NR_TLB_REMOTE_FLUSH{,_RECEIVED} defined for !CONFIG_SMP in 
linux-next?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
