Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 42A3C6B0071
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 05:29:49 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so2339625wid.5
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:29:48 -0800 (PST)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com. [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id ic3si5314369wid.49.2014.12.07.02.29.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 02:29:48 -0800 (PST)
Received: by mail-wg0-f44.google.com with SMTP id b13so4122106wgh.3
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:29:48 -0800 (PST)
Date: Sun, 7 Dec 2014 11:29:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcontrol.c: fix the placement of 'MAX_NUMNODES > 1'
 if block
Message-ID: <20141207102946.GH15892@dhcp22.suse.cz>
References: <1417881883-18324-1-git-send-email-festevam@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417881883-18324-1-git-send-email-festevam@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabio Estevam <festevam@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-mm@kvack.org, Fabio Estevam <fabio.estevam@freescale.com>

Hi,
this has been fixed last week already
http://marc.info/?l=linux-mm&m=141751847710864&w=2

Thanks!

On Sat 06-12-14 14:04:43, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> When building ARM allmodconfig we get the following build warning:
> 
> mm/memcontrol.c:1629:13: warning: 'test_mem_cgroup_node_reclaimable' defined but not used [-Wunused-function]
> 
> As test_mem_cgroup_node_reclaimable() is only used inside the
> '#if MAX_NUMNODES > 1' block, we should also place its definition there as well.
> 
> Reported-by: Olof's autobuilder <build@lixom.net>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c6ac50e..d538b08 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1616,6 +1616,7 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  			 NULL, "Memory cgroup out of memory");
>  }
>  
> +#if MAX_NUMNODES > 1
>  /**
>   * test_mem_cgroup_node_reclaimable
>   * @memcg: the target memcg
> @@ -1638,7 +1639,6 @@ static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
>  	return false;
>  
>  }
> -#if MAX_NUMNODES > 1
>  
>  /*
>   * Always updating the nodemask is not very good - even if we have an empty
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
