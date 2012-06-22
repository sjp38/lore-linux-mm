Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 97ED46B0171
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:32:47 -0400 (EDT)
Date: Fri, 22 Jun 2012 14:32:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: cleanup typos in mem cgroup
Message-ID: <20120622123244.GD4814@tiehlicka.suse.cz>
References: <1340366474-28228-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340366474-28228-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri 22-06-12 20:01:14, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> 
> ---
>  mm/memcontrol.c |   12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 776fc57..9e3c74a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -115,8 +115,8 @@ static const char * const mem_cgroup_events_names[] = {
>  
>  /*
>   * Per memcg event counter is incremented at every pagein/pageout. With THP,
> - * it will be incremated by the number of pages. This counter is used for
> - * for trigger some periodic events. This is straightforward and better
> + * it will be incremented by the number of pages. This counter is used for

.... is used to trigger ....

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
> @@ -2213,7 +2213,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (mem_cgroup_wait_acct_move(mem_over_limit))
>  		return CHARGE_RETRY;
>  
> -	/* If we don't need to call oom-killer at el, return immediately */
> +	/* If we don't need to call oom-killer at all, return immediately */

I think the whole comment should rather go away.

>  	if (!oom_check)
>  		return CHARGE_NOMEM;
>  	/* check OOM */

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
