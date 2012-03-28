Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id E002E6B0044
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 05:18:16 -0400 (EDT)
Date: Wed, 28 Mar 2012 11:18:11 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V4 01/10] hugetlb: rename max_hstate to
 hugetlb_max_hstate
Message-ID: <20120328091811.GB20949@tiehlicka.suse.cz>
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1331919570-2264-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1331919570-2264-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

[Sorry for late review]

On Fri 16-03-12 23:09:21, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We will be using this from other subsystems like memcg
> in later patches.

OK, why not. I would probably loved an accessor function more but what
ever.

Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 5f34bd8..d623e71 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -34,7 +34,7 @@ const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
>  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
>  unsigned long hugepages_treat_as_movable;
>  
> -static int max_hstate;
> +static int hugetlb_max_hstate;
> 
>  unsigned int default_hstate_idx;
>  struct hstate hstates[HUGE_MAX_HSTATE];
>  
> @@ -46,7 +46,7 @@ static unsigned long __initdata default_hstate_max_huge_pages;
>  static unsigned long __initdata default_hstate_size;
>  
>  #define for_each_hstate(h) \
> -	for ((h) = hstates; (h) < &hstates[max_hstate]; (h)++)
> +	for ((h) = hstates; (h) < &hstates[hugetlb_max_hstate]; (h)++)
>  
>  /*
>   * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
> @@ -1808,9 +1808,9 @@ void __init hugetlb_add_hstate(unsigned order)
>  		printk(KERN_WARNING "hugepagesz= specified twice, ignoring\n");
>  		return;
>  	}
> -	BUG_ON(max_hstate >= HUGE_MAX_HSTATE);
> +	BUG_ON(hugetlb_max_hstate >= HUGE_MAX_HSTATE);
>  	BUG_ON(order == 0);
> -	h = &hstates[max_hstate++];
> +	h = &hstates[hugetlb_max_hstate++];
>  	h->order = order;
>  	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
>  	h->nr_huge_pages = 0;
> @@ -1831,10 +1831,10 @@ static int __init hugetlb_nrpages_setup(char *s)
>  	static unsigned long *last_mhp;
>  
>  	/*
> -	 * !max_hstate means we haven't parsed a hugepagesz= parameter yet,
> +	 * !hugetlb_max_hstate means we haven't parsed a hugepagesz= parameter yet,
>  	 * so this hugepages= parameter goes to the "default hstate".
>  	 */
> -	if (!max_hstate)
> +	if (!hugetlb_max_hstate)
>  		mhp = &default_hstate_max_huge_pages;
>  	else
>  		mhp = &parsed_hstate->max_huge_pages;
> @@ -1853,7 +1853,7 @@ static int __init hugetlb_nrpages_setup(char *s)
>  	 * But we need to allocate >= MAX_ORDER hstates here early to still
>  	 * use the bootmem allocator.
>  	 */
> -	if (max_hstate && parsed_hstate->order >= MAX_ORDER)
> +	if (hugetlb_max_hstate && parsed_hstate->order >= MAX_ORDER)
>  		hugetlb_hstate_alloc_pages(parsed_hstate);
>  
>  	last_mhp = mhp;
> -- 
> 1.7.9
> 

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
