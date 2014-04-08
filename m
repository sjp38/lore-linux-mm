Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFC36B0031
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 15:52:25 -0400 (EDT)
Received: by mail-bk0-f42.google.com with SMTP id mx12so1193139bkb.1
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 12:52:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f2si1321177wjn.128.2014.04.08.12.52.22
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 12:52:23 -0700 (PDT)
Date: Tue, 08 Apr 2014 15:51:51 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <53445377.c22fc20a.4082.ffff890cSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1396983740-26047-2-git-send-email-lcapitulino@redhat.com>
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
 <1396983740-26047-2-git-send-email-lcapitulino@redhat.com>
Subject: Re: [PATCH 1/5] hugetlb: prep_compound_gigantic_page(): drop __init
 marker
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lcapitulino@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

Hi Luiz,

On Tue, Apr 08, 2014 at 03:02:16PM -0400, Luiz Capitulino wrote:
> This function is going to be used by non-init code in a future
> commit.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
> ---
>  mm/hugetlb.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7c02b9d..319db28 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -689,8 +689,7 @@ static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
>  	put_page(page); /* free it into the hugepage allocator */
>  }
>  
> -static void __init prep_compound_gigantic_page(struct page *page,
> -					       unsigned long order)
> +static void prep_compound_gigantic_page(struct page *page, unsigned long order)
>  {
>  	int i;
>  	int nr_pages = 1 << order;

Is __ClearPageReserved() in this function relevant only in boot time
allocation?  If yes, it might be good to avoid calling it in runtime
allocation.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
