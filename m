Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58C926B025F
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 06:33:45 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x63so10920167wmf.2
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:33:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q29si36571edq.55.2017.11.27.03.33.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 03:33:44 -0800 (PST)
Date: Mon, 27 Nov 2017 12:33:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-ID: <20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JianKang Chen <chenjiankang1@huawei.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Mon 27-11-17 19:09:24, JianKang Chen wrote:
> From: Jiankang Chen <chenjiankang1@huawei.com>
> 
> __get_free_pages will return an virtual address, 
> but it is not just 32-bit address, for example a 64-bit system. 
> And this comment really confuse new bigenner of mm.

s@bigenner@beginner@

Anyway, do we really need a bug on for this? Has this actually caught
any wrong usage? VM_BUG_ON tends to be enabled these days AFAIK and
panicking the kernel seems like an over-reaction. If there is a real
risk then why don't we simply mask __GFP_HIGHMEM off when calling
alloc_pages?

> reported-by: Hanjun Guo <guohanjun@huawei.com>
> Signed-off-by: Jiankang Chen <chenjiankang1@huawei.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 77e4d3c..5a7c432 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4240,7 +4240,7 @@ unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
>  	struct page *page;
>  
>  	/*
> -	 * __get_free_pages() returns a 32-bit address, which cannot represent
> +	 * __get_free_pages() returns a virtual address, which cannot represent
>  	 * a highmem page
>  	 */
>  	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
> -- 
> 1.7.12.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
