Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8448C6B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 08:40:07 -0500 (EST)
Date: Fri, 3 Feb 2012 14:39:50 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Handling of unused variable 'do-numainfo on compilation
 time
Message-ID: <20120203133950.GA1690@cmpxchg.org>
References: <1328258627-2241-1-git-send-email-geunsik.lim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1328258627-2241-1-git-send-email-geunsik.lim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Geunsik Lim <geunsik.lim@gmail.com>, linux-mm <linux-mm@kvack.org>

Michal, this keeps coming up, please decide between the proposed
solutions ;-)

On Fri, Feb 03, 2012 at 05:43:47PM +0900, Geunsik Lim wrote:
> Actually, Usage of the variable 'do_numainfo'is not suitable for gcc compiler.
> Declare the variable 'do_numainfo' if the number of NUMA nodes > 1.
> 
> Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
> ---
>  mm/memcontrol.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 556859f..4e17ac5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -776,7 +776,10 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>  	/* threshold event is triggered in finer grain than soft limit */
>  	if (unlikely(mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_THRESH))) {
> -		bool do_softlimit, do_numainfo;
> +		bool do_softlimit;
> +#if MAX_NUMNODES > 1
> +                bool do_numainfo;
> +#endif
>  
>  		do_softlimit = mem_cgroup_event_ratelimit(memcg,
>  						MEM_CGROUP_TARGET_SOFTLIMIT);
> -- 
> 1.7.8.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
