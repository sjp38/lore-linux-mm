Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9266B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 08:03:17 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id d17so199267eek.37
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 05:03:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si989383eep.106.2014.01.14.05.03.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 05:03:16 -0800 (PST)
Date: Tue, 14 Jan 2014 14:03:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/3] mm/memcg: fix last_dead_count memory wastage
Message-ID: <20140114130315.GA32227@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 13-01-14 17:50:49, Hugh Dickins wrote:
> Shorten mem_cgroup_reclaim_iter.last_dead_count from unsigned long to
> int: it's assigned from an int and compared with an int, and adjacent
> to an unsigned int: so there's no point to it being unsigned long,
> which wasted 104 bytes in every mem_cgroup_per_zone.
>     
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> Putting this one first as it should be nicely uncontroversial.
> I'm assuming much too late for v3.13, so all 3 diffed against mmotm.
> 
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- mmotm/mm/memcontrol.c	2014-01-10 18:25:02.236448954 -0800
> +++ linux/mm/memcontrol.c	2014-01-12 22:21:10.700570471 -0800
> @@ -149,7 +149,7 @@ struct mem_cgroup_reclaim_iter {
>  	 * matches memcg->dead_count of the hierarchy root group.
>  	 */
>  	struct mem_cgroup *last_visited;
> -	unsigned long last_dead_count;
> +	int last_dead_count;
>  
>  	/* scan generation, increased every round-trip */
>  	unsigned int generation;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
