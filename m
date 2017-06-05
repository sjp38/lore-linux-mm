Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EAC96B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 02:22:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k30so10277264wrc.9
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 23:22:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si20335895wrb.41.2017.06.04.23.22.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Jun 2017 23:22:51 -0700 (PDT)
Date: Mon, 5 Jun 2017 08:22:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Trivial typo fix.
Message-ID: <20170605062248.GC9248@dhcp22.suse.cz>
References: <20170605014350.1973-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170605014350.1973-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon 05-06-17 09:43:50, Wei Yang wrote:
> Looks there is no word "blamo", and it should be "blame".
> 
> This patch just fix the typo.

Well, I do not think this is a typo. blamo has a slang meaning which I
believe was intentional. Besides that, why would you want to fix this
anyway. Is this something that you would grep for?

> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  mm/page_alloc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 07efbc3a8656..9ce765e6fe2f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3214,7 +3214,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	if (gfp_mask & __GFP_THISNODE)
>  		goto out;
>  
> -	/* Exhausted what can be done so it's blamo time */
> +	/* Exhausted what can be done so it's blame time */
>  	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
>  		*did_some_progress = 1;
>  
> -- 
> 2.11.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
