Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 14BFB6B005D
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 11:07:45 -0500 (EST)
Date: Thu, 13 Dec 2012 17:07:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 5/8] mm: vmscan: improve comment on low-page cache
 handling
Message-ID: <20121213160742.GH21644@dhcp22.suse.cz>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355348620-9382-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 12-12-12 16:43:37, Johannes Weiner wrote:
> Fix comment style and elaborate on why anonymous memory is
> force-scanned when file cache runs low.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

yes, much better
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/vmscan.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5e1beed..05475e1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1697,13 +1697,15 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
>  		get_lru_size(lruvec, LRU_INACTIVE_FILE);
>  
> +	/*
> +	 * If it's foreseeable that reclaiming the file cache won't be
> +	 * enough to get the zone back into a desirable shape, we have
> +	 * to swap.  Better start now and leave the - probably heavily
> +	 * thrashing - remaining file pages alone.
> +	 */
>  	if (global_reclaim(sc)) {
> -		free  = zone_page_state(zone, NR_FREE_PAGES);
> +		free = zone_page_state(zone, NR_FREE_PAGES);
>  		if (unlikely(file + free <= high_wmark_pages(zone))) {
> -			/*
> -			 * If we have very few page cache pages, force-scan
> -			 * anon pages.
> -			 */
>  			fraction[0] = 1;
>  			fraction[1] = 0;
>  			denominator = 1;
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
