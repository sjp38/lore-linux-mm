Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 36CFB6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:39:09 -0400 (EDT)
Date: Fri, 23 Aug 2013 10:38:54 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377268734-8oq8947y-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377253841-17620-7-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377253841-17620-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377253841-17620-7-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 7/7] mm/hwpoison: add '#' to madvise_hwpoison
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 23, 2013 at 06:30:41PM +0800, Wanpeng Li wrote:
> Add '#' to madvise_hwpoison.
> 
> Before patch:
> 
> [   95.892866] Injecting memory failure for page 19d0 at b7786000
> [   95.893151] MCE 0x19d0: non LRU page recovery: Ignored
> 
> After patch:
> 
> [   95.892866] Injecting memory failure for page 0x19d0 at 0xb7786000
> [   95.893151] MCE 0x19d0: non LRU page recovery: Ignored
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/madvise.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 95795df..588bb19 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -353,14 +353,14 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
>  		if (ret != 1)
>  			return ret;
>  		if (bhv == MADV_SOFT_OFFLINE) {
> -			printk(KERN_INFO "Soft offlining page %lx at %lx\n",
> +			pr_info("Soft offlining page %#lx at %#lx\n",
>  				page_to_pfn(p), start);
>  			ret = soft_offline_page(p, MF_COUNT_INCREASED);
>  			if (ret)
>  				break;
>  			continue;
>  		}
> -		printk(KERN_INFO "Injecting memory failure for page %lx at %lx\n",
> +		pr_info("Injecting memory failure for page %#lx at %#lx\n",
>  		       page_to_pfn(p), start);
>  		/* Ignore return value for now */
>  		memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
> -- 
> 1.8.1.2
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
