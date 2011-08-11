Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 71BB96B00EE
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 08:51:37 -0400 (EDT)
Date: Thu, 11 Aug 2011 14:51:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: Switch NUMA_BUILD and COMPACTION_BUILD to new
 IS_ENABLED() syntax
Message-ID: <20110811125133.GJ8023@tiehlicka.suse.cz>
References: <1312989160-737-1-git-send-email-mmarek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312989160-737-1-git-send-email-mmarek@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Marek <mmarek@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 10-08-11 17:12:40, Michal Marek wrote:
> Introduced in 3.1-rc1, IS_ENABLED(CONFIG_NUMA) expands to a true value
> iff CONFIG_NUMA is set. This makes it easier to grep for code that
> depends on CONFIG_NUMA.

Same applies to CONFIG_COMPACTION.

> Signed-off-by: Michal Marek <mmarek@suse.cz>

I like this.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/gfp.h    |    2 +-
>  include/linux/kernel.h |   14 --------------
>  mm/page_alloc.c        |   17 +++++++++--------
>  mm/vmalloc.c           |    4 ++--
>  mm/vmscan.c            |    2 +-
>  5 files changed, 13 insertions(+), 26 deletions(-)
> 
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e8ecb6..e052d79 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
[...]
> @@ -2097,7 +2098,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	 * allowed per node queues are empty and that nodes are
>  	 * over allocated.
>  	 */
> -	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
> +	if (IS_ENABLED(CONFIG_NUMA) && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)

I gues it makes sense to follow checkpatch here.

>  		goto nopage;
>  
>  restart:

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
