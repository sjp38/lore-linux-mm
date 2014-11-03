Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 565F16B0081
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 10:28:51 -0500 (EST)
Received: by mail-lb0-f182.google.com with SMTP id f15so10298085lbj.41
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 07:28:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xe3si32857614lbb.114.2014.11.03.07.28.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 07:28:49 -0800 (PST)
Date: Mon, 3 Nov 2014 16:28:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: remove stale page_cgroup_lock comment
Message-ID: <20141103152848.GD10156@dhcp22.suse.cz>
References: <1414898060-4658-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414898060-4658-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat 01-11-14 23:14:20, Johannes Weiner wrote:
> There is no cgroup-specific page lock anymore.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 38f0647a2f12..d20928597a07 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2467,10 +2467,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	int isolated;
>  
>  	VM_BUG_ON_PAGE(pc->mem_cgroup, page);
> -	/*
> -	 * we don't need page_cgroup_lock about tail pages, becase they are not
> -	 * accessed by any other context at this point.
> -	 */
>  
>  	/*
>  	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
> -- 
> 2.1.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
