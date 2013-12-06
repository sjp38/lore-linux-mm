Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id CBE826B0085
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 12:48:41 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id y10so989639wgg.12
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 09:48:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cd6si37067648wjc.57.2013.12.06.09.48.39
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 09:48:40 -0800 (PST)
Date: Fri, 06 Dec 2013 12:48:19 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386352099-a1o7ki65-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386322013-29554-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386322013-29554-1-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hwpoison: add '#' to hwpoison_inject
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 06, 2013 at 05:26:53PM +0800, Wanpeng Li wrote:
> Add '#' to hwpoison_inject just as done in madvise_hwpoison.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

It could affect some test code, but I checked mce-test and it doesn't
depend on this message. So maybe it's OK.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya

> ---
>  mm/hwpoison-inject.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> index 4c84678..146cead 100644
> --- a/mm/hwpoison-inject.c
> +++ b/mm/hwpoison-inject.c
> @@ -55,7 +55,7 @@ static int hwpoison_inject(void *data, u64 val)
>  		return 0;
>  
>  inject:
> -	printk(KERN_INFO "Injecting memory failure at pfn %lx\n", pfn);
> +	pr_info(KERN_INFO "Injecting memory failure at pfn %#lx\n", pfn);
>  	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
>  }
>  
> -- 
> 1.7.7.6
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
