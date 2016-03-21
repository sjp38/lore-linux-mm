Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 71DD76B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:53:37 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id r129so49152988wmr.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:53:37 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id bi2si15051133wjc.200.2016.03.21.05.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 05:53:36 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l68so21680698wml.3
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:53:36 -0700 (PDT)
Date: Mon, 21 Mar 2016 13:53:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm: drop PAGE_CACHE_* and page_cache_{get,release}
 definition
Message-ID: <20160321125335.GE23066@dhcp22.suse.cz>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458561998-126622-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458561998-126622-4-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon 21-03-16 15:06:38, Kirill A. Shutemov wrote:
> All users gone. We can remove these macros.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

\o/

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/pagemap.h | 15 ---------------
>  1 file changed, 15 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index b3fc0370c14f..7e1ab155c67c 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -86,21 +86,6 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
>  				(__force unsigned long)mask;
>  }
>  
> -/*
> - * The page cache can be done in larger chunks than
> - * one page, because it allows for more efficient
> - * throughput (it can then be mapped into user
> - * space in smaller chunks for same flexibility).
> - *
> - * Or rather, it _will_ be done in larger chunks.
> - */
> -#define PAGE_CACHE_SHIFT	PAGE_SHIFT
> -#define PAGE_CACHE_SIZE		PAGE_SIZE
> -#define PAGE_CACHE_MASK		PAGE_MASK
> -#define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
> -
> -#define page_cache_get(page)		get_page(page)
> -#define page_cache_release(page)	put_page(page)
>  void release_pages(struct page **pages, int nr, bool cold);
>  
>  /*
> -- 
> 2.7.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
