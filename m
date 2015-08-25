Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F2BBC6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 11:28:26 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so18765131wic.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:28:26 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id gc6si3856603wic.19.2015.08.25.08.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 08:28:26 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so19589980wid.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 08:28:25 -0700 (PDT)
Date: Tue, 25 Aug 2015 17:28:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm/page_alloc: change
 sysctl_lower_zone_reserve_ratio to sysctl_lowmem_reserve_ratio
Message-ID: <20150825152822.GJ6285@dhcp22.suse.cz>
References: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440511291-3990-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 25-08-15 22:01:30, Yaowei Bai wrote:
> We use sysctl_lowmem_reserve_ratio rather than sysctl_lower_zone_reserve_ratio to
> determine how aggressive the kernel is in defending lowmem from the possibility of
> being captured into pinned user memory. To avoid misleading, correct it in some
> comments.

We never had a sysctl like that AFAICS in git history.

> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0a0acdb..b730f7d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6043,7 +6043,7 @@ void __init page_alloc_init(void)
>  }
>  
>  /*
> - * calculate_totalreserve_pages - called when sysctl_lower_zone_reserve_ratio
> + * calculate_totalreserve_pages - called when sysctl_lowmem_reserve_ratio
>   *	or min_free_kbytes changes.
>   */
>  static void calculate_totalreserve_pages(void)
> @@ -6087,7 +6087,7 @@ static void calculate_totalreserve_pages(void)
>  
>  /*
>   * setup_per_zone_lowmem_reserve - called whenever
> - *	sysctl_lower_zone_reserve_ratio changes.  Ensures that each zone
> + *	sysctl_lowmem_reserve_ratio changes.  Ensures that each zone
>   *	has a correct pages reserved value, so an adequate number of
>   *	pages are left in the zone after a successful __alloc_pages().
>   */
> -- 
> 1.9.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
