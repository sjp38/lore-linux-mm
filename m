Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1406B0253
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 05:07:09 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id rs7so73394013lbb.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:07:09 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v3si32182587wjx.3.2016.06.07.02.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 02:07:08 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m124so21293236wme.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:07:08 -0700 (PDT)
Date: Tue, 7 Jun 2016 11:07:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 02/10] mm: swap: unexport __pagevec_lru_add()
Message-ID: <20160607090645.GD12305@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-3-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 15:48:28, Johannes Weiner wrote:
> There is currently no modular user of this function. We used to have
> filesystems that open-coded the page cache instantiation, but luckily
> they're all streamlined, and we don't want this to come back.

allmodconfig agrees with that

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 95916142fc46..d810c3d95c97 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -860,7 +860,6 @@ void __pagevec_lru_add(struct pagevec *pvec)
>  {
>  	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, NULL);
>  }
> -EXPORT_SYMBOL(__pagevec_lru_add);
>  
>  /**
>   * pagevec_lookup_entries - gang pagecache lookup
> -- 
> 2.8.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
