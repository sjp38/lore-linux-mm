Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 85C756B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:37:34 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id w144so21981247wmw.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:37:34 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id gy4si18554534wjc.133.2015.12.10.04.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 04:37:33 -0800 (PST)
Received: by wmec201 with SMTP id c201so22897310wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:37:33 -0800 (PST)
Date: Thu, 10 Dec 2015 13:37:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/8] mm: memcontrol: drop unused @css argument in
 memcg_init_kmem
Message-ID: <20151210123732.GG19496@dhcp22.suse.cz>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449599665-18047-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 08-12-15 13:34:18, Johannes Weiner wrote:
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/net/tcp_memcontrol.h | 3 ++-
>  mm/memcontrol.c              | 6 +++---
>  net/ipv4/tcp_memcontrol.c    | 2 +-
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
> index 3a17b16..dc2da2f 100644
> --- a/include/net/tcp_memcontrol.h
> +++ b/include/net/tcp_memcontrol.h
> @@ -1,6 +1,7 @@
>  #ifndef _TCP_MEMCG_H
>  #define _TCP_MEMCG_H
>  
> -int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
> +int tcp_init_cgroup(struct mem_cgroup *memcg);
>  void tcp_destroy_cgroup(struct mem_cgroup *memcg);
> +
>  #endif /* _TCP_MEMCG_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5fe45d68..eda8d43 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3561,7 +3561,7 @@ static int mem_cgroup_oom_control_write(struct cgroup_subsys_state *css,
>  }
>  
>  #ifdef CONFIG_MEMCG_KMEM
> -static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> +static int memcg_init_kmem(struct mem_cgroup *memcg)
>  {
>  	int ret;
>  
> @@ -3569,7 +3569,7 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  	if (ret)
>  		return ret;
>  
> -	return tcp_init_cgroup(memcg, ss);
> +	return tcp_init_cgroup(memcg);
>  }
>  
>  static void memcg_deactivate_kmem(struct mem_cgroup *memcg)
> @@ -4252,7 +4252,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	}
>  	mutex_unlock(&memcg_create_mutex);
>  
> -	ret = memcg_init_kmem(memcg, &memory_cgrp_subsys);
> +	ret = memcg_init_kmem(memcg);
>  	if (ret)
>  		return ret;
>  
> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
> index 18bc7f7..133eb5e 100644
> --- a/net/ipv4/tcp_memcontrol.c
> +++ b/net/ipv4/tcp_memcontrol.c
> @@ -6,7 +6,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/module.h>
>  
> -int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
> +int tcp_init_cgroup(struct mem_cgroup *memcg)
>  {
>  	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
>  	struct page_counter *counter_parent = NULL;
> -- 
> 2.6.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
