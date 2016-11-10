Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36F0F6B0296
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 12:21:58 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so12875564wme.4
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 09:21:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si7003173wmb.0.2016.11.10.09.21.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 09:21:56 -0800 (PST)
Date: Thu, 10 Nov 2016 18:21:55 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] filemap: add comment for confusing logic in
 page_cache_tree_insert()
Message-ID: <20161110172155.GC31098@quack2.suse.cz>
References: <20161110163640.126124-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161110163640.126124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Thu 10-11-16 19:36:40, Kirill A. Shutemov wrote:
> Unlike THP, hugetlb pages represented by one entry on radix-tree.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Jan Kara <jack@suse.cz>

Thanks!

								Honza
> ---
>  mm/filemap.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 849f459ad078..7602e8fabf5e 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -169,7 +169,10 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  static void page_cache_tree_delete(struct address_space *mapping,
>  				   struct page *page, void *shadow)
>  {
> -	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
> +	int i, nr;
> +
> +	/* hugetlb pages represented by one entry on radix-tree */
> +	nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
>  
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(PageTail(page), page);
> -- 
> 2.9.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
