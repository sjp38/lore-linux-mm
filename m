Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA8F8D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 04:53:00 -0500 (EST)
Date: Mon, 15 Nov 2010 09:52:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 40/44] mm/hugetlb.c: Remove unnecessary semicolons
Message-ID: <20101115095244.GI27362@csn.ul.ie>
References: <cover.1289789604.git.joe@perches.com> <59705f848d35b12ace640f92afcffea02cee0976.1289789605.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <59705f848d35b12ace640f92afcffea02cee0976.1289789605.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: Jiri Kosina <trivial@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 14, 2010 at 07:04:59PM -0800, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  mm/hugetlb.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c4a3558..8875242 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -540,7 +540,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  
>  	/* If reserves cannot be used, ensure enough pages are in the pool */
>  	if (avoid_reserve && h->free_huge_pages - h->resv_huge_pages == 0)
> -		goto err;;
> +		goto err;
>  
>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>  						MAX_NR_ZONES - 1, nodemask) {
> -- 
> 1.7.3.1.g432b3.dirty
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
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
