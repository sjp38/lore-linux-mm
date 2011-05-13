Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 52A69900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 05:23:14 -0400 (EDT)
Date: Fri, 13 May 2011 11:23:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [rfc patch 1/6] memcg: remove unused retry signal from reclaim
Message-ID: <20110513092308.GC25304@tiehlicka.suse.cz>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
 <1305212038-15445-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1305212038-15445-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 12-05-11 16:53:53, Johannes Weiner wrote:
> If the memcg reclaim code detects the target memcg below its limit it
> exits and returns a guaranteed non-zero value so that the charge is
> retried.
> 
> Nowadays, the charge side checks the memcg limit itself and does not
> rely on this non-zero return value trick.
> 
> This patch removes it.  The reclaim code will now always return the
> true number of pages it reclaimed on its own.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Makes sense
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 010f916..bf5ab87 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1503,7 +1503,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  			if (!res_counter_soft_limit_excess(&root_mem->res))
>  				return total;
>  		} else if (mem_cgroup_margin(root_mem))
> -			return 1 + total;
> +			return total;
>  	}
>  	return total;
>  }
> -- 
> 1.7.5.1
> 

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
