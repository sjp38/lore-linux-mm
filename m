Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 67D086B006E
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 03:15:40 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id w62so1335313wes.13
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 00:15:39 -0800 (PST)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id u8si40220449wjx.141.2015.01.13.00.15.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 00:15:39 -0800 (PST)
Received: by mail-wg0-f45.google.com with SMTP id y19so1391048wgg.4
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 00:15:39 -0800 (PST)
Date: Tue, 13 Jan 2015 09:15:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: add BUILD_BUG_ON() for string tables
Message-ID: <20150113081537.GA25318@dhcp22.suse.cz>
References: <1421088863-14270-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421088863-14270-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-01-15 10:54:23, Greg Thelen wrote:
> Use BUILD_BUG_ON() to compile assert that memcg string tables are in
> sync with corresponding enums.  There aren't currently any issues with
> these tables.  This is just defensive.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ef91e856c7e4..8d1ca6c55480 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3699,6 +3699,10 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>  	struct mem_cgroup *mi;
>  	unsigned int i;
>  
> +	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_stat_names) !=
> +		     MEM_CGROUP_STAT_NSTATS);
> +	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_events_names) !=
> +		     MEM_CGROUP_EVENTS_NSTATS);
>  	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
>  
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
> -- 
> 2.2.0.rc0.207.ga3a616c
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
