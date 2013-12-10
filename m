Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id AF28C6B006E
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 21:32:04 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so1706975bkb.30
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:32:03 -0800 (PST)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id s8si6208824bkh.189.2013.12.09.18.32.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 18:32:03 -0800 (PST)
Received: by mail-la0-f45.google.com with SMTP id eh20so2232502lab.4
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 18:32:03 -0800 (PST)
Date: Tue, 10 Dec 2013 03:31:37 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH v2] mm/hwpoison: add '#' to hwpoison_inject
Message-ID: <20131210023133.GA1849@hp530>
References: <1386632757-11783-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <1386632757-11783-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 10, 2013 at 07:45:57AM +0800, Wanpeng Li wrote:
> Changelog:
>  v1 -> v2:
>   * remove KERN_INFO in pr_info().
> 
> Add '#' to hwpoison_inject just as done in madvise_hwpoison.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/hwpoison-inject.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> index 4c84678..95487c7 100644
> --- a/mm/hwpoison-inject.c
> +++ b/mm/hwpoison-inject.c
> @@ -55,7 +55,7 @@ static int hwpoison_inject(void *data, u64 val)
>  		return 0;
>  
>  inject:
> -	printk(KERN_INFO "Injecting memory failure at pfn %lx\n", pfn);
> +	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
>  	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
>  }

Reviewed-by: Vladimir Murzin <murzin.v@gmail.com>

>  
> -- 
> 1.7.5.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
