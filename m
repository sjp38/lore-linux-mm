Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0C36B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 06:02:44 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f4-v6so528423plm.12
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 03:02:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si6922762pgb.669.2018.04.06.03.02.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 03:02:42 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:02:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH resend] mm/page_alloc: fix comment is __get_free_pages
Message-ID: <20180406100236.GK8286@dhcp22.suse.cz>
References: <1511780964-64864-1-git-send-email-chenjiankang1@huawei.com>
 <20171127113341.ldx32qvexqe2224d@dhcp22.suse.cz>
 <20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129160446.jluzpv3n6mjc3fwv@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: JianKang Chen <chenjiankang1@huawei.com>, mgorman@techsingularity.net, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Wed 29-11-17 17:04:46, Michal Hocko wrote:
[...]
> From 000bb422fe07adbfa8cd8ed953b18f48647a45d6 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 29 Nov 2017 17:02:33 +0100
> Subject: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
> 
> There is no real reason to blow up just because the caller doesn't know
> that __get_free_pages cannot return highmem pages. Simply fix that up
> silently. Even if we have some confused users such a fixup will not be
> harmful.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Andrew, have we reached any conclusion for this? Should I repost or drop
it on the floor?

> ---
>  mm/page_alloc.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0d518e9b2ee8..3dd960ea8c13 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4284,9 +4284,7 @@ unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
>  	 * __get_free_pages() returns a virtual address, which cannot represent
>  	 * a highmem page
>  	 */
> -	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
> -
> -	page = alloc_pages(gfp_mask, order);
> +	page = alloc_pages(gfp_mask & ~__GFP_HIGHMEM, order);
>  	if (!page)
>  		return 0;
>  	return (unsigned long) page_address(page);
> -- 
> 2.15.0
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs
