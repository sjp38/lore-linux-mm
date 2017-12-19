Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3BA76B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:02:37 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id f4so10877699wre.9
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:02:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i88si10883142wri.407.2017.12.19.00.02.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 00:02:36 -0800 (PST)
Date: Tue, 19 Dec 2017 09:02:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/8] mm: Improve comment on page->mapping
Message-ID: <20171219080233.GA2787@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-5-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171216164425.8703-5-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat 16-12-17 08:44:21, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The comment on page->mapping is terse, and out of date (it does not
> mention the possibility of PAGE_MAPPING_MOVABLE).  Instead, point
> the interested reader to page-flags.h where there is a much better
> comment.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm_types.h | 12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index c2294e6204e8..8c3b8cea22ee 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -50,15 +50,9 @@ struct page {
>  	unsigned long flags;		/* Atomic flags, some possibly
>  					 * updated asynchronously */
>  	union {
> -		struct address_space *mapping;	/* If low bit clear, points to
> -						 * inode address_space, or NULL.
> -						 * If page mapped as anonymous
> -						 * memory, low bit is set, and
> -						 * it points to anon_vma object
> -						 * or KSM private structure. See
> -						 * PAGE_MAPPING_ANON and
> -						 * PAGE_MAPPING_KSM.
> -						 */
> +		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
> +		struct address_space *mapping;
> +
>  		void *s_mem;			/* slab first object */
>  		atomic_t compound_mapcount;	/* first tail page */
>  		/* page_deferred_list().next	 -- second tail page */
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
