Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6104C6B0069
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:37:56 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id d49so2432498eek.5
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:37:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 5si16004734eei.81.2013.12.10.12.37.55
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 12:37:55 -0800 (PST)
Date: Tue, 10 Dec 2013 15:37:27 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386707847-amnateda-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386667175-19952-9-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386667175-19952-9-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 09/12] sched/numa: fix period_slot recalculation
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 05:19:32PM +0800, Wanpeng Li wrote:
> Changelog:
>  v3 -> v4:
>   * remove period_slot recalculation
> 
> The original code is as intended and was meant to scale the difference
> between the NUMA_PERIOD_THRESHOLD and local/remote ratio when adjusting
> the scan period. The period_slot recalculation can be dropped.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya

> ---
>  kernel/sched/fair.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 7073c76..90b9b88 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1356,7 +1356,6 @@ static void update_task_scan_period(struct task_struct *p,
>  		 * scanning faster if shared accesses dominate as it may
>  		 * simply bounce migrations uselessly
>  		 */
> -		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
>  		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
>  		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
>  	}
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
