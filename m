Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id A20156B005C
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 07:11:44 -0400 (EDT)
Date: Fri, 1 Jun 2012 13:11:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] rename MEM_CGROUP_STAT_SWAPOUT as MEM_CGROUP_STAT_NR_SWAP
Message-ID: <20120601111142.GF30196@tiehlicka.suse.cz>
References: <4FC89BC4.9030604@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FC89BC4.9030604@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, hannes@cmpxchg.org, akpm@linux-foundation.org

On Fri 01-06-12 19:39:00, KAMEZAWA Hiroyuki wrote:
> MEM_CGROUP_STAT_SWAPOUT represents the usage of swap rather than
> the number of swap-out events. Rename it to be MEM_CGROUP_STAT_NR_SWAP.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0121ef3..76bc54c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -97,7 +97,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
>  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> -	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_NR_SWAP, /* # of pages, swapped out */
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> @@ -722,7 +722,7 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
>  					 bool charge)
>  {
>  	int val = (charge) ? 1 : -1;
> -	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
> +	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_NR_SWAP], val);
>  }
>  
>  static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
> @@ -4042,7 +4042,7 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  	val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
>  
>  	if (swap)
> -		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_SWAPOUT);
> +		val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_NR_SWAP);
>  
>  	return val << PAGE_SHIFT;
>  }
> @@ -4303,7 +4303,7 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  	unsigned int i;
>  
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> -		if (i == MEM_CGROUP_STAT_SWAPOUT && !do_swap_account)
> +		if (i == MEM_CGROUP_STAT_NR_SWAP && !do_swap_account)
>  			continue;
>  		seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
>  			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
> @@ -4330,7 +4330,7 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>  		long long val = 0;
>  
> -		if (i == MEM_CGROUP_STAT_SWAPOUT && !do_swap_account)
> +		if (i == MEM_CGROUP_STAT_NR_SWAP && !do_swap_account)
>  			continue;
>  		for_each_mem_cgroup_tree(mi, memcg)
>  			val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
