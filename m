Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E114A8D0001
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 10:44:20 -0400 (EDT)
Date: Fri, 5 Nov 2010 14:44:04 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch]vmscan: avoid set zone congested if no page dirty
Message-ID: <20101105144404.GB32723@csn.ul.ie>
References: <1288831858.23014.129.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1288831858.23014.129.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 04, 2010 at 08:50:58AM +0800, Shaohua Li wrote:
> nr_dirty and nr_congested are increased only when page is dirty. So if all pages
> are clean, both them will be zero. In this case, we should not mark the zone
> congested.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b8a6fdc..d31d7ce 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -913,7 +913,7 @@ keep_lumpy:
>  	 * back off and wait for congestion to clear because further reclaim
>  	 * will encounter the same problem
>  	 */
> -	if (nr_dirty == nr_congested)
> +	if (nr_dirty == nr_congested && nr_dirty != 0)
>  		zone_set_flag(zone, ZONE_CONGESTED);
>  
>  	free_page_list(&free_pages);
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
