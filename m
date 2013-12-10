Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 89EC66B003B
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 02:12:00 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id z2so4948823wiv.1
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 23:12:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cw10si502199wib.61.2013.12.09.23.11.59
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 23:11:59 -0800 (PST)
Date: Tue, 10 Dec 2013 02:11:24 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386659484-8nauy0i4-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386483293-15354-11-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-11-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 11/12] sched/numa: drop unnecessary variable in
 task_weight
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Dec 08, 2013 at 02:14:52PM +0800, Wanpeng Li wrote:
> Drop unnecessary total_faults variable in function task_weight to unify
> task_weight and group_weight.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  kernel/sched/fair.c |   11 ++---------
>  1 files changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index 942e67b..df8b677 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -947,17 +947,10 @@ static inline unsigned long group_faults(struct task_struct *p, int nid)
>   */
>  static inline unsigned long task_weight(struct task_struct *p, int nid)
>  {
> -	unsigned long total_faults;
> -
> -	if (!p->numa_faults)
> -		return 0;
> -
> -	total_faults = p->total_numa_faults;
> -
> -	if (!total_faults)
> +	if (!p->numa_faults || !p->total_numa_faults)
>  		return 0;
>  
> -	return 1000 * task_faults(p, nid) / total_faults;
> +	return 1000 * task_faults(p, nid) / p->total_numa_faults;
>  }
>  
>  static inline unsigned long group_weight(struct task_struct *p, int nid)
> -- 
> 1.7.5.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
