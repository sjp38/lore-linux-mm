Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id F10956B003D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 23:28:31 -0400 (EDT)
Date: Mon, 26 Aug 2013 23:28:16 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of madvise_hwpoison
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 27, 2013 at 10:39:31AM +0800, Wanpeng Li wrote:
> The return value outside for loop is always zero which means madvise_hwpoison 
> return success, however, this is not truth for soft_offline_page w/ failure
> return value.

I don't understand what you want to do for what reason. Could you clarify
those?

> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/madvise.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index a20764c..19b71e4 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -359,7 +359,7 @@ static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
>  				page_to_pfn(p), start);
>  			ret = soft_offline_page(p, MF_COUNT_INCREASED);
>  			if (ret)
> -				break;
> +				return ret;
>  			continue;
>  		}
>  		pr_info("Injecting memory failure for page %#lx at %#lx\n",

This seems to introduce no behavioral change.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
