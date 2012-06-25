Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 32D9D6B0313
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 04:17:45 -0400 (EDT)
Message-ID: <4FE81DEB.5090407@parallels.com>
Date: Mon, 25 Jun 2012 12:14:35 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] memcg: optimize memcg_get_hierarchical_limit
References: <1340432297-5362-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1340432297-5362-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On 06/23/2012 10:18 AM, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>
> Optimize memcg_get_hierarchical_limit to save cpu cycle.
>
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> ---
>   mm/memcontrol.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c821e36..1ca79e2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3917,9 +3917,9 @@ static void memcg_get_hierarchical_limit(struct mem_cgroup *memcg,
>
>   	min_limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
>   	min_memsw_limit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> -	cgroup = memcg->css.cgroup;
>   	if (!memcg->use_hierarchy)
>   		goto out;
> +	cgroup = memcg->css.cgroup;
>
>   	while (cgroup->parent) {
>   		cgroup = cgroup->parent;
>
Seriously, this saves nothing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
