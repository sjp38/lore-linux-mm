Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 939D36B0075
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 05:33:12 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so2309863wiw.13
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:33:12 -0800 (PST)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id q4si5365911wiy.17.2014.12.07.02.33.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 02:33:11 -0800 (PST)
Received: by mail-wi0-f181.google.com with SMTP id r20so2347495wiv.8
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:33:11 -0800 (PST)
Date: Sun, 7 Dec 2014 11:33:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcontrol: Skip test_mem_cgroup_node_reclaimable()
 when no MAX_NUMNODES or not more than 1
Message-ID: <20141207103310.GJ15892@dhcp22.suse.cz>
References: <5482316D.607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5482316D.607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi,
this has been fixed last week already
http://marc.info/?l=linux-mm&m=141751847710864&w=2

On Sat 06-12-14 06:27:57, Chen Gang wrote:
> test_mem_cgroup_node_reclaimable() is only used when "MAX_NUMNODES > 1",
> so move it into related quote.
> 
> The related warning (with allmodconfig under parisc):
> 
>     CC      mm/memcontrol.o
>   mm/memcontrol.c:1629:13: warning: 'test_mem_cgroup_node_reclaimable' defined but not used [-Wunused-function]
>    static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
>                ^
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
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
> 1.9.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
