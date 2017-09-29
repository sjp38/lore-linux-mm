Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B878D6B0069
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 16:43:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 10so117610wmv.16
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 13:43:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u83sor1248353wmg.33.2017.09.29.13.43.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Sep 2017 13:43:28 -0700 (PDT)
Date: Fri, 29 Sep 2017 22:43:21 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH] mm, hugetlb: fix "treat_as_movable" condition in
 htlb_alloc_mask
Message-ID: <20170929204321.GA593@gmail.com>
References: <20170929151339.GA4398@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170929151339.GA4398@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mike.kravetz@oracle.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, punit.agrawal@arm.com, gerald.schaefer@de.ibm.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On Fri, Sep 29, 2017 at 05:13:39PM +0200, Alexandru Moise wrote:
> If hugepage_migration_supported() returns true, this renders the
> hugepages_treat_as_movable sysctl completely pointless.
> 
> Let's keep this behavior optional by switching the if() condition
> from || to &&.
> 
> Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
> ---
>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 424b0ef08a60..ab28de0122af 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -926,7 +926,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
>  /* Movability of hugepages depends on migration support. */
>  static inline gfp_t htlb_alloc_mask(struct hstate *h)
>  {
> -	if (hugepages_treat_as_movable || hugepage_migration_supported(h))
> +	if (hugepages_treat_as_movable && hugepage_migration_supported(h))
>  		return GFP_HIGHUSER_MOVABLE;
>  	else
>  		return GFP_HIGHUSER;
> -- 
> 2.14.2
> 

I seem to have terribly misunderstood the semantics of this flag wrt hugepages,
please ignore this for now.

../Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
