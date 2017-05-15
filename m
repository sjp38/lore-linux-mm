Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFD16B02F2
	for <linux-mm@kvack.org>; Mon, 15 May 2017 10:54:40 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s62so113552576pgc.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 07:54:40 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w9si10933160pls.254.2017.05.15.07.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 07:54:39 -0700 (PDT)
Date: Mon, 15 May 2017 10:54:36 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch 15/18] mm/vmscan: Adjust system_state checks
Message-ID: <20170515105436.276c59fe@gandalf.local.home>
In-Reply-To: <20170514183613.675463242@linutronix.de>
References: <20170514182716.347236777@linutronix.de>
	<20170514183613.675463242@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

On Sun, 14 May 2017 20:27:31 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> To enable smp_processor_id() and might_sleep() debug checks earlier, it's
> required to add system states between SYSTEM_BOOTING and SYSTEM_RUNNING.
> 
> Adjust the system_state check in kswapd_run() to handle the extra states.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: linux-mm@kvack.org
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
