Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 4C4656B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 05:39:31 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c4so953544eek.10
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 02:39:29 -0700 (PDT)
Date: Mon, 1 Apr 2013 11:39:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: avoid accessing memcg after releasing reference
Message-ID: <20130401093927.GB30749@dhcp22.suse.cz>
References: <5158F344.9020509@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5158F344.9020509@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Mon 01-04-13 10:39:00, Li Zefan wrote:
> This might cause use-after-free bug.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
> found when reading the code.
> 
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8ec501c..6391046 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3186,12 +3186,12 @@ void memcg_release_cache(struct kmem_cache *s)
>  
>  	root = s->memcg_params->root_cache;
>  	root->memcg_params->memcg_caches[id] = NULL;
> -	mem_cgroup_put(memcg);
>  
>  	mutex_lock(&memcg->slab_caches_mutex);
>  	list_del(&s->memcg_params->list);
>  	mutex_unlock(&memcg->slab_caches_mutex);
>  
> +	mem_cgroup_put(memcg);
>  out:
>  	kfree(s->memcg_params);
>  }
> -- 
> 1.8.0.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
