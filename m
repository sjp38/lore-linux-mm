Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 320056B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 09:50:57 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so20664072wib.1
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 06:50:56 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id hj1si20523218wib.65.2015.01.13.06.50.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 06:50:55 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id n3so4445130wiv.1
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 06:50:55 -0800 (PST)
Date: Tue, 13 Jan 2015 15:50:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: remove unnecessary soft limit tree
 node test
Message-ID: <20150113145053.GG25318@dhcp22.suse.cz>
References: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420856041-27647-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 09-01-15 21:13:59, Johannes Weiner wrote:
> kzalloc_node() automatically falls back to nodes with suitable memory.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fd9e542fc26f..aad254b30708 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4520,13 +4520,10 @@ static void __init mem_cgroup_soft_limit_tree_init(void)
>  {
>  	struct mem_cgroup_tree_per_node *rtpn;
>  	struct mem_cgroup_tree_per_zone *rtpz;
> -	int tmp, node, zone;
> +	int node, zone;
>  
>  	for_each_node(node) {
> -		tmp = node;
> -		if (!node_state(node, N_NORMAL_MEMORY))
> -			tmp = -1;
> -		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, tmp);
> +		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL, node);
>  		BUG_ON(!rtpn);
>  
>  		soft_limit_tree.rb_tree_per_node[node] = rtpn;
> -- 
> 2.2.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
