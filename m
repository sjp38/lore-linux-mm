Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C23816B0083
	for <linux-mm@kvack.org>; Mon, 28 May 2012 09:39:22 -0400 (EDT)
Date: Mon, 28 May 2012 15:39:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove the unnecessary MEM_CGROUP_STAT_DATA
Message-ID: <20120528133918.GA22185@tiehlicka.suse.cz>
References: <1337933501-3985-1-git-send-email-baozich@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337933501-3985-1-git-send-email-baozich@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Baozi <baozich@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Fri 25-05-12 16:11:41, Chen Baozi wrote:
> Since MEM_CGROUP_ON_MOVE has been removed, it comes to be redudant
> to hold MEM_CGROUP_STAT_DATA to mark the end of data requires
> synchronization.

A similar patch has been already posted by Johannes 2 weeks ago
(http://www.gossamer-threads.com/lists/linux/kernel/1535888) and it
should appear in -next soonish.

> 
> Signed-off-by: Chen Baozi <baozich@gmail.com>
> ---
>  mm/memcontrol.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f342778..446ca94 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -88,7 +88,6 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
>  	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> -	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> @@ -2139,7 +2138,7 @@ static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *memcg, int cpu)
>  	int i;
>  
>  	spin_lock(&memcg->pcp_counter_lock);
> -	for (i = 0; i < MEM_CGROUP_STAT_DATA; i++) {
> +	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>  		long x = per_cpu(memcg->stat->count[i], cpu);
>  
>  		per_cpu(memcg->stat->count[i], cpu) = 0;
> -- 
> 1.7.1
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
