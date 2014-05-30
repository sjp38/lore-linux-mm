Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id EB3A16B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 08:03:15 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1321623pad.39
        for <linux-mm@kvack.org>; Fri, 30 May 2014 05:03:15 -0700 (PDT)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id wp2si5326918pab.65.2014.05.30.05.03.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 May 2014 05:03:15 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so1667471pbb.11
        for <linux-mm@kvack.org>; Fri, 30 May 2014 05:03:14 -0700 (PDT)
Date: Fri, 30 May 2014 05:02:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] hugetlb: rename hugepage_migration_support() to
 ..._supported()
In-Reply-To: <1401423232-25198-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1405300500540.1037@eggly.anvils>
References: <1401423232-25198-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401423232-25198-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, trinity@vger.kernel.org

On Fri, 30 May 2014, Naoya Horiguchi wrote:

> We already have a function named hugepage_supported(), and the similar

hugepages_supported()

> name hugepage_migration_support() is a bit unconfortable, so let's rename
> it hugepage_migration_supported().
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  include/linux/hugetlb.h | 4 ++--
>  mm/hugetlb.c            | 2 +-
>  mm/migrate.c            | 2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git v3.15-rc5.orig/include/linux/hugetlb.h v3.15-rc5/include/linux/hugetlb.h
> index c9de64cf288d..9d35e514312b 100644
> --- v3.15-rc5.orig/include/linux/hugetlb.h
> +++ v3.15-rc5/include/linux/hugetlb.h
> @@ -385,7 +385,7 @@ static inline pgoff_t basepage_index(struct page *page)
>  
>  extern void dissolve_free_huge_pages(unsigned long start_pfn,
>  				     unsigned long end_pfn);
> -static inline int hugepage_migration_support(struct hstate *h)
> +static inline int hugepage_migration_supported(struct hstate *h)
>  {
>  #ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
>  	return huge_page_shift(h) == PMD_SHIFT;
> @@ -441,7 +441,7 @@ static inline pgoff_t basepage_index(struct page *page)
>  	return page->index;
>  }
>  #define dissolve_free_huge_pages(s, e)	do {} while (0)
> -#define hugepage_migration_support(h)	0
> +#define hugepage_migration_supported(h)	0
>  
>  static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>  					   struct mm_struct *mm, pte_t *pte)
> diff --git v3.15-rc5.orig/mm/hugetlb.c v3.15-rc5/mm/hugetlb.c
> index ea42b584661a..83d936d12c1d 100644
> --- v3.15-rc5.orig/mm/hugetlb.c
> +++ v3.15-rc5/mm/hugetlb.c
> @@ -545,7 +545,7 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>  /* Movability of hugepages depends on migration support. */
>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
>  {
> -	if (hugepages_treat_as_movable || hugepage_migration_support(h))
> +	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
>  		return GFP_HIGHUSER_MOVABLE;
>  	else
>  		return GFP_HIGHUSER;
> diff --git v3.15-rc5.orig/mm/migrate.c v3.15-rc5/mm/migrate.c
> index bed48809e5d0..15b589ae6aaf 100644
> --- v3.15-rc5.orig/mm/migrate.c
> +++ v3.15-rc5/mm/migrate.c
> @@ -1031,7 +1031,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>  	 * tables or check whether the hugepage is pmd-based or not before
>  	 * kicking migration.
>  	 */
> -	if (!hugepage_migration_support(page_hstate(hpage))) {
> +	if (!hugepage_migration_supported(page_hstate(hpage))) {
>  		putback_active_hugepage(hpage);
>  		return -ENOSYS;
>  	}
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
