Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05BC96B016B
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 03:53:51 -0400 (EDT)
Date: Thu, 4 Aug 2011 09:53:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] page cgroup: using vzalloc instead of vmalloc
Message-ID: <20110804075346.GE31039@tiehlicka.suse.cz>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu 04-08-11 11:09:47, Bob Liu wrote:
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_cgroup.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 39d216d..6bdc67d 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -513,11 +513,10 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
>  	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
>  	array_size = length * sizeof(void *);
>  
> -	array = vmalloc(array_size);
> +	array = vzalloc(array_size);
>  	if (!array)
>  		goto nomem;
>  
> -	memset(array, 0, array_size);
>  	ctrl = &swap_cgroup_ctrl[type];
>  	mutex_lock(&swap_cgroup_mutex);
>  	ctrl->length = length;
> -- 
> 1.6.3.3
> 
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
