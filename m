Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 13A616B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:02:07 -0400 (EDT)
Date: Thu, 25 Jul 2013 10:02:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove redundant code in
 mem_cgroup_force_empty_write()
Message-ID: <20130725080205.GE12818@dhcp22.suse.cz>
References: <51F08505.6050402@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F08505.6050402@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Thu 25-07-13 09:53:09, Li Zefan wrote:
> vfs guarantees the cgroup won't be destroyed, so it's redundant
> to get a css reference.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/memcontrol.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 03c8bf7..aa3e478 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5015,15 +5015,10 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> -	int ret;
>  
>  	if (mem_cgroup_is_root(memcg))
>  		return -EINVAL;
> -	css_get(&memcg->css);
> -	ret = mem_cgroup_force_empty(memcg);
> -	css_put(&memcg->css);
> -
> -	return ret;
> +	return mem_cgroup_force_empty(memcg);
>  }
>  
>  
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
