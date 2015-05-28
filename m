Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2646B006C
	for <linux-mm@kvack.org>; Thu, 28 May 2015 09:03:41 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so145779391wic.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 06:03:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb7si4584751wid.20.2015.05.28.06.03.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 May 2015 06:03:37 -0700 (PDT)
Date: Thu, 28 May 2015 15:03:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] OOM: print points as unsigned int
Message-ID: <20150528130324.GD9540@dhcp22.suse.cz>
References: <1432806404-223203-1-git-send-email-long.wanglong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432806404-223203-1-git-send-email-long.wanglong@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <long.wanglong@huawei.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, hannes@cmpxchg.org, oleg@redhat.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wanglong@laoqinren.net, peifeiyue@huawei.com

On Thu 28-05-15 09:46:44, Wang Long wrote:
> In oom_kill_process(), the variable 'points' is unsigned int.
> Print it as such.
> 
> Signed-off-by: Wang Long <long.wanglong@huawei.com>

I do not think this matter much in the real life but there is no reason
to use a wrong format type.

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/oom_kill.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 2b665da..056002c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -528,7 +528,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		dump_header(p, gfp_mask, order, memcg, nodemask);
>  
>  	task_lock(p);
> -	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
> +	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
>  		message, task_pid_nr(p), p->comm, points);
>  	task_unlock(p);
>  
> -- 
> 1.8.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
