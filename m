Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 401846B009E
	for <linux-mm@kvack.org>; Wed, 22 May 2013 06:52:49 -0400 (EDT)
Date: Wed, 22 May 2013 12:52:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] mm/hugetlb: use already exist interface
 huge_page_shift
Message-ID: <20130522105246.GF19989@dhcp22.suse.cz>
References: <1369214970-1526-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1369214970-1526-4-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369214970-1526-4-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 22-05-13 17:29:30, Wanpeng Li wrote:
> Use already exist interface huge_page_shift instead of h->order + PAGE_SHIFT.

alloc_bootmem_huge_page in powerpc uses the same construct so maybe you
want to udpate that one as well.

> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/hugetlb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index f8feeec..b6ff0ee 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -319,7 +319,7 @@ unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
>  
>  	hstate = hstate_vma(vma);
>  
> -	return 1UL << (hstate->order + PAGE_SHIFT);
> +	return 1UL << huge_page_shift(hstate);
>  }
>  EXPORT_SYMBOL_GPL(vma_kernel_pagesize);
>  
> -- 
> 1.8.1.2
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
