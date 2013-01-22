Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 624E76B0009
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 09:01:01 -0500 (EST)
Date: Tue, 22 Jan 2013 15:00:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 6/6] memcg: avoid dangling reference count in creation
 failure.
Message-ID: <20130122140058.GF28525@dhcp22.suse.cz>
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
 <1358862461-18046-7-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358862461-18046-7-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Tue 22-01-13 17:47:41, Glauber Costa wrote:
> When use_hierarchy is enabled, we acquire an extra reference count
> in our parent during cgroup creation. We don't release it, though,
> if any failure exist in the creation process.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 357324c..72a008e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6166,6 +6166,8 @@ mem_cgroup_css_online(struct cgroup *cont)
>  		 * call __mem_cgroup_free, so return directly
>  		 */
>  		mem_cgroup_put(memcg);
> +		if (parent->use_hierarchy)
> +			mem_cgroup_put(parent);
>  	}
>  	return error;
>  }
> -- 
> 1.8.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
