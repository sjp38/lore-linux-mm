Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1C36A6B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 09:39:49 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so3155219eek.36
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 06:39:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h45si11102950eeo.172.2013.12.05.06.39.47
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 06:39:47 -0800 (PST)
Date: Thu, 05 Dec 2013 09:39:30 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386254370-ui1ehq60-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <52A03EE4.6030609@huawei.com>
References: <52A03EE4.6030609@huawei.com>
Subject: Re: [PATCH] mm: do_mincore() cleanup
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi <qiuxishi@huawei.com>

On Thu, Dec 05, 2013 at 04:52:52PM +0800, Jianguo Wu wrote:
> Two cleanups:
> 1. remove redundant codes for hugetlb pages.
> 2. end = pmd_addr_end(addr, end) restricts [addr, end) within PMD_SIZE,
>    this may increase do_mincore() calls, remove it.
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks!

Naoya

> ---
>  mm/mincore.c |    7 -------
>  1 files changed, 0 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/mincore.c b/mm/mincore.c
> index da2be56..1016233 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -225,13 +225,6 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>  
>  	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
>  
> -	if (is_vm_hugetlb_page(vma)) {
> -		mincore_hugetlb_page_range(vma, addr, end, vec);
> -		return (end - addr) >> PAGE_SHIFT;
> -	}
> -
> -	end = pmd_addr_end(addr, end);
> -
>  	if (is_vm_hugetlb_page(vma))
>  		mincore_hugetlb_page_range(vma, addr, end, vec);
>  	else
> -- 
> 1.7.1
> 
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
