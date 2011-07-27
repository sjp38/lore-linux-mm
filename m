Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BA3656B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 09:38:17 -0400 (EDT)
Date: Wed, 27 Jul 2011 15:38:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/5] mm: writeback: remove seriously stale comment on
 dirty limits
Message-ID: <20110727133813.GF4024@tiehlicka.suse.cz>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <1311625159-13771-4-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311625159-13771-4-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon 25-07-11 22:19:17, Johannes Weiner wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Indeed outdated a lot.

Reviewed-by: Michal Hocko <mhocko@suse.cz>
if it makes any sense for comment removal like this.

> ---
>  mm/page-writeback.c |   18 ------------------
>  1 files changed, 0 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index a4de005..41dc871 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -379,24 +379,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
>  EXPORT_SYMBOL(bdi_set_max_ratio);
>  
>  /*
> - * Work out the current dirty-memory clamping and background writeout
> - * thresholds.
> - *
> - * The main aim here is to lower them aggressively if there is a lot of mapped
> - * memory around.  To avoid stressing page reclaim with lots of unreclaimable
> - * pages.  It is better to clamp down on writers than to start swapping, and
> - * performing lots of scanning.
> - *
> - * We only allow 1/2 of the currently-unmapped memory to be dirtied.
> - *
> - * We don't permit the clamping level to fall below 5% - that is getting rather
> - * excessive.
> - *
> - * We make sure that the background writeout level is below the adjusted
> - * clamping level.
> - */
> -
> -/*
>   * global_dirty_limits - background-writeback and dirty-throttling thresholds
>   *
>   * Calculate the dirty thresholds based on sysctl parameters
> -- 
> 1.7.6
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
