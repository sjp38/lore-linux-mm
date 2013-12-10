Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id D48196B0039
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 02:01:41 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id w62so4554122wes.31
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 23:01:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bj10si6260472wjb.141.2013.12.09.23.01.39
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 23:01:40 -0800 (PST)
Date: Tue, 10 Dec 2013 02:01:09 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386658869-2gttr64d-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386483293-15354-10-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-10-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 10/12] sched/numa: fix record hinting faults check
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Dec 08, 2013 at 02:14:51PM +0800, Wanpeng Li wrote:
> Adjust numa_scan_period in task_numa_placement, depending on how much useful
> work the numa code can do. The local faults and remote faults should be used
> to check if there is record hinting faults instead of local faults and shared
> faults. This patch fix it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  kernel/sched/fair.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index b077f1b3..942e67b 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1322,7 +1322,7 @@ static void update_task_scan_period(struct task_struct *p,
>  	 * completely idle or all activity is areas that are not of interest
>  	 * to automatic numa balancing. Scan slower
>  	 */
> -	if (local + shared == 0) {
> +	if (local + remote == 0) {
>  		p->numa_scan_period = min(p->numa_scan_period_max,
>  			p->numa_scan_period << 1);
>  
> -- 
> 1.7.5.4
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
