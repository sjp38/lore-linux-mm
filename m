Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A36D36B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 06:47:12 -0500 (EST)
Date: Tue, 11 Jan 2011 11:46:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v3 3/7] hugetlbfs: Change remove_from_page_cache
Message-ID: <20110111114648.GE11932@csn.ul.ie>
References: <cover.1294723009.git.minchan.kim@gmail.com> <95582288aa619785893385ac5f5e2ded45e0cc28.1294723009.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <95582288aa619785893385ac5f5e2ded45e0cc28.1294723009.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 02:22:07PM +0900, Minchan Kim wrote:
> This patch series changes remove_from_page_cache's page ref counting
> rule. Page cache ref count is decreased in delete_from_page_cache.
> So we don't need decreasing page reference by caller.
> 
> Cc: William Irwin <wli@holomorphy.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks.

> ---
>  fs/hugetlbfs/inode.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 9885082..b9eeb1c 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -332,8 +332,7 @@ static void truncate_huge_page(struct page *page)
>  {
>  	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
>  	ClearPageUptodate(page);
> -	remove_from_page_cache(page);
> -	put_page(page);
> +	delete_from_page_cache(page);
>  }
>  
>  static void truncate_hugepages(struct inode *inode, loff_t lstart)

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
