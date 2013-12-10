Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id C53396B0073
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 21:36:42 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so6617828pbb.18
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:36:42 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id gn4si8998670pbc.141.2013.12.09.18.36.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 18:36:41 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 12:36:38 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 81A9E3578052
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:36:36 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA2IPSr59768838
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:18:25 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA2aZdD016874
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:36:35 +1100
Date: Tue, 10 Dec 2013 10:36:34 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 6/7] mm/migrate: remove unused function,
 fail_migrate_page()
Message-ID: <52a67e39.24be440a.4dbe.37f1SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1386580248-22431-7-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386580248-22431-7-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, Dec 09, 2013 at 06:10:47PM +0900, Joonsoo Kim wrote:
>fail_migrate_page() isn't used anywhere, so remove it.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/include/linux/migrate.h b/include/linux/migrate.h
>index e4671f9..4308018 100644
>--- a/include/linux/migrate.h
>+++ b/include/linux/migrate.h
>@@ -41,9 +41,6 @@ extern int migrate_page(struct address_space *,
> extern int migrate_pages(struct list_head *l, new_page_t x,
> 		unsigned long private, enum migrate_mode mode, int reason);
>
>-extern int fail_migrate_page(struct address_space *,
>-			struct page *, struct page *);
>-
> extern int migrate_prep(void);
> extern int migrate_prep_local(void);
> extern int migrate_vmas(struct mm_struct *mm,
>@@ -83,7 +80,6 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
>
> /* Possible settings for the migrate_page() method in address_operations */
> #define migrate_page NULL
>-#define fail_migrate_page NULL
>
> #endif /* CONFIG_MIGRATION */
>
>diff --git a/mm/migrate.c b/mm/migrate.c
>index cdafdc0..b595f89 100644
>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -550,14 +550,6 @@ void migrate_page_copy(struct page *newpage, struct page *page)
>  *                    Migration functions
>  ***********************************************************/
>
>-/* Always fail migration. Used for mappings that are not movable */
>-int fail_migrate_page(struct address_space *mapping,
>-			struct page *newpage, struct page *page)
>-{
>-	return -EIO;
>-}
>-EXPORT_SYMBOL(fail_migrate_page);
>-
> /*
>  * Common logic to directly migrate a single page suitable for
>  * pages that do not use PagePrivate/PagePrivate2.
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
