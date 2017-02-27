Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 054606B0388
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 10:06:29 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v66so15250425wrc.4
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 07:06:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 36si21648988wrk.321.2017.02.27.07.06.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 07:06:28 -0800 (PST)
Date: Mon, 27 Feb 2017 16:06:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 5/6] mm: enable MADV_FREE for swapless system
Message-ID: <20170227150623.GH26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <155648585589300bfae1d45078e7aebb3d988b87.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155648585589300bfae1d45078e7aebb3d988b87.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 24-02-17 13:31:48, Shaohua Li wrote:
> Now MADV_FREE pages can be easily reclaimed even for swapless system. We
> can safely enable MADV_FREE for all systems.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/madvise.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 225af7d..5ab4b7b 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -612,13 +612,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
>  	case MADV_WILLNEED:
>  		return madvise_willneed(vma, prev, start, end);
>  	case MADV_FREE:
> -		/*
> -		 * XXX: In this implementation, MADV_FREE works like
> -		 * MADV_DONTNEED on swapless system or full swap.
> -		 */
> -		if (get_nr_swap_pages() > 0)
> -			return madvise_free(vma, prev, start, end);
> -		/* passthrough */
> +		return madvise_free(vma, prev, start, end);
>  	case MADV_DONTNEED:
>  		return madvise_dontneed(vma, prev, start, end);
>  	default:
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
