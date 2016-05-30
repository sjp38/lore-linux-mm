Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4A206B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 04:53:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w16so77193609lfd.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:53:13 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id uw10si43253085wjc.242.2016.05.30.01.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 01:53:12 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n129so20390434wmn.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:53:12 -0700 (PDT)
Date: Mon, 30 May 2016 10:53:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcontrol.c: add memory allocation result check
Message-ID: <20160530085311.GM22928@dhcp22.suse.cz>
References: <1464597951-2976-1-git-send-email-wwtao0320@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464597951-2976-1-git-send-email-wwtao0320@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wenwei Tao <wwtao0320@163.com>
Cc: hannes@cmpxchg.org, vdavydov@virtuozzo.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ww.tao0320@gmail.com

On Mon 30-05-16 16:45:51, Wenwei Tao wrote:
> From: Wenwei Tao <ww.tao0320@gmail.com>
> 
> The mem_cgroup_tree_per_node allocation might fail,
> check that before continue the memcg init. Since it
> is in the init phase, trigger the panic if that failure
> happens.

We would blow up in the very same function so what is the point of the
explicit BUG_ON?

> Signed-off-by: Wenwei Tao <ww.tao0320@gmail.com>
> ---
>  mm/memcontrol.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 925b431..6385c62 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5712,6 +5712,7 @@ static int __init mem_cgroup_init(void)
>  
>  		rtpn = kzalloc_node(sizeof(*rtpn), GFP_KERNEL,
>  				    node_online(node) ? node : NUMA_NO_NODE);
> +		BUG_ON(!rtpn);
>  
>  		for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>  			struct mem_cgroup_tree_per_zone *rtpz;
> -- 
> 1.8.3.1
> 
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
