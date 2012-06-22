Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 0F7126B016D
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:28:11 -0400 (EDT)
Date: Fri, 22 Jun 2012 14:28:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: use existing function to judge root mem cgroup
Message-ID: <20120622122807.GC4814@tiehlicka.suse.cz>
References: <1340366243-28104-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340366243-28104-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri 22-06-12 19:57:22, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f72b5e5..776fc57 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4873,7 +4873,7 @@ mem_cgroup_create(struct cgroup *cont)
>  			goto free_out;
>  
>  	/* root ? */
> -	if (cont->parent == NULL) {
> +	if (!(mem_cgroup_is_root(cont))) {

This is not correct. mem_cgroup_is_root takes mem_cgroup and you are
giving it cgroup, see?

>  		int cpu;
>  		enable_swap_cgroup();
>  		parent = NULL;
> -- 
> 1.7.9.5
> 
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
