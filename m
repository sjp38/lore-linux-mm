Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB016B0062
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:37:20 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hn6so5933117wib.4
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:37:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 10si2306435wjp.35.2013.12.10.12.37.19
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 12:37:19 -0800 (PST)
Date: Tue, 10 Dec 2013 15:36:52 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386707812-t48rtxql-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386667175-19952-8-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386667175-19952-8-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 08/12] sched/numa: use wrapper function task_faults_idx
 to calculate index in group_faults
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 05:19:31PM +0800, Wanpeng Li wrote:
> Use wrapper function task_faults_idx to calculate index in group_faults.

yes, it syncs group_faults() with task_faults().

> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  kernel/sched/fair.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index e0b1063..7073c76 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -935,7 +935,8 @@ static inline unsigned long group_faults(struct task_struct *p, int nid)
>  	if (!p->numa_group)
>  		return 0;
>  
> -	return p->numa_group->faults[2*nid] + p->numa_group->faults[2*nid+1];
> +	return p->numa_group->faults[task_faults_idx(nid, 0)] +
> +		p->numa_group->faults[task_faults_idx(nid, 1)];
>  }
>  
>  /*
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
