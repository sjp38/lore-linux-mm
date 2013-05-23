Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 01E946B0002
	for <linux-mm@kvack.org>; Thu, 23 May 2013 06:36:39 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id dn14so3668415obc.26
        for <linux-mm@kvack.org>; Thu, 23 May 2013 03:36:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368321816-17719-8-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1368321816-17719-8-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 23 May 2013 18:36:39 +0800
Message-ID: <CAJd=RBAQzDi3RT5e6Kq3MwQPna1tRUETEjLbFka6P2QRZVWMVA@mail.gmail.com>
Subject: Re: [PATCHv4 07/39] thp, mm: basic defines for transparent huge page cache
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>

Better if one or two sentences are prepared to show that the following
defines are necessary.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/huge_mm.h |    8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 528454c..6b4c9b2 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -64,6 +64,10 @@ extern pmd_t *page_check_address_pmd(struct page *page,
>  #define HPAGE_PMD_MASK HPAGE_MASK
>  #define HPAGE_PMD_SIZE HPAGE_SIZE
>
> +#define HPAGE_CACHE_ORDER      (HPAGE_SHIFT - PAGE_CACHE_SHIFT)
> +#define HPAGE_CACHE_NR         (1L << HPAGE_CACHE_ORDER)
> +#define HPAGE_CACHE_INDEX_MASK (HPAGE_CACHE_NR - 1)
> +
>  extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
>
>  #define transparent_hugepage_enabled(__vma)                            \
> @@ -185,6 +189,10 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
>  #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
>  #define HPAGE_PMD_SIZE ({ BUILD_BUG(); 0; })
>
> +#define HPAGE_CACHE_ORDER      ({ BUILD_BUG(); 0; })
> +#define HPAGE_CACHE_NR         ({ BUILD_BUG(); 0; })
> +#define HPAGE_CACHE_INDEX_MASK ({ BUILD_BUG(); 0; })
> +
>  #define hpage_nr_pages(x) 1
>
>  #define transparent_hugepage_enabled(__vma) 0
> --
> 1.7.10.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
