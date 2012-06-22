Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 508926B0205
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 11:04:05 -0400 (EDT)
Date: Fri, 22 Jun 2012 17:03:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2] memcg: cleanup typos in mem cgroup
Message-ID: <20120622150358.GB16628@tiehlicka.suse.cz>
References: <1340369199-29535-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340369199-29535-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

Have you used any tool to find those typos? Have you gone through the
whole memcontrol.c file?
I am not agains fixes like this but I would much prefer if it was one
batch of all fixes. I bet there are more typose ;)

On Fri 22-06-12 20:46:39, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> ---
>  mm/memcontrol.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 776fc57..503ddd0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -115,8 +115,8 @@ static const char * const mem_cgroup_events_names[] = {
>  
>  /*
>   * Per memcg event counter is incremented at every pagein/pageout. With THP,
> - * it will be incremated by the number of pages. This counter is used for
> - * for trigger some periodic events. This is straightforward and better
> + * it will be incremented by the number of pages. This counter is used to
> + * trigger some periodic events. This is straightforward and better
>   * than using jiffies etc. to handle periodic memcg event.
>   */
>  enum mem_cgroup_events_target {
> @@ -678,7 +678,7 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_zone *mctz)
>   *
>   * If there are kernel internal actions which can make use of some not-exact
>   * value, and reading all cpu value can be performance bottleneck in some
> - * common workload, threashold and synchonization as vmstat[] should be
> + * common workload, threshold and synchonization as vmstat[] should be
>   * implemented.
>   */
>  static long mem_cgroup_read_stat(struct mem_cgroup *memcg,
> @@ -2213,7 +2213,6 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (mem_cgroup_wait_acct_move(mem_over_limit))
>  		return CHARGE_RETRY;
>  
> -	/* If we don't need to call oom-killer at el, return immediately */
>  	if (!oom_check)
>  		return CHARGE_NOMEM;
>  	/* check OOM */
> @@ -2291,7 +2290,7 @@ again:
>  		 * In that case, "memcg" can point to root or p can be NULL with
>  		 * race with swapoff. Then, we have small risk of mis-accouning.
>  		 * But such kind of mis-account by race always happens because
> -		 * we don't have cgroup_mutex(). It's overkill and we allo that
> +		 * we don't have cgroup_mutex(). It's overkill and we allow that
>  		 * small race, here.
>  		 * (*) swapoff at el will charge against mm-struct not against
>  		 * task-struct. So, mm->owner can be NULL.
> @@ -2396,7 +2395,7 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
>  }
>  
>  /*
> - * Cancel chrages in this cgroup....doesn't propagate to parent cgroup.
> + * Cancel charges in this cgroup....doesn't propagate to parent cgroup.
>   * This is useful when moving usage to parent cgroup.
>   */
>  static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
