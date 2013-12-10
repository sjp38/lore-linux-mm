Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 794C86B003D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 02:13:13 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id hn9so4943292wib.0
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 23:13:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w7si510611wie.33.2013.12.09.23.13.12
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 23:13:12 -0800 (PST)
Date: Tue, 10 Dec 2013 02:12:47 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386659567-rn8hjtqh-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386483293-15354-12-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-12-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 12/12] sched/numa: drop local 'ret' in
 task_numa_migrate()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Dec 08, 2013 at 02:14:53PM +0800, Wanpeng Li wrote:
> task_numa_migrate() has two locals called "ret". Fix it all up.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks!
Naoya

> ---
>  kernel/sched/fair.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
> index df8b677..3159ca7 100644
> --- a/kernel/sched/fair.c
> +++ b/kernel/sched/fair.c
> @@ -1257,7 +1257,7 @@ static int task_numa_migrate(struct task_struct *p)
>  	p->numa_scan_period = task_scan_min(p);
>  
>  	if (env.best_task == NULL) {
> -		int ret = migrate_task_to(p, env.best_cpu);
> +		ret = migrate_task_to(p, env.best_cpu);
>  		return ret;
>  	}
>  
> -- 
> 1.7.5.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
