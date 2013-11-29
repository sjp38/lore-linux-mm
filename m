Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 42D976B0036
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 04:45:52 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so8964112wes.24
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 01:45:51 -0800 (PST)
Received: from mail-ea0-x236.google.com (mail-ea0-x236.google.com [2a00:1450:4013:c01::236])
        by mx.google.com with ESMTPS id h8si13942074wix.18.2013.11.29.01.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 01:45:51 -0800 (PST)
Received: by mail-ea0-f182.google.com with SMTP id o10so8788853eaj.41
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 01:45:51 -0800 (PST)
Date: Fri, 29 Nov 2013 10:45:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: make memcg_update_cache_sizes() static
Message-ID: <20131129094549.GE25893@dhcp22.suse.cz>
References: <1385567162-14973-1-git-send-email-vdavydov@parallels.com>
 <1385567162-14973-2-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385567162-14973-2-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed 27-11-13 19:46:02, Vladimir Davydov wrote:
> This function is not used outside of memcontrol.c so make it static.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 40efb9d..b20b915 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3084,7 +3084,7 @@ int memcg_cache_id(struct mem_cgroup *memcg)
>   * But when we create a new cache, we can call this as well if its parent
>   * is kmem-limited. That will have to hold set_limit_mutex as well.
>   */
> -int memcg_update_cache_sizes(struct mem_cgroup *memcg)
> +static int memcg_update_cache_sizes(struct mem_cgroup *memcg)
>  {
>  	int num, ret;
>  
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
