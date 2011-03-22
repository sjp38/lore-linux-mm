Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4952E8D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 05:27:59 -0400 (EDT)
Date: Tue, 22 Mar 2011 10:27:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: +
 page_cgroup-reduce-allocation-overhead-for-page_cgroup-array-for-config_sparsemem.patch
 added to -mm tree
Message-ID: <20110322092753.GD12940@tiehlicka.suse.cz>
References: <201103090035.p290ZJ78004080@imap1.linux-foundation.org>
 <20110322092421.GY2140@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322092421.GY2140@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, balbir@in.ibm.com, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Tue 22-03-11 10:24:21, Johannes Weiner wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: do not define unused free_page_cgroup without memory hotplug
> 
> Without memory hotplug configured in, the page cgroup array is never
> actually freed again:
> 
> mm/page_cgroup.c:149:13: warning: ???free_page_cgroup??? defined but not used
> 
> Wrap the definition in ifdefs.  Rather than moving it into an existing
> ifdef section, to keep it close to its allocation counterpart.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Makes perfect sense. Thanks!

Ackedy-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page_cgroup.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 885b2ac..a12cc3f 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -146,6 +146,7 @@ static void *__init_refok alloc_page_cgroup(size_t size, int nid)
>  	return addr;
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG
>  static void free_page_cgroup(void *addr)
>  {
>  	if (is_vmalloc_addr(addr)) {
> @@ -159,6 +160,7 @@ static void free_page_cgroup(void *addr)
>  		free_pages_exact(addr, table_size);
>  	}
>  }
> +#endif
>  
>  static int __init_refok init_section_page_cgroup(unsigned long pfn)
>  {
> -- 
> 1.7.4

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
