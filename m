Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A987D6B0034
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:35:29 -0400 (EDT)
Date: Fri, 23 Aug 2013 10:35:12 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377268512-9c5ohh48-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377253841-17620-4-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377253841-17620-4-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/7] mm/hwpoison: replacing atomic_long_sub() with
 atomic_long_dec()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 23, 2013 at 06:30:38PM +0800, Wanpeng Li wrote:
> Repalce atomic_long_sub() with atomic_long_dec() since the page is 
> normal page instead of hugetlbfs page or thp.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/memory-failure.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index a6c4752..297965e 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1363,7 +1363,7 @@ int unpoison_memory(unsigned long pfn)
>  			return 0;
>  		}
>  		if (TestClearPageHWPoison(p))
> -			atomic_long_sub(nr_pages, &num_poisoned_pages);
> +			atomic_long_dec(&num_poisoned_pages);
>  		pr_info("MCE: Software-unpoisoned free page %#lx\n", pfn);
>  		return 0;
>  	}
> -- 
> 1.8.1.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
