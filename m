Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4C83D6B0073
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 05:31:08 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so4872655wiv.0
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:31:07 -0800 (PST)
Received: from mail-wg0-x233.google.com (mail-wg0-x233.google.com. [2a00:1450:400c:c00::233])
        by mx.google.com with ESMTPS id vj4si57110907wjc.21.2014.12.07.02.31.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 02:31:07 -0800 (PST)
Received: by mail-wg0-f51.google.com with SMTP id k14so4069980wgh.38
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 02:31:07 -0800 (PST)
Date: Sun, 7 Dec 2014 11:31:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcontrol.c:  Cleaning up function that are not
 used anywhere
Message-ID: <20141207103105.GI15892@dhcp22.suse.cz>
References: <1417884356-3086-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417884356-3086-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 06-12-14 17:45:56, Rickard Strandqvist wrote:
> Remove function mem_cgroup_lru_names_not_uptodate() that is not used anywhere.
> And move BUILD_BUG_ON() to the beginning of memcg_stat_show() instead.
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d6ac0e3..5e2f0f3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4379,17 +4379,14 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
>  }
>  #endif /* CONFIG_NUMA */
>  
> -static inline void mem_cgroup_lru_names_not_uptodate(void)
> -{
> -	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> -}
> -
>  static int memcg_stat_show(struct seq_file *m, void *v)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
>  	struct mem_cgroup *mi;
>  	unsigned int i;
>  
> +	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> +
>  	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>  		if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
>  			continue;
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
