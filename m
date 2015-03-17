Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 22EF36B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 11:36:59 -0400 (EDT)
Received: by lbcds1 with SMTP id ds1so9875855lbc.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 08:36:58 -0700 (PDT)
Received: from mail-we0-x232.google.com (mail-we0-x232.google.com. [2a00:1450:400c:c03::232])
        by mx.google.com with ESMTPS id v6si3830380wif.47.2015.03.17.08.36.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 08:36:57 -0700 (PDT)
Received: by weop45 with SMTP id p45so10716658weo.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 08:36:56 -0700 (PDT)
Date: Tue, 17 Mar 2015 16:36:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove obsolete comment
Message-ID: <20150317153654.GK28112@dhcp22.suse.cz>
References: <1426606113-1694-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426606113-1694-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 17-03-15 18:28:33, Vladimir Davydov wrote:
> Low and high watermarks, as they defined in the TODO to the mem_cgroup
> struct, have already been implemented by Johannes, so remove the stale
> comment.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0a06628470cc..74a9641d8f9f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -259,11 +259,6 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
>   * page cache and RSS per cgroup. We would eventually like to provide
>   * statistics based on the statistics developed by Rik Van Riel for clock-pro,
>   * to help the administrator determine what knobs to tune.
> - *
> - * TODO: Add a water mark for the memory controller. Reclaim will begin when
> - * we hit the water mark. May be even add a low water mark, such that
> - * no reclaim occurs from a cgroup at it's low water mark, this is
> - * a feature that will be implemented much later in the future.
>   */
>  struct mem_cgroup {
>  	struct cgroup_subsys_state css;
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
