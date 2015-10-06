Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id E8E606B0266
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 13:01:28 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so177078487wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 10:01:28 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id h2si39351258wjx.151.2015.10.06.10.01.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 10:01:27 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so168249830wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 10:01:27 -0700 (PDT)
Date: Tue, 6 Oct 2015 19:01:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: convert threshold to bytes
Message-ID: <20151006170122.GB2752@dhcp22.suse.cz>
References: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>

On Mon 05-10-15 14:44:22, Shaohua Li wrote:
> The page_counter_memparse() returns pages for the threshold, while
> mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
> to bytes.
> 
> Looks a regression introduced by 3e32cb2e0a12b69150

Yes. This suggests
Cc: stable # 3.19+

> Signed-off-by: Shaohua Li <shli@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1fedbde..d9b5c81 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3387,6 +3387,7 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
>  	ret = page_counter_memparse(args, "-1", &threshold);
>  	if (ret)
>  		return ret;
> +	threshold <<= PAGE_SHIFT;
>  
>  	mutex_lock(&memcg->thresholds_lock);
>  
> -- 
> 2.4.6
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
