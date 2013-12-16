Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 29A466B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 11:47:32 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so2324987eek.26
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 08:47:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si618194eep.22.2013.12.16.08.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 08:47:31 -0800 (PST)
Date: Mon, 16 Dec 2013 17:47:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: fix memcg_size() calculation
Message-ID: <20131216164730.GD26797@dhcp22.suse.cz>
References: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sat 14-12-13 12:15:33, Vladimir Davydov wrote:
> The mem_cgroup structure contains nr_node_ids pointers to
> mem_cgroup_per_node objects, not the objects themselves.

Ouch! This is 2k per node which is wasted. What a shame I haven't
noticed this back then when reviewing 45cf7ebd5a033 (memcg: reduce the
size of struct memcg 244-fold)

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bf5e894..7f1a356 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -338,7 +338,7 @@ struct mem_cgroup {
>  static size_t memcg_size(void)
>  {
>  	return sizeof(struct mem_cgroup) +
> -		nr_node_ids * sizeof(struct mem_cgroup_per_node);
> +		nr_node_ids * sizeof(struct mem_cgroup_per_node *);
>  }
>  
>  /* internal only representation about the status of kmem accounting. */
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
