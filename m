Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DD2258D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 08:25:14 -0400 (EDT)
Date: Tue, 12 Apr 2011 14:25:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RESEND 1/4] memcg: mark init_section_page_cgroup()
 properly
Message-ID: <20110412122507.GD13700@tiehlicka.suse.cz>
References: <1302575737-6401-1-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1302575737-6401-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue 12-04-11 11:35:34, Namhyung Kim wrote:
> The commit ca371c0d7e23 ("memcg: fix page_cgroup fatal error
> in FLATMEM") removes call to alloc_bootmem() in the function
> so that it can be marked as __meminit to reduce memory usage
> when MEMORY_HOTPLUG=n.
> 
> Also as new helper function alloc_page_cgroup() is called only
> in the function, it should be marked too.
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.cz>

I am not aware I would be involved in the first round, but yes this
looks correct and reasonable. You can add my
Reviewed-by: Michal Hocko <mhocko@suse.cz>
if you care.

> ---
> I kept Acked-by's because it seemed like a trivial change, no?
> 
>  mm/page_cgroup.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 99055010cece..81205c52735c 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -130,7 +130,7 @@ struct page *lookup_cgroup_page(struct page_cgroup *pc)
>  	return page;
>  }
>  
> -static void *__init_refok alloc_page_cgroup(size_t size, int nid)
> +static void *__meminit alloc_page_cgroup(size_t size, int nid)
>  {
>  	void *addr = NULL;
>  
> @@ -162,7 +162,7 @@ static void free_page_cgroup(void *addr)
>  }
>  #endif
>  
> -static int __init_refok init_section_page_cgroup(unsigned long pfn)
> +static int __meminit init_section_page_cgroup(unsigned long pfn)
>  {
>  	struct page_cgroup *base, *pc;
>  	struct mem_section *section;
> -- 
> 1.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
