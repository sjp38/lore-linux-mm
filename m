Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 451376B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 16:54:44 -0500 (EST)
Received: by gyg10 with SMTP id 10so7536236gyg.14
        for <linux-mm@kvack.org>; Mon, 07 Nov 2011 13:54:42 -0800 (PST)
Date: Mon, 7 Nov 2011 13:54:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: do not kill tasks with oom_score_adj
 OOM_SCORE_ADJ_MIN
In-Reply-To: <20111104143145.0F93B8B45E@mx2.suse.de>
Message-ID: <alpine.DEB.2.00.1111071353140.27419@chino.kir.corp.google.com>
References: <20111104143145.0F93B8B45E@mx2.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 4 Nov 2011, Michal Hocko wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index e916168..4883514 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -185,6 +185,9 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	if (!p)
>  		return 0;
>  
> +	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +		return 0;
> +
>  	/*
>  	 * The memory controller may have a limit of 0 bytes, so avoid a divide
>  	 * by zero, if necessary.

This leaves p locked, you need to do task_unlock(p) first.

Once that's fixed, please add my

	Acked-by: David Rientjes <rientjes@google.com>

and resubmit to Andrew for the 3.2 rc series.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
