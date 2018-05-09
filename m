Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 35BD36B039A
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:18:10 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 3-v6so20061641wry.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:18:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f22-v6si1083446edq.84.2018.05.09.01.18.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 01:18:08 -0700 (PDT)
Date: Wed, 9 May 2018 10:18:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: drain memcg stock on force_empty
Message-ID: <20180509081807.GG32366@dhcp22.suse.cz>
References: <20180507201651.165879-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507201651.165879-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Junaid Shahid <junaids@google.com>, Junaid Shahid <juanids@google.com>

On Mon 07-05-18 13:16:51, Shakeel Butt wrote:
> From: Junaid Shahid <junaids@google.com>
> 
> The per-cpu memcg stock can retain a charge of upto 32 pages. On a
> machine with large number of cpus, this can amount to a decent amount
> of memory. Additionally force_empty interface might be triggering
> unneeded memcg reclaims.
> 
> Signed-off-by: Junaid Shahid <juanids@google.com>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2d33a37f971..2c3c69524b49 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2841,6 +2841,9 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
>  
>  	/* we call try-to-free pages for make this cgroup empty */
>  	lru_add_drain_all();
> +
> +	drain_all_stock(memcg);
> +
>  	/* try to free all pages in this cgroup */
>  	while (nr_retries && page_counter_read(&memcg->memory)) {
>  		int progress;
> -- 
> 2.17.0.441.gb46fe60e1d-goog

-- 
Michal Hocko
SUSE Labs
