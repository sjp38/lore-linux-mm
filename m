Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B05B86B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 02:49:35 -0400 (EDT)
Date: Tue, 9 Apr 2013 08:49:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/8] memcg: convert to use cgroup_is_ancestor()
Message-ID: <20130409064934.GA30386@dhcp22.suse.cz>
References: <51627DA9.7020507@huawei.com>
 <51627DFA.9050007@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627DFA.9050007@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon 08-04-13 16:21:14, Li Zefan wrote:
> This is a preparation to kill css_id.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5aa6e91..14f1375 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1383,7 +1383,7 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  		return true;
>  	if (!root_memcg->use_hierarchy || !memcg)
>  		return false;
> -	return css_is_ancestor(&memcg->css, &root_memcg->css);
> +	return cgroup_is_ancestor(memcg->css.cgroup, root_memcg->css.cgroup);
>  }
>  
>  static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> -- 
> 1.8.0.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
