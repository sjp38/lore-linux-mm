Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id 985466B00C2
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:27:51 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id r7so585617bkg.21
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:27:51 -0800 (PST)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id yh8si5326460bkb.100.2013.12.09.08.27.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 08:27:50 -0800 (PST)
Received: by mail-la0-f44.google.com with SMTP id ep20so1765544lab.3
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:27:50 -0800 (PST)
Date: Mon, 9 Dec 2013 17:27:27 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH] mm/hwpoison: add '#' to hwpoison_inject
Message-ID: <20131209162723.GA2236@hp530>
References: <1386322013-29554-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <1386322013-29554-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Wanpeng

On Fri, Dec 06, 2013 at 05:26:53PM +0800, Wanpeng Li wrote:
> Add '#' to hwpoison_inject just as done in madvise_hwpoison.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
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

You don't need KERN_INFO here.

Vladimir

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
