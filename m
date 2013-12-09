Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id A76F26B00D2
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 12:07:37 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i17so2879456qcy.23
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 09:07:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c3si6555319qan.89.2013.12.09.09.07.35
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 09:07:36 -0800 (PST)
Date: Mon, 09 Dec 2013 12:07:26 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386608846-opj9f7ee-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386580248-22431-7-git-send-email-iamjoonsoo.kim@lge.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-7-git-send-email-iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 6/7] mm/migrate: remove unused function,
 fail_migrate_page()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 06:10:47PM +0900, Joonsoo Kim wrote:
> fail_migrate_page() isn't used anywhere, so remove it.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e4671f9..4308018 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -41,9 +41,6 @@ extern int migrate_page(struct address_space *,
>  extern int migrate_pages(struct list_head *l, new_page_t x,
>  		unsigned long private, enum migrate_mode mode, int reason);
>  
> -extern int fail_migrate_page(struct address_space *,
> -			struct page *, struct page *);
> -
>  extern int migrate_prep(void);
>  extern int migrate_prep_local(void);
>  extern int migrate_vmas(struct mm_struct *mm,
> @@ -83,7 +80,6 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
>  
>  /* Possible settings for the migrate_page() method in address_operations */
>  #define migrate_page NULL
> -#define fail_migrate_page NULL
>  
>  #endif /* CONFIG_MIGRATION */
>  
> diff --git a/mm/migrate.c b/mm/migrate.c
> index cdafdc0..b595f89 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -550,14 +550,6 @@ void migrate_page_copy(struct page *newpage, struct page *page)
>   *                    Migration functions
>   ***********************************************************/
>  
> -/* Always fail migration. Used for mappings that are not movable */
> -int fail_migrate_page(struct address_space *mapping,
> -			struct page *newpage, struct page *page)
> -{
> -	return -EIO;
> -}
> -EXPORT_SYMBOL(fail_migrate_page);
> -
>  /*
>   * Common logic to directly migrate a single page suitable for
>   * pages that do not use PagePrivate/PagePrivate2.
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
