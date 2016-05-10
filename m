Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADE86B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:28:40 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so6147833wmw.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:28:40 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id hn10si990140wjc.65.2016.05.10.00.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 00:28:39 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id r12so1168750wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:28:38 -0700 (PDT)
Date: Tue, 10 May 2016 09:28:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: fix stale mem_cgroup_force_empty() comment
Message-ID: <20160510072837.GC23576@dhcp22.suse.cz>
References: <1462569810-54496-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462569810-54496-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 06-05-16 14:23:30, Greg Thelen wrote:
> commit f61c42a7d911 ("memcg: remove tasks/children test from
> mem_cgroup_force_empty()") removed memory reparenting from the function.
> 
> Fix the function's comment.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fe787f5c41bd..19fd76168a05 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2636,8 +2636,7 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * Reclaims as many pages from the given memcg as possible and moves
> - * the rest to the parent.
> + * Reclaims as many pages from the given memcg as possible.
>   *
>   * Caller is responsible for holding css reference for memcg.
>   */
> -- 
> 2.8.0.rc3.226.g39d4020

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
