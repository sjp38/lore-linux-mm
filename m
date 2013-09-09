Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id B5BE96B0034
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 16:22:21 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so6594997pbc.37
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 13:22:21 -0700 (PDT)
Date: Mon, 9 Sep 2013 13:22:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, memcg: add a helper function to check may oom
 condition
In-Reply-To: <522D2FE5.3080606@huawei.com>
Message-ID: <alpine.DEB.2.02.1309091317570.16291@chino.kir.corp.google.com>
References: <522D2FE5.3080606@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, hannes@cmpxchg.org, Li Zefan <lizefan@huawei.com>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 9 Sep 2013, Qiang Huang wrote:

> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index da60007..d061c63 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -82,6 +82,11 @@ static inline void oom_killer_enable(void)
>  	oom_killer_disabled = false;
>  }
> 
> +static inline bool may_oom(gfp_t gfp_mask)

Makes sense, but I think the name should be more specific to gfp flags to 
make it clear what it's using to determine eligibility, maybe oom_gfp_allowed()? 
We usually prefix oom killer functions with "oom".

Nice taste.

> +{
> +	return (gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY);
> +}
> +
>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
> 
>  /* sysctls */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
