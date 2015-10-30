Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8870882F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 08:47:14 -0400 (EDT)
Received: by wmeg8 with SMTP id g8so11038889wme.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 05:47:14 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id l13si3539440wmg.29.2015.10.30.05.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 05:47:13 -0700 (PDT)
Received: by wmff134 with SMTP id f134so11000339wmf.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 05:47:13 -0700 (PDT)
Date: Fri, 30 Oct 2015 13:47:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/8] mm: lru_deactivate_fn should clear PG_referenced
Message-ID: <20151030124711.GB23627@dhcp22.suse.cz>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-7-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446188504-28023-7-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

On Fri 30-10-15 16:01:42, Minchan Kim wrote:
> deactivate_page aims for accelerate for reclaiming through
> moving pages from active list to inactive list so we should
> clear PG_referenced for the goal.

I might be missing something but aren't we using PG_referenced only for
pagecache (and shmem) pages?

> 
> Acked-by: Hugh Dickins <hughd@google.com>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/swap.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index d0eacc5f62a3..4a6aec976ab1 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -810,6 +810,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
>  
>  		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
>  		ClearPageActive(page);
> +		ClearPageReferenced(page);
>  		add_page_to_lru_list(page, lruvec, lru);
>  
>  		__count_vm_event(PGDEACTIVATE);
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
