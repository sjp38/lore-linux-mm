Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 20B4C6B016B
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:34:08 -0400 (EDT)
Date: Tue, 26 Jun 2012 10:34:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm, oom: move declaration for
 mem_cgroup_out_of_memory to oom.h
Message-ID: <20120626083405.GA9566@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 25-06-12 18:47:46, David Rientjes wrote:
> mem_cgroup_out_of_memory() is defined in mm/oom_kill.c, so declare it in
> linux/oom.h rather than linux/memcontrol.h.

Makes sense
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h |    2 --
>  include/linux/oom.h        |    2 ++
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -72,8 +72,6 @@ extern void mem_cgroup_uncharge_end(void);
>  extern void mem_cgroup_uncharge_page(struct page *page);
>  extern void mem_cgroup_uncharge_cache_page(struct page *page);
>  
> -extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> -				     int order);
>  bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>  				  struct mem_cgroup *memcg);
>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -49,6 +49,8 @@ extern unsigned long oom_badness(struct task_struct *p,
>  extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  
> +extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> +				     int order);
>  extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		int order, nodemask_t *mask, bool force_kill);
>  extern int register_oom_notifier(struct notifier_block *nb);
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
