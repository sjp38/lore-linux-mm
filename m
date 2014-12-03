Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0201E6B0032
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 10:22:44 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so15969913pab.20
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 07:22:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o1si38646126pde.256.2014.12.03.07.22.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Dec 2014 07:22:42 -0800 (PST)
Date: Wed, 3 Dec 2014 10:22:31 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol.c:  Cleaning up function that are not
 used anywhere
Message-ID: <20141203152231.GA2822@phnom.home.cmpxchg.org>
References: <1417560083-27157-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417560083-27157-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 02, 2014 at 11:41:23PM +0100, Rickard Strandqvist wrote:
> Remove function mem_cgroup_lru_names_not_uptodate() that is not used anywhere.
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  mm/memcontrol.c |    5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d6ac0e3..5edd1fe 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4379,11 +4379,6 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
>  }
>  #endif /* CONFIG_NUMA */
>  
> -static inline void mem_cgroup_lru_names_not_uptodate(void)
> -{
> -	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> -}

That assertion doesn't work in an unused function, but we still want
this check.  Please move the BUILD_BUG_ON() to the beginning of
memcg_stat_show() instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
