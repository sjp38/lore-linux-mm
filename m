Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 402B56B0171
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:07:53 -0500 (EST)
Date: Mon, 12 Dec 2011 15:07:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcg: keep root group unchanged if fail to create
 new
Message-ID: <20111212140750.GE14720@tiehlicka.suse.cz>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
 <alpine.LSU.2.00.1112111520510.2297@eggly>
 <20111212131118.GA15249@tiehlicka.suse.cz>
 <CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 12-12-11 21:49:18, Hillf Danton wrote:
[...]
> From: Hillf Danton <dhillf@gmail.com>
> Subject: [PATCH] mm: memcg: keep root group unchanged if fail to create new
> 
> If the request is to create non-root group and we fail to meet it, we should
> leave the root unchanged.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks
> ---
> 
> --- a/mm/memcontrol.c	Fri Dec  9 21:57:40 2011
> +++ b/mm/memcontrol.c	Mon Dec 12 21:47:14 2011
> @@ -4848,9 +4848,9 @@ mem_cgroup_create(struct cgroup_subsys *
>  		int cpu;
>  		enable_swap_cgroup();
>  		parent = NULL;
> -		root_mem_cgroup = memcg;
>  		if (mem_cgroup_soft_limit_tree_init())
>  			goto free_out;
> +		root_mem_cgroup = memcg;
>  		for_each_possible_cpu(cpu) {
>  			struct memcg_stock_pcp *stock =
>  						&per_cpu(memcg_stock, cpu);
> @@ -4888,7 +4888,6 @@ mem_cgroup_create(struct cgroup_subsys *
>  	return &memcg->css;
>  free_out:
>  	__mem_cgroup_free(memcg);
> -	root_mem_cgroup = NULL;
>  	return ERR_PTR(error);
>  }
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
