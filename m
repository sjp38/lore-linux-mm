Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 79F4B6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:44:12 -0400 (EDT)
Received: by wijp15 with SMTP id p15so73456752wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:44:12 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id pu2si31282397wjc.109.2015.08.24.03.44.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 03:44:11 -0700 (PDT)
Received: by wijp15 with SMTP id p15so73456075wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:44:10 -0700 (PDT)
Date: Mon, 24 Aug 2015 12:44:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm/page_alloc: fix a terrible misleading comment
Message-ID: <20150824104408.GI17078@dhcp22.suse.cz>
References: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 22-08-15 15:40:10, Yaowei Bai wrote:
> The comment says that the per-cpu batchsize and zone watermarks
> are determined by present_pages which is definitely wrong, they
> are both calculated from managed_pages. Fix it.

This seems to be missed in b40da04946aa ("mm: use zone->present_pages
instead of zone->managed_pages where appropriate")
> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b5240b..c22b133 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6003,7 +6003,7 @@ void __init mem_init_print_info(const char *str)
>   * set_dma_reserve - set the specified number of pages reserved in the first zone
>   * @new_dma_reserve: The number of pages to mark reserved
>   *
> - * The per-cpu batchsize and zone watermarks are determined by present_pages.
> + * The per-cpu batchsize and zone watermarks are determined by managed_pages.
>   * In the DMA zone, a significant percentage may be consumed by kernel image
>   * and other unfreeable allocations which can skew the watermarks badly. This
>   * function may optionally be used to account for unfreeable pages in the
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
