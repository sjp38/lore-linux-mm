Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 525356B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 02:56:34 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l9so444697wre.12
        for <linux-mm@kvack.org>; Tue, 16 May 2017 23:56:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 14si1172119wrb.329.2017.05.16.23.56.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 23:56:33 -0700 (PDT)
Subject: Re: [patch V2 15/17] mm/vmscan: Adjust system_state checks
References: <20170516184231.564888231@linutronix.de>
 <20170516184736.119158930@linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f2c2e6d1-4347-e57a-449f-531d5c31965c@suse.cz>
Date: Wed, 17 May 2017 08:56:31 +0200
MIME-Version: 1.0
In-Reply-To: <20170516184736.119158930@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Mark Rutland <mark.rutland@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On 05/16/2017 08:42 PM, Thomas Gleixner wrote:
> To enable smp_processor_id() and might_sleep() debug checks earlier, it's
> required to add system states between SYSTEM_BOOTING and SYSTEM_RUNNING.
> 
> Adjust the system_state check in kswapd_run() to handle the extra states.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: linux-mm@kvack.org

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/vmscan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3643,7 +3643,7 @@ int kswapd_run(int nid)
>  	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
>  	if (IS_ERR(pgdat->kswapd)) {
>  		/* failure at boot is fatal */
> -		BUG_ON(system_state == SYSTEM_BOOTING);
> +		BUG_ON(system_state < SYSTEM_RUNNING);
>  		pr_err("Failed to start kswapd on node %d\n", nid);
>  		ret = PTR_ERR(pgdat->kswapd);
>  		pgdat->kswapd = NULL;
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
