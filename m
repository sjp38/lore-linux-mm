Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EA5346B0070
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 10:41:11 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so1567973pdb.11
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 07:41:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id y4si4465126pdn.6.2014.10.24.07.41.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 07:41:10 -0700 (PDT)
Date: Fri, 24 Oct 2014 18:41:01 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/3] mm: memcontrol: remove bogus NULL check after
 mem_cgroup_from_task()
Message-ID: <20141024144101.GA28055@esperanza>
References: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1414158589-26094-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Oct 24, 2014 at 09:49:47AM -0400, Johannes Weiner wrote:
> That function acts like a typecast - unless NULL is passed in, no NULL
> can come out.  task_in_mem_cgroup() callers don't pass NULL tasks.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
