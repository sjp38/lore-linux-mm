Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 238726B000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 04:05:00 -0500 (EST)
Date: Mon, 11 Feb 2013 10:04:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: replace cgroup_lock with memcg specific
 memcg_lock fix
Message-ID: <20130211090457.GB19922@dhcp22.suse.cz>
References: <1360569889-843-1-git-send-email-glommer@parallels.com>
 <1360569889-843-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360569889-843-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

Ouch, I have totally missed this one.
Acked-by: Michal Hocko <mhocko@suse.cz>

On Mon 11-02-13 12:04:49, Glauber Costa wrote:
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 28252c9..03ebf68 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5884,7 +5884,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	mutex_lock(&memcg_create_mutex);
>  	/* oom-kill-disable is a flag for subhierarchy. */
>  	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
> -		cgroup_unlock();
> +		mutex_unlock(&memcg_create_mutex);
>  		return -EINVAL;
>  	}
>  	memcg->oom_kill_disable = val;
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
