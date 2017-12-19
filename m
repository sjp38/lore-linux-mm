Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 351646B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:02:29 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 96so10919143wrk.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 02:02:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si11558492wrg.500.2017.12.19.02.02.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 02:02:28 -0800 (PST)
Date: Tue, 19 Dec 2017 11:02:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] mm: Remove reference to PG_buddy
Message-ID: <20171219100226.GG2787@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-9-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-9-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat 16-12-17 08:44:25, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> PG_buddy doesn't exist any more.  It's called PageBuddy now.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index a517d210f177..06f16a451a53 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -173,13 +173,14 @@ struct page {
>  	};
>  
>  	union {
> -		unsigned long private;		/* Mapping-private opaque data:
> -					 	 * usually used for buffer_heads
> -						 * if PagePrivate set; used for
> -						 * swp_entry_t if PageSwapCache;
> -						 * indicates order in the buddy
> -						 * system if PG_buddy is set.
> -						 */
> +		/*
> +		 * Mapping-private opaque data:
> +		 * Usually used for buffer_heads if PagePrivate
> +		 * Used for swp_entry_t if PageSwapCache
> +		 * Indicates order in the buddy system if PageBuddy
> +		 */
> +		unsigned long private;
> +
>  #if USE_SPLIT_PTE_PTLOCKS
>  #if ALLOC_SPLIT_PTLOCKS
>  		spinlock_t *ptl;
> -- 
> 2.15.1
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
