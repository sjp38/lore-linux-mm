Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id EBFE16B0044
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 18:21:24 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so8629208pbc.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 15:21:24 -0700 (PDT)
Date: Mon, 16 Apr 2012 15:21:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/7] memcg: move charge to parent only when necessary.
Message-ID: <20120416222119.GC12421@google.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
 <4F86BAB0.5030809@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F86BAB0.5030809@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Apr 12, 2012 at 08:21:20PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> When memcg->use_hierarchy==true, the parent res_counter includes
> the usage in child's usage. So, it's not necessary to call try_charge()
> in the parent.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   39 ++++++++++++++++++++++++++++++++-------
>  1 files changed, 32 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fa01106..3215880 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2409,6 +2409,20 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
>  			res_counter_uncharge(&memcg->memsw, bytes);
>  	}
>  }

New line missing here.

> +/*
> + * Moving usage between a child to its parent if use_hierarchy==true.
> + */

Prolly "from a child to its parent"?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
