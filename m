Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id E480F6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 05:29:27 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p65so11624092wmp.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:29:27 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id k71si1949656wmd.15.2016.03.11.02.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 02:29:26 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id l68so12247639wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:29:26 -0800 (PST)
Date: Fri, 11 Mar 2016 11:29:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: zap oom_info_lock
Message-ID: <20160311102925.GG27701@dhcp22.suse.cz>
References: <1457691083-22655-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457691083-22655-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 11-03-16 13:11:23, Vladimir Davydov wrote:
> mem_cgroup_print_oom_info is always called under oom_lock, so
> oom_info_lock is redundant.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fa7bf354ae32..36db05fa8acb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1150,12 +1150,9 @@ static bool mem_cgroup_wait_acct_move(struct mem_cgroup *memcg)
>   */
>  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> -	/* oom_info_lock ensures that parallel ooms do not interleave */
> -	static DEFINE_MUTEX(oom_info_lock);
>  	struct mem_cgroup *iter;
>  	unsigned int i;
>  
> -	mutex_lock(&oom_info_lock);
>  	rcu_read_lock();
>  
>  	if (p) {
> @@ -1199,7 +1196,6 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  
>  		pr_cont("\n");
>  	}
> -	mutex_unlock(&oom_info_lock);
>  }
>  
>  /*
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
