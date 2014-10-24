Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8D69F6B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 14:29:15 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so1676042wgh.35
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:29:15 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id xb3si6140577wjb.53.2014.10.24.11.29.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 11:29:14 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id k14so1655578wgh.31
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 11:29:13 -0700 (PDT)
Date: Fri, 24 Oct 2014 20:29:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: remove bogus NULL check after
 mem_cgroup_from_task()
Message-ID: <20141024182911.GA18956@dhcp22.suse.cz>
References: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 24-10-14 09:49:47, Johannes Weiner wrote:
> That function acts like a typecast - unless NULL is passed in, no NULL
> can come out.  task_in_mem_cgroup() callers don't pass NULL tasks.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks and sorry about my bogus version earlier today.

Acked-by: Michal Hocko <mhocko@suse.cz

> ---
>  mm/memcontrol.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 23cf27cca370..bdf8520979cf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1335,7 +1335,7 @@ static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  bool task_in_mem_cgroup(struct task_struct *task,
>  			const struct mem_cgroup *memcg)
>  {
> -	struct mem_cgroup *curr = NULL;
> +	struct mem_cgroup *curr;
>  	struct task_struct *p;
>  	bool ret;
>  
> @@ -1351,8 +1351,7 @@ bool task_in_mem_cgroup(struct task_struct *task,
>  		 */
>  		rcu_read_lock();
>  		curr = mem_cgroup_from_task(task);
> -		if (curr)
> -			css_get(&curr->css);
> +		css_get(&curr->css);
>  		rcu_read_unlock();
>  	}
>  	/*
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
